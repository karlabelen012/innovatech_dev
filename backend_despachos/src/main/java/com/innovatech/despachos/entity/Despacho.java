package com.innovatech.despachos.entity;

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
 * Representa el despacho/entrega asociado a una venta.
 * No usa una relación JPA hacia Venta (esa entidad vive en otra base de
 * datos, en otro microservicio): solo guarda el id de referencia.
 */
@Entity
@Table(name = "despachos")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Despacho {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long ventaId;

    private LocalDate fechaDespacho;

    private String patenteCamion;

    private Integer intentosEntrega = 0;

    private Boolean despachado = false;
}
