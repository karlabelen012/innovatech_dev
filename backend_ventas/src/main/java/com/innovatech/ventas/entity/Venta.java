package com.innovatech.ventas.entity;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Representa una venta realizada por Innovatech Chile.
 * Cuando el microservicio de Despachos genera un despacho para esta venta,
 * llama de vuelta a este servicio para marcar despachoGenerado = true.
 */
@Entity
@Table(name = "ventas")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Venta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String direccionEntrega;

    private Double valorCompra;

    private LocalDate fechaCompra;

    private Boolean despachoGenerado = false;
}
