USE eusta_servicio_tecnico;

-- ============================================
-- DATOS INICIALES (CATÁLOGOS)
-- ============================================

-- Estados de orden (IMPORTANTE para trigger)
INSERT INTO ESTADO_ORDEN (nombre, descripcion, orden_visualizacion)
VALUES 
('RECIBIDA', 'Equipo recibido', 1),
('EN_DIAGNOSTICO', 'En diagnóstico', 2),
('EN_REPARACION', 'En reparación', 3),
('LISTA', 'Lista para entregar', 4),
('ENTREGADA', 'Entregada', 5);

-- ============================================
-- DATOS PRINCIPALES
-- ============================================

-- Técnicos
INSERT INTO TECNICOS (nombre, apellido, email, telefono)
VALUES 
('Ivan', 'Robledo', 'ivan@email.com', '123456789');

-- Clientes
INSERT INTO CLIENTES (nombre, apellido, dni, email, telefono, direccion)
VALUES 
('Juan', 'Perez', '12345678', 'juan@email.com', '111111111', 'Calle 123'),
('Maria', 'Gomez', '87654321', 'maria@email.com', '222222222', 'Calle 456');

-- Equipos
INSERT INTO EQUIPOS (id_cliente, tipo_equipo, marca, modelo, numero_serie, descripcion)
VALUES 
(1, 'Notebook', 'HP', 'Pavilion', 'SN123', 'Notebook 8GB RAM'),
(2, 'PC', 'Custom', 'Gamer', 'SN456', 'PC Gamer Ryzen');

-- Servicios
INSERT INTO SERVICIOS (nombre, descripcion, precio_base)
VALUES 
('Formateo', 'Formateo e instalación de sistema operativo', 10000),
('Limpieza', 'Limpieza interna del equipo', 5000);

-- Repuestos
INSERT INTO REPUESTOS (nombre, descripcion, stock, stock_minimo, costo_unitario, precio_sugerido)
VALUES 
('SSD 480GB', 'Disco sólido', 10, 2, 20000, 30000),
('Pasta térmica', 'Pasta térmica CPU', 20, 5, 2000, 5000);

-- ============================================
-- ORDENES DE TRABAJO
-- ============================================

-- Orden 1 (esto dispara trigger de estado inicial)
INSERT INTO ORDEN_TRABAJO (
    id_equipo,
    id_tecnico,
    problema_reportado,
    diagnostico,
    observaciones,
    total_estimado,
    total_final
)
VALUES (
    1,
    1,
    'La notebook no inicia',
    'Sistema operativo corrupto',
    'Requiere formateo',
    10000,
    12000
);

-- ============================================
-- DETALLE DE SERVICIOS
-- ============================================

INSERT INTO ORDEN_SERVICIO (
    id_orden,
    id_servicio,
    cantidad,
    precio_unitario,
    subtotal
)
VALUES (
    1,
    1,
    1,
    12000,
    12000
);

-- ============================================
-- DETALLE DE REPUESTOS (dispara trigger de stock)
-- ============================================

INSERT INTO ORDEN_REPUESTO (
    id_orden,
    id_repuesto,
    cantidad,
    costo_unitario,
    precio_unitario,
    subtotal
)
VALUES (
    1,
    2,
    1,
    2000,
    5000,
    5000
);

-- ============================================
-- PAGOS (para probar funciones)
-- ============================================

INSERT INTO PAGOS (
    id_orden,
    metodo_pago,
    monto,
    referencia,
    observacion
)
VALUES (
    1,
    'Efectivo',
    5000,
    'Pago inicial',
    'Seña'
);