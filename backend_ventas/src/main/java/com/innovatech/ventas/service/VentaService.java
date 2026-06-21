package com.innovatech.ventas.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import com.innovatech.ventas.entity.Venta;
import com.innovatech.ventas.repository.VentaRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VentaService {

    private final VentaRepository repository;

    public List<Venta> listar() {
        return repository.findAll();
    }

    public Venta obtener(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Venta no encontrada: " + id));
    }

    public Venta guardar(Venta venta) {
        return repository.save(venta);
    }

    public Venta actualizar(Long id, Venta datos) {
        Venta venta = obtener(id);
        venta.setDireccionEntrega(datos.getDireccionEntrega());
        venta.setValorCompra(datos.getValorCompra());
        venta.setFechaCompra(datos.getFechaCompra());
        return repository.save(venta);
    }

    public List<Venta> pendientesDeDespacho() {
        return repository.findByDespachoGeneradoFalse();
    }

    /**
     * Invocado internamente por el microservicio de Despachos (vía REST,
     * usando el nombre DNS interno del Service de Kubernetes "backend-ventas")
     * cuando se crea un despacho asociado a esta venta.
     */
    public Venta marcarComoDespachada(Long id) {
        Venta venta = obtener(id);
        venta.setDespachoGenerado(true);
        return repository.save(venta);
    }

    public void eliminar(Long id) {
        Venta venta = obtener(id);
        repository.delete(venta);
    }
}
