package com.innovatech.ventas.controller;

import java.util.List;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.innovatech.ventas.entity.Venta;
import com.innovatech.ventas.service.VentaService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/ventas")
@RequiredArgsConstructor
@CrossOrigin("*")
public class VentaController {

    private final VentaService service;

    @GetMapping
    public List<Venta> listar() {
        return service.listar();
    }

    @GetMapping("/{id}")
    public Venta obtener(@PathVariable Long id) {
        return service.obtener(id);
    }

    @GetMapping("/pendientes")
    public List<Venta> pendientes() {
        return service.pendientesDeDespacho();
    }

    @PostMapping
    public Venta crear(@RequestBody Venta venta) {
        return service.guardar(venta);
    }

    @PutMapping("/{id}")
    public Venta actualizar(@PathVariable Long id, @RequestBody Venta venta) {
        return service.actualizar(id, venta);
    }

    /**
     * Endpoint interno: lo llama el microservicio de Despachos (comunicación
     * servicio-a-servicio dentro del clúster) cuando se crea un despacho.
     */
    @PutMapping("/{id}/marcar-despachada")
    public Venta marcarComoDespachada(@PathVariable Long id) {
        return service.marcarComoDespachada(id);
    }

    @DeleteMapping("/{id}")
    public void eliminar(@PathVariable Long id) {
        service.eliminar(id);
    }
}
