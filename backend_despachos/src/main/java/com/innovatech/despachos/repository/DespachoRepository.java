package com.innovatech.despachos.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.innovatech.despachos.entity.Despacho;

public interface DespachoRepository extends JpaRepository<Despacho, Long> {

    List<Despacho> findByVentaId(Long ventaId);
}
