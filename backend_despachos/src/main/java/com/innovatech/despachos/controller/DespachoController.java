package com.innovatech.despachos.controller;

import java.util.List;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.innovatech.despachos.entity.Despacho;
import com.innovatech.despachos.service.DespachoService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/despachos")
@RequiredArgsConstructor
@CrossOrigin("*")
public class DespachoController {

    private final DespachoService service;

    @GetMapping
    public List<Despacho> listar() {
        return service.listar();
    }

    @GetMapping("/{id}")
    public Despacho obtener(@PathVariable Long id) {
        return service.obtener(id);
    }

    @GetMapping("/venta/{ventaId}")
    public List<Despacho> porVenta(@PathVariable Long ventaId) {
        return service.porVenta(ventaId);
    }

    @PostMapping
    public Despacho crear(@RequestBody Despacho despacho) {
        return service.crear(despacho);
    }

    @PutMapping("/{id}/intento")
    public Despacho registrarIntento(@PathVariable Long id, @RequestParam boolean exitoso) {
        return service.registrarIntento(id, exitoso);
    }

    @DeleteMapping("/{id}")
    public void eliminar(@PathVariable Long id) {
        service.eliminar(id);
    }
}
