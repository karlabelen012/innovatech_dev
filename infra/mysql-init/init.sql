-- Cada microservicio tiene su propia base de datos lógica (patrón
-- "database per service"), aunque ambas corren sobre la misma instancia
-- de MySQL para ahorrar recursos en el laboratorio de AWS Academy.
-- Ambos backends se conectan con el usuario root (igual que en el
-- proyecto de referencia del profe), cada uno apuntando a su propia BD.

CREATE DATABASE IF NOT EXISTS ventas_db;
CREATE DATABASE IF NOT EXISTS despachos_db;
