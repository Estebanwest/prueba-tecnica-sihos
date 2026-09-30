-- ============================================================
-- PRUEBA TÉCNICA - CONOCIMIENTOS EN BASES DE DATOS Y PROGRAMACIÓN
-- Dominio: Sistema de Gestión Hospitalaria (sihos_db)
-- ============================================================

-- ------------------------------------------------------------
-- DEFINICIÓN Y CREACIÓN DE LA BASE DE DATOS Y TABLA
-- ------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS sihos_db;
USE sihos_db;

CREATE TABLE IF NOT EXISTS productos (
    id_fabricante VARCHAR(10),
    id_producto VARCHAR(10),
    descripcion VARCHAR(100),
    precio DECIMAL(10,2),
    existencia INT
);

-- Inserción de datos iniciales
INSERT INTO productos (id_fabricante, id_producto, descripcion, precio, existencia) VALUES
('Aci', '41001', 'Aguja', 58, 227),
('Aci', '41002', 'Micropore', 80, 150),
('Aci', '41003', 'Gasa', 112, 80),
('Aci', '41004', 'Equipo macrogoteo', 110, 50),
('Bic', '41003', 'Curas', 120, 20),
('Inc', '41089', 'Canaleta', 500, 30),
('Qsa', 'Xk47', 'Compressa', 150, 200),
('Bic', 'Xk47', 'Compressa', 200, 200);

-- ------------------------------------------------------------
-- CONSULTAS SOLICITADAS
-- ------------------------------------------------------------

-- Punto 1: Listado de productos con IVA (10%) incluido
SELECT 
    id_fabricante, 
    id_producto, 
    descripcion, 
    precio, 
    ROUND(precio * 1.10, 2) AS precio_con_iva
FROM productos;

-- Punto 2: Cantidad total de existencias agrupadas por producto
SELECT 
    descripcion, 
    SUM(existencia) AS total_existencias
FROM productos
GROUP BY descripcion;

-- Punto 3: Promedio de precio por fabricante
SELECT 
    id_fabricante, 
    ROUND(AVG(precio), 2) AS promedio_precio
FROM productos
GROUP BY id_fabricante;

-- Punto 4: Obtener el producto con mayor precio
SELECT 
    id_fabricante, 
    id_producto, 
    descripcion, 
    precio
FROM productos
ORDER BY precio DESC
LIMIT 1;

-- Punto 5: Cargar en el sistema un nuevo pedido de 500 Curas que envió el fabricante Bic
UPDATE productos 
SET existencia = existencia + 500 
WHERE id_fabricante = 'Bic' AND descripcion = 'Curas';

-- Punto 6: Eliminar de la base de datos los productos del fabricante Qsa
DELETE FROM productos 
WHERE id_fabricante = 'Qsa';