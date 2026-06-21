import { useEffect, useState } from 'react'
import VentaCard from './components/VentaCard'
import VentaForm from './components/VentaForm'
import DespachoCard from './components/DespachoCard'
import DespachoForm from './components/DespachoForm'
import {
  obtenerVentas,
  crearVenta,
  eliminarVenta,
  obtenerDespachos,
  crearDespacho,
  eliminarDespacho,
} from './services/api'
import './App.css'

function App() {
  const [tab, setTab] = useState('ventas')
  const [ventas, setVentas] = useState([])
  const [despachos, setDespachos] = useState([])
  const [error, setError] = useState(null)

  const cargarVentas = async () => {
    try {
      setVentas(await obtenerVentas())
    } catch (err) {
      setError(err.message)
    }
  }

  const cargarDespachos = async () => {
    try {
      setDespachos(await obtenerDespachos())
    } catch (err) {
      setError(err.message)
    }
  }

  useEffect(() => {
    cargarVentas()
    cargarDespachos()
  }, [])

  const handleCrearVenta = async (venta) => {
    try {
      await crearVenta(venta)
      await cargarVentas()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleEliminarVenta = async (id) => {
    try {
      await eliminarVenta(id)
      await cargarVentas()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleCrearDespacho = async (despacho) => {
    try {
      await crearDespacho(despacho)
      await cargarDespachos()
      // El backend de Ventas pudo haber sido actualizado por el backend de
      // Despachos (comunicación entre microservicios): refrescamos.
      await cargarVentas()
    } catch (err) {
      setError(err.message)
    }
  }

  const handleEliminarDespacho = async (id) => {
    try {
      await eliminarDespacho(id)
      await cargarDespachos()
    } catch (err) {
      setError(err.message)
    }
  }

  return (
    <div className="container">
      <header className="header">
        <h1>Innovatech Chile</h1>
        <p className="subtitle">Gestión de Ventas y Despachos · EP3 DevOps</p>
      </header>

      {error && <div className="error-banner">{error}</div>}

      <nav className="tabs">
        <button className={tab === 'ventas' ? 'tab active' : 'tab'} onClick={() => setTab('ventas')}>
          Ventas ({ventas.length})
        </button>
        <button className={tab === 'despachos' ? 'tab active' : 'tab'} onClick={() => setTab('despachos')}>
          Despachos ({despachos.length})
        </button>
      </nav>

      {tab === 'ventas' && (
        <section>
          <VentaForm onCrear={handleCrearVenta} />
          <div className="grid">
            {ventas.map((venta) => (
              <VentaCard key={venta.id} venta={venta} onEliminar={handleEliminarVenta} />
            ))}
          </div>
        </section>
      )}

      {tab === 'despachos' && (
        <section>
          <DespachoForm ventas={ventas} onCrear={handleCrearDespacho} />
          <div className="grid">
            {despachos.map((despacho) => (
              <DespachoCard key={despacho.id} despacho={despacho} onEliminar={handleEliminarDespacho} />
            ))}
          </div>
        </section>
      )}
    </div>
  )
}

export default App
