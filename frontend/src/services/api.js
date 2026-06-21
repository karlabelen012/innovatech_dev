// Cliente API del frontend. En producción (Nginx en el pod) /api/ventas y
// /api/despachos se reescriben hacia cada microservicio. En desarrollo local
// (npm run dev) usa VITE_API_BASE si está definida, o las mismas rutas
// relativas si corres todo detrás de un proxy/docker-compose con Nginx.

const VENTAS_API = '/api/ventas'
const DESPACHOS_API = '/api/despachos'

async function manejarRespuesta(response, mensajeError) {
  if (!response.ok) {
    throw new Error(mensajeError)
  }
  if (response.status === 204) return null
  return await response.json()
}

// ---------- Ventas ----------

export async function obtenerVentas() {
  const response = await fetch(`${VENTAS_API}/`)
  return manejarRespuesta(response, 'Error al obtener ventas')
}

export async function crearVenta(venta) {
  const response = await fetch(`${VENTAS_API}/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(venta),
  })
  return manejarRespuesta(response, 'Error al crear la venta')
}

export async function eliminarVenta(id) {
  const response = await fetch(`${VENTAS_API}/${id}`, { method: 'DELETE' })
  return manejarRespuesta(response, 'Error al eliminar la venta')
}

// ---------- Despachos ----------

export async function obtenerDespachos() {
  const response = await fetch(`${DESPACHOS_API}/`)
  return manejarRespuesta(response, 'Error al obtener despachos')
}

export async function crearDespacho(despacho) {
  const response = await fetch(`${DESPACHOS_API}/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(despacho),
  })
  return manejarRespuesta(response, 'Error al crear el despacho')
}

export async function eliminarDespacho(id) {
  const response = await fetch(`${DESPACHOS_API}/${id}`, { method: 'DELETE' })
  return manejarRespuesta(response, 'Error al eliminar el despacho')
}
