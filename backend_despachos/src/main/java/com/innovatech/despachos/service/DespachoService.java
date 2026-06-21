package com.innovatech.despachos.service;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import com.innovatech.despachos.client.VentasClient;
import com.innovatech.despachos.entity.Despacho;
import com.innovatech.despachos.repository.DespachoRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DespachoService {

    private final DespachoRepository repository;
    private final VentasClient ventasClient;

    public List<Despacho> listar() {
        return repository.findAll();
    }

    public Despacho obtener(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Despacho no encontrado: " + id));
    }

    public List<Despacho> porVenta(Long ventaId) {
        return repository.findByVentaId(ventaId);
    }

    public Despacho crear(Despacho despacho) {
        Despacho guardado = repository.save(despacho);
        // Comunicación entre microservicios: Despachos -> Ventas
        ventasClient.marcarVentaComoDespachada(guardado.getVentaId());
        return guardado;
    }

    public Despacho registrarIntento(Long id, boolean exitoso) {
        Despacho despacho = obtener(id);
        despacho.setIntentosEntrega(despacho.getIntentosEntrega() + 1);
        despacho.setDespachado(exitoso);
        return repository.save(despacho);
    }

    public void eliminar(Long id) {
        Despacho despacho = obtener(id);
        repository.delete(despacho);
    }
}
