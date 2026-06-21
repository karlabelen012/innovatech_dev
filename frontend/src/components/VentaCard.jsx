function VentaCard({ venta, onEliminar }) {
  return (
    <div className="card">
      <div className="card-header">
        <span className="card-id">Venta #{venta.id}</span>
        <span className={`badge ${venta.despachoGenerado ? 'badge-ok' : 'badge-pendiente'}`}>
          {venta.despachoGenerado ? 'Despachada' : 'Pendiente'}
        </span>
      </div>
      <p><strong>Dirección:</strong> {venta.direccionEntrega}</p>
      <p><strong>Valor:</strong> ${Number(venta.valorCompra).toLocaleString('es-CL')}</p>
      <p><strong>Fecha compra:</strong> {venta.fechaCompra}</p>
      <button className="btn-eliminar" onClick={() => onEliminar(venta.id)}>
        Eliminar
      </button>
    </div>
  )
}

export default VentaCard
