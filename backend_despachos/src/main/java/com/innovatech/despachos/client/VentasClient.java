package com.innovatech.despachos.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * Cliente HTTP hacia el microservicio de Ventas.
 *
 * Esta es la comunicación servicio-a-servicio dentro del clúster: se usa el
 * nombre del Service de Kubernetes ("backend-ventas") como hostname, que
 * Kubernetes resuelve internamente vía DNS (kube-dns/CoreDNS). El mismo
 * nombre de host también funciona en docker-compose local porque ahí los
 * contenedores se resuelven por nombre de servicio.
 */
@Component
public class VentasClient {

    private static final Logger log = LoggerFactory.getLogger(VentasClient.class);

    private final RestTemplate restTemplate;

    @Value("${ventas.service.url}")
    private String ventasServiceUrl;

    public VentasClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Avisa a Ventas que ya se generó un despacho para esa venta.
     * Si Ventas no responde (caída, redeploy, etc.) el despacho igual se
     * guarda: la notificación no debe bloquear la operación principal.
     */
    public void marcarVentaComoDespachada(Long ventaId) {
        String url = ventasServiceUrl + "/api/v1/ventas/" + ventaId + "/marcar-despachada";
        try {
            restTemplate.put(url, null);
            log.info("Venta {} marcada como despachada en backend-ventas", ventaId);
        } catch (RestClientException ex) {
            log.warn("No se pudo notificar a backend-ventas para la venta {}: {}", ventaId, ex.getMessage());
        }
    }
}
