USE eusta_servicio_tecnico;

-- ============================================================
-- VISTAS
-- ============================================================

DROP VIEW IF EXISTS vw_ordenes_clientes;
CREATE VIEW vw_ordenes_clientes AS
SELECT 
    ot.id_orden,
    ot.fecha_ingreso,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.apellido AS apellido_cliente,
    e.id_equipo,
    e.tipo_equipo,
    e.marca,
    e.modelo,
    t.id_tecnico,
    t.nombre AS nombre_tecnico,
    t.apellido AS apellido_tecnico,
    ot.problema_reportado,
    ot.diagnostico,
    ot.total_estimado,
    ot.total_final,
    ot.fecha_cierre
FROM ORDEN_TRABAJO ot
INNER JOIN EQUIPOS e ON ot.id_equipo = e.id_equipo
INNER JOIN CLIENTES c ON e.id_cliente = c.id_cliente
INNER JOIN TECNICOS t ON ot.id_tecnico = t.id_tecnico;


DROP VIEW IF EXISTS vw_pagos_por_orden;
CREATE VIEW vw_pagos_por_orden AS
SELECT
    p.id_pago,
    p.id_orden,
    p.fecha_pago,
    p.metodo_pago,
    p.monto,
    p.referencia,
    p.observacion
FROM PAGOS p;

-- ============================================================
-- FUNCIONES
-- ============================================================

DROP FUNCTION IF EXISTS fn_total_pagado;
DROP FUNCTION IF EXISTS fn_saldo_pendiente;

DELIMITER //

CREATE FUNCTION fn_total_pagado(p_id_orden INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total_pagado DECIMAL(10,2);

    SELECT IFNULL(SUM(monto), 0.00)
    INTO v_total_pagado
    FROM PAGOS
    WHERE id_orden = p_id_orden;

    RETURN v_total_pagado;
END //

CREATE FUNCTION fn_saldo_pendiente(p_id_orden INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total_final DECIMAL(10,2);
    DECLARE v_saldo DECIMAL(10,2);

    SELECT IFNULL(total_final, 0.00)
    INTO v_total_final
    FROM ORDEN_TRABAJO
    WHERE id_orden = p_id_orden;

    SET v_saldo = v_total_final - fn_total_pagado(p_id_orden);

    RETURN v_saldo;
END //

DELIMITER ;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DROP PROCEDURE IF EXISTS sp_registrar_pago;
DROP PROCEDURE IF EXISTS sp_cambiar_estado_orden;

DELIMITER //

CREATE PROCEDURE sp_registrar_pago(
    IN p_id_orden INT,
    IN p_metodo_pago VARCHAR(30),
    IN p_monto DECIMAL(10,2),
    IN p_referencia VARCHAR(100),
    IN p_observacion VARCHAR(255)
)
BEGIN
    INSERT INTO PAGOS (
        id_orden,
        fecha_pago,
        metodo_pago,
        monto,
        referencia,
        observacion
    )
    VALUES (
        p_id_orden,
        CURRENT_TIMESTAMP,
        p_metodo_pago,
        p_monto,
        p_referencia,
        p_observacion
    );
END //

CREATE PROCEDURE sp_cambiar_estado_orden(
    IN p_id_orden INT,
    IN p_id_estado INT,
    IN p_observacion VARCHAR(255)
)
BEGIN
    INSERT INTO ORDEN_ESTADO (
        id_orden,
        id_estado,
        fecha_hora,
        observacion
    )
    VALUES (
        p_id_orden,
        p_id_estado,
        CURRENT_TIMESTAMP,
        p_observacion
    );
END //

DELIMITER ;

-- ============================================================
-- TRIGGERS
-- ============================================================

DROP TRIGGER IF EXISTS tr_descontar_stock_repuesto;
DROP TRIGGER IF EXISTS tr_estado_inicial_orden;

DELIMITER //

CREATE TRIGGER tr_descontar_stock_repuesto
AFTER INSERT ON ORDEN_REPUESTO
FOR EACH ROW
BEGIN
    UPDATE REPUESTOS
    SET stock = stock - NEW.cantidad
    WHERE id_repuesto = NEW.id_repuesto;
END //

CREATE TRIGGER tr_estado_inicial_orden
AFTER INSERT ON ORDEN_TRABAJO
FOR EACH ROW
BEGIN
    DECLARE v_id_estado INT;

    SELECT id_estado
    INTO v_id_estado
    FROM ESTADO_ORDEN
    WHERE nombre = 'RECIBIDA'
    LIMIT 1;

    IF v_id_estado IS NOT NULL THEN
        INSERT INTO ORDEN_ESTADO (
            id_orden,
            id_estado,
            fecha_hora,
            observacion
        )
        VALUES (
            NEW.id_orden,
            v_id_estado,
            CURRENT_TIMESTAMP,
            'Estado inicial automático'
        );
    END IF;
END //

DELIMITER ;