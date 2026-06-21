import { useState } from 'react'

function VentaForm({ onCrear }) {
  const [direccionEntrega, setDireccionEntrega] = useState('')
  const [valorCompra, setValorCompra] = useState('')
  const [fechaCompra, setFechaCompra] = useState('')

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!direccionEntrega || !valorCompra || !fechaCompra) return

    await onCrear({
      direccionEntrega,
      valorCompra: Number(valorCompra),
      fechaCompra,
    })

    setDireccionEntrega('')
    setValorCompra('')
    setFechaCompra('')
  }

  return (
    <form className="form" onSubmit={handleSubmit}>
      <h3>Nueva venta</h3>
      <input
        type="text"
        placeholder="Dirección de entrega"
        value={direccionEntrega}
        onChange={(e) => setDireccionEntrega(e.target.value)}
        required
      />
      <input
        type="number"
        placeholder="Valor de la compra"
        value={valorCompra}
        onChange={(e) => setValorCompra(e.target.value)}
        required
      />
      <input
        type="date"
        value={fechaCompra}
        onChange={(e) => setFechaCompra(e.target.value)}
        required
      />
      <button type="submit">Registrar venta</button>
    </form>
  )
}

export default VentaForm
