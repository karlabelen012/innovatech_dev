import { useState } from 'react'

function DespachoForm({ ventas, onCrear }) {
  const [ventaId, setVentaId] = useState('')
  const [patenteCamion, setPatenteCamion] = useState('')
  const [fechaDespacho, setFechaDespacho] = useState('')

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!ventaId || !patenteCamion || !fechaDespacho) return

    await onCrear({
      ventaId: Number(ventaId),
      patenteCamion,
      fechaDespacho,
    })

    setVentaId('')
    setPatenteCamion('')
    setFechaDespacho('')
  }

  return (
    <form className="form" onSubmit={handleSubmit}>
      <h3>Nuevo despacho</h3>
      <select value={ventaId} onChange={(e) => setVentaId(e.target.value)} required>
        <option value="">Selecciona una venta</option>
        {ventas.map((venta) => (
          <option key={venta.id} value={venta.id}>
            Venta #{venta.id} - {venta.direccionEntrega}
          </option>
        ))}
      </select>
      <input
        type="text"
        placeholder="Patente del camión"
        value={patenteCamion}
        onChange={(e) => setPatenteCamion(e.target.value)}
        required
      />
      <input
        type="date"
        value={fechaDespacho}
        onChange={(e) => setFechaDespacho(e.target.value)}
        required
      />
      <button type="submit">Registrar despacho</button>
    </form>
  )
}

export default DespachoForm
