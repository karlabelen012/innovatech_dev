function DespachoCard({ despacho, onEliminar }) {
  return (
    <div className="card">
      <div className="card-header">
        <span className="card-id">Despacho #{despacho.id}</span>
        <span className={`badge ${despacho.despachado ? 'badge-ok' : 'badge-pendiente'}`}>
          {despacho.despachado ? 'Entregado' : 'En proceso'}
        </span>
      </div>
      <p><strong>Venta asociada:</strong> #{despacho.ventaId}</p>
      <p><strong>Patente camión:</strong> {despacho.patenteCamion}</p>
      <p><strong>Fecha despacho:</strong> {despacho.fechaDespacho}</p>
      <p><strong>Intentos de entrega:</strong> {despacho.intentosEntrega}</p>
      <button className="btn-eliminar" onClick={() => onEliminar(despacho.id)}>
        Eliminar
      </button>
    </div>
  )
}

export default DespachoCard
