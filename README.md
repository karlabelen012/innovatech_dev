# Innovatech Chile — Ventas y Despachos (EP3 DevOps · ISY1101)

Sistema de gestión de **Ventas** y **Despachos** para la empresa Innovatech
Chile, desplegado en **AWS EKS** con autoscaling, pipeline CI/CD vía GitHub
Actions y arquitectura de microservicios.

Este repo retoma la app de EP2 (contenedorización) y la lleva a un entorno de
**orquestación productiva**, según el caso de la Evaluación Parcial N°3:
clúster EKS, despliegue de Frontend + Backend desde ECR, autoscaling (HPA) y
pipeline `build → push → deploy` automatizado.

## Arquitectura

```
                         Internet
                            │
                    (Service LoadBalancer)
                            │
                      ┌───────────┐
                      │ frontend  │  React + Vite + Nginx (2 réplicas)
                      └─────┬─────┘
                proxy /api/ventas/    proxy /api/despachos/
                            │                    │
                ┌───────────▼──────┐   ┌─────────▼──────────┐
                │  backend-ventas   │   │ backend-despachos   │
                │  Spring Boot      │──▶│ Spring Boot         │
                │  :8080 (HPA 2-5)  │   │ :8081 (HPA 2-5)     │
                └─────────┬─────────┘   └─────────┬───────────┘
                          │                        │
                          └──────────┬─────────────┘
                                     │
                               ┌─────▼─────┐
                               │   mysql   │  ventas_db / despachos_db
                               └───────────┘
```

La flecha `backend-despachos → backend-ventas` es comunicación real
servicio-a-servicio: cuando se crea un despacho, `backend-despachos` llama
internamente a `backend-ventas` (vía el nombre DNS del Service de
Kubernetes, `http://backend-ventas:8080`) para marcar la venta como
despachada.

| Componente | Tecnología | Puerto | Tipo de Service |
|---|---|---|---|
| `frontend` | React + Vite + Nginx | 80 | `LoadBalancer` (público) |
| `backend-ventas` | Spring Boot | 8080 | `ClusterIP` (interno) |
| `backend-despachos` | Spring Boot | 8081 | `ClusterIP` (interno) |
| `mysql` | MySQL 8.0 (2 BD lógicas) | 3306 | `ClusterIP` (interno) |

## Estructura del repositorio

```
.
├── frontend/                 # React + Vite, Dockerfile, nginx.conf
├── backend-ventas/           # Spring Boot - microservicio de Ventas
├── backend-despachos/        # Spring Boot - microservicio de Despachos
├── infra/
│   ├── terraform/            # VPC, EKS, Node Group, ECR x3, CloudWatch
│   ├── k8s/                  # Deployments, Services, HPA, Secret template
│   └── mysql-init/           # Script que crea ventas_db y despachos_db
├── .github/workflows/cd.yml  # Pipeline build -> push ECR -> deploy EKS
├── docker-compose.yml        # Entorno local
└── CHECKLIST_EVIDENCIAS_EP3.md
```

## 1. Correr en local (docker-compose)

```bash
cp .env.example .env
# edita .env y define una contraseña para MYSQL_ROOT_PASSWORD

docker compose up --build
```

- Frontend: http://localhost:3000
- Backend Ventas: http://localhost:8080/api/v1/ventas
- Backend Despachos: http://localhost:8081/api/v1/despachos

## 2. Desplegar en AWS Academy (Learner Lab)

### 2.1 Obtener credenciales del laboratorio

Entra a **AWS Academy → Start Lab**, espera el círculo verde y luego
**AWS Details → Show**. Copia las 3 credenciales:

```bash
aws configure set aws_access_key_id     TU_ACCESS_KEY
aws configure set aws_secret_access_key TU_SECRET_KEY
aws configure set aws_session_token     TU_SESSION_TOKEN
aws configure set default.region        us-east-1

aws sts get-caller-identity   # verifica que quedaste autenticado
```

> Las credenciales de AWS Academy **expiran** (normalmente cada 3-4 horas).
> Si un comando empieza a fallar con `ExpiredToken`, repite este paso.

### 2.2 Provisionar la infraestructura con Terraform

```bash
cd infra/terraform
terraform init
terraform apply -auto-approve
```

Tarda **10-15 minutos** (VPC, NAT Gateway, clúster EKS y Node Group).
Al finalizar, copia las URLs de los 3 ECR que aparecen en el output.

### 2.3 Conectar kubectl al clúster

```bash
aws eks update-kubeconfig --region us-east-1 --name innovatech-cluster
kubectl get nodes
```

Espera a que los nodos queden en estado `Ready`.

### 2.4 Instalar metrics-server (obligatorio para el HPA)

EKS **no trae metrics-server preinstalado**. Sin esto, `kubectl get hpa`
mostrará `<unknown>` en el uso de CPU y el autoscaling nunca se activará:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verifica que quede en Running:
kubectl get pods -n kube-system | grep metrics-server
```

### 2.5 Crear el Secret de MySQL (gestión de credenciales — IE5)

La contraseña de MySQL **no se guarda en el código fuente**, se crea
directamente en el clúster:

```bash
kubectl create secret generic innovatech-secrets \
  --from-literal=MYSQL_ROOT_PASSWORD='TuPasswordSegura123'
```

### 2.6 Configurar los Secrets de GitHub Actions

En tu repo de GitHub → **Settings → Secrets and variables → Actions**,
crea/actualiza:

| Secret | Valor |
|---|---|
| `AWS_ACCESS_KEY_ID` | El de AWS Academy (paso 2.1) |
| `AWS_SECRET_ACCESS_KEY` | El de AWS Academy |
| `AWS_SESSION_TOKEN` | El de AWS Academy |

### 2.7 Disparar el pipeline

```bash
git add .
git commit -m "ci: trigger EP3 deploy pipeline"
git push origin deploy
```

Esto ejecuta `.github/workflows/cd.yml`: build de las 3 imágenes → push a
ECR → `kubectl apply` de los manifiestos → `kubectl set image` con la
imagen recién publicada → espera el rollout.

### 2.8 Verificar el despliegue

```bash
kubectl get pods -o wide
kubectl get svc frontend     # columna EXTERNAL-IP = URL pública
kubectl get hpa
kubectl logs deployment/backend-ventas
kubectl logs deployment/backend-despachos
```

Abre la `EXTERNAL-IP` del service `frontend` en el navegador.

## 3. Demostrar el autoscaling (evidencia para IE3 / IE9)

Genera carga sobre uno de los backends para que el HPA escale:

```bash
kubectl run carga --image=busybox --restart=Never -- /bin/sh -c \
  "while true; do wget -q -O- http://backend-ventas:8080/api/v1/ventas; done"

# En otra terminal, observa cómo sube el % de CPU y las réplicas:
kubectl get hpa -w
```

Cuando termines, limpia el generador de carga:

```bash
kubectl delete pod carga
```

Toma capturas de `kubectl get hpa -w` mostrando el cambio de réplicas — es
la evidencia que pide el indicador IE3 ("Capturas de configuración" y
"Evidencia de métricas o simulación de carga").

## 4. Comunicación Frontend → Backend → Backend (IE7)

- El **frontend** llega al usuario por la URL pública del `LoadBalancer`.
- Nginx, dentro del pod del frontend, reescribe `/api/ventas/*` y
  `/api/despachos/*` hacia los Services internos `backend-ventas` y
  `backend-despachos` (DNS interno de Kubernetes, resuelto por CoreDNS).
- Al crear un despacho, `backend-despachos` llama a
  `backend-ventas:8080/api/v1/ventas/{id}/marcar-despachada` usando el mismo
  nombre DNS interno — esto es comunicación servicio-a-servicio real, no
  solo Frontend → Backend.

## 5. Limpiar recursos (importante: el lab tiene tiempo límite)

Al terminar de practicar o antes de que termine la sesión del Learner Lab:

```bash
cd infra/terraform
terraform destroy -auto-approve
```

Esto evita dejar el clúster EKS y el NAT Gateway corriendo (son los recursos
que más rápido consumen el presupuesto del laboratorio).

## 6. Problemas comunes

| Síntoma | Causa probable | Solución |
|---|---|---|
| `ExpiredToken` en cualquier comando AWS | Credenciales de Academy vencidas | Repite el paso 2.1 y actualiza los Secrets de GitHub |
| `kubectl get hpa` muestra `<unknown>` | metrics-server no instalado | Repite el paso 2.4 |
| Pods en `ImagePullBackOff` la primera vez | El manifiesto trae `REPLACE_*_IMAGE` hasta que corre el pipeline | Es esperado en el primer `kubectl apply` manual; el pipeline lo corrige con `kubectl set image` |
| `CrashLoopBackOff` en los backends | MySQL aún no está `Ready` cuando arrancan | Espera unos segundos y revisa `kubectl logs`; el `readinessProbe` reintenta solo |
| Node Group no se crea / queda en `CREATE_FAILED` | Cuota de instancias del Learner Lab agotada | Reduce `desired_size`/`max_size` en `variables.tf` o reintenta más tarde |
| El despacho se crea pero la venta no queda "Despachada" | `backend-ventas` no respondía cuando se llamó | Es resiliente a propósito (ver `VentasClient`); revisa logs de `backend-despachos` |

## 7. Stack técnico

- **Backend:** Java 21, Spring Boot, Spring Data JPA, MySQL 8.0
- **Frontend:** React 19, Vite, Nginx
- **Contenedores:** Docker (build multi-stage)
- **Orquestación:** Kubernetes (Amazon EKS)
- **IaC:** Terraform (`~> 5.0` provider AWS)
- **CI/CD:** GitHub Actions
- **Registro de imágenes:** Amazon ECR
- **Autoscaling:** Horizontal Pod Autoscaler (CPU 50%)

---

Ver también [`CHECKLIST_EVIDENCIAS_EP3.md`](./CHECKLIST_EVIDENCIAS_EP3.md)
para la lista de capturas/evidencias que pide la pauta de evaluación.
