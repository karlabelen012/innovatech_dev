package com.innovatech.ventas.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.innovatech.ventas.entity.Venta;

public interface VentaRepository extends JpaRepository<Venta, Long> {

    List<Venta> findByDespachoGeneradoFalse();
}
