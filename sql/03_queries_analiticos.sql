-- =============================================
-- BANCO ANALYTICS - QUERIES ANALÍTICOS
-- Proyecto: Especialista Data Analytics y Proyectos
-- Autor: Danilo Arturo


-- ============================================
-- SECCIÓN 1: ANÁLISIS DE CLIENTES
-- ============================================

-- 1.1 Distribución de clientes por segmento
SELECT 
    segmento,
    COUNT(*) AS total_clientes,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM clientes
WHERE activo = TRUE
GROUP BY segmento
ORDER BY total_clientes DESC;


-- 1.2 Distribución de clientes por tipo y segmento
SELECT 
    tipo_cliente,
    segmento,
    COUNT(*) AS total
FROM clientes
WHERE activo = TRUE
GROUP BY tipo_cliente, segmento
ORDER BY tipo_cliente, segmento;


-- 1.3 Top 5 departamentos con más clientes
SELECT 
    departamento,
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN tipo_cliente = 'empresarial' THEN 1 ELSE 0 END) AS empresariales,
    SUM(CASE WHEN tipo_cliente = 'individual' THEN 1 ELSE 0 END) AS individuales
FROM clientes
WHERE activo = TRUE
GROUP BY departamento
ORDER BY total_clientes DESC
LIMIT 5;


-- 1.4 Clientes nuevos por año
SELECT 
    EXTRACT(YEAR FROM fecha_apertura) AS anio,
    COUNT(*) AS clientes_nuevos
FROM clientes
GROUP BY EXTRACT(YEAR FROM fecha_apertura)
ORDER BY anio;


-- 1.5 Clientes con múltiples cuentas
SELECT 
    c.id_cliente,
    c.nombre,
    c.tipo_cliente,
    c.segmento,
    COUNT(cu.id_cuenta) AS num_cuentas,
    SUM(cu.saldo_actual) AS saldo_total
FROM clientes c
JOIN cuentas cu ON c.id_cliente = cu.id_cliente
GROUP BY c.id_cliente, c.nombre, c.tipo_cliente, c.segmento
HAVING COUNT(cu.id_cuenta) > 1
ORDER BY num_cuentas DESC;


-- ============================================
-- SECCIÓN 2: ANÁLISIS DE CUENTAS
-- ============================================

-- 2.1 Resumen de cuentas por tipo y moneda
SELECT 
    tipo_cuenta,
    moneda,
    COUNT(*) AS total_cuentas,
    SUM(saldo_actual) AS saldo_total,
    ROUND(AVG(saldo_actual), 2) AS saldo_promedio
FROM cuentas
WHERE estado = 'activa'
GROUP BY tipo_cuenta, moneda
ORDER BY saldo_total DESC;


-- 2.2 Top 10 cuentas con mayor saldo
SELECT 
    cu.numero_cuenta,
    c.nombre AS cliente,
    c.tipo_cliente,
    cu.tipo_cuenta,
    cu.moneda,
    cu.saldo_actual
FROM cuentas cu
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE cu.estado = 'activa'
ORDER BY cu.saldo_actual DESC
LIMIT 10;


-- 2.3 Distribución de saldos por segmento de cliente
SELECT 
    c.segmento,
    COUNT(cu.id_cuenta) AS num_cuentas,
    SUM(cu.saldo_actual) AS saldo_total,
    ROUND(AVG(cu.saldo_actual), 2) AS saldo_promedio,
    MIN(cu.saldo_actual) AS saldo_minimo,
    MAX(cu.saldo_actual) AS saldo_maximo
FROM clientes c
JOIN cuentas cu ON c.id_cliente = cu.id_cliente
WHERE cu.estado = 'activa' AND cu.moneda = 'GTQ'
GROUP BY c.segmento
ORDER BY saldo_total DESC;


-- 2.4 Cuentas bloqueadas o inactivas
SELECT 
    cu.numero_cuenta,
    c.nombre AS cliente,
    cu.tipo_cuenta,
    cu.estado,
    cu.saldo_actual,
    cu.fecha_apertura
FROM cuentas cu
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE cu.estado IN ('bloqueada', 'inactiva');


-- ============================================
-- SECCIÓN 3: ANÁLISIS DE TRANSACCIONES
-- ============================================

-- 3.1 Volumen de transacciones por tipo
SELECT 
    tipo_transaccion,
    COUNT(*) AS num_transacciones,
    SUM(monto) AS monto_total,
    ROUND(AVG(monto), 2) AS monto_promedio
FROM transacciones
WHERE estado = 'completada'
GROUP BY tipo_transaccion
ORDER BY monto_total DESC;


-- 3.2 Transacciones por canal
SELECT 
    canal,
    COUNT(*) AS num_transacciones,
    SUM(monto) AS monto_total,
    ROUND(AVG(monto), 2) AS monto_promedio,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje_uso
FROM transacciones
WHERE estado = 'completada'
GROUP BY canal
ORDER BY num_transacciones DESC;


-- 3.3 Tendencia mensual de transacciones
SELECT 
    TO_CHAR(fecha_hora, 'YYYY-MM') AS mes,
    COUNT(*) AS num_transacciones,
    SUM(monto) AS monto_total,
    COUNT(DISTINCT id_cuenta) AS cuentas_activas
FROM transacciones
WHERE estado = 'completada'
GROUP BY TO_CHAR(fecha_hora, 'YYYY-MM')
ORDER BY mes;


-- 3.4 Transacciones por día de la semana
SELECT 
    TO_CHAR(fecha_hora, 'Day') AS dia_semana,
    EXTRACT(DOW FROM fecha_hora) AS num_dia,
    COUNT(*) AS num_transacciones,
    SUM(monto) AS monto_total
FROM transacciones
WHERE estado = 'completada'
GROUP BY TO_CHAR(fecha_hora, 'Day'), EXTRACT(DOW FROM fecha_hora)
ORDER BY num_dia;


-- 3.5 Transacciones por hora del día (para detectar patrones)
SELECT 
    EXTRACT(HOUR FROM fecha_hora) AS hora,
    COUNT(*) AS num_transacciones,
    SUM(monto) AS monto_total
FROM transacciones
WHERE estado = 'completada'
GROUP BY EXTRACT(HOUR FROM fecha_hora)
ORDER BY hora;


-- 3.6 Transacciones rechazadas - análisis de motivos
SELECT 
    t.referencia,
    t.tipo_transaccion,
    t.monto,
    t.canal,
    t.descripcion,
    t.fecha_hora,
    c.nombre AS cliente
FROM transacciones t
JOIN cuentas cu ON t.id_cuenta = cu.id_cuenta
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE t.estado = 'rechazada'
ORDER BY t.fecha_hora DESC;


-- 3.7 Clientes con mayor volumen de transacciones
SELECT 
    c.nombre,
    c.tipo_cliente,
    c.segmento,
    COUNT(t.id_transaccion) AS num_transacciones,
    SUM(t.monto) AS monto_total,
    ROUND(AVG(t.monto), 2) AS monto_promedio
FROM clientes c
JOIN cuentas cu ON c.id_cliente = cu.id_cliente
JOIN transacciones t ON cu.id_cuenta = t.id_cuenta
WHERE t.estado = 'completada'
GROUP BY c.id_cliente, c.nombre, c.tipo_cliente, c.segmento
ORDER BY monto_total DESC
LIMIT 10;


-- ============================================
-- SECCIÓN 4: ANÁLISIS DE SEGURIDAD
-- ============================================

-- 4.1 Resumen de alertas por tipo
SELECT 
    tipo_alerta,
    COUNT(*) AS total_alertas,
    SUM(CASE WHEN estado = 'pendiente' THEN 1 ELSE 0 END) AS pendientes,
    SUM(CASE WHEN estado = 'investigando' THEN 1 ELSE 0 END) AS investigando,
    SUM(CASE WHEN estado = 'resuelto_confirmado' THEN 1 ELSE 0 END) AS fraudes_confirmados,
    SUM(CASE WHEN estado = 'resuelto_falso_positivo' THEN 1 ELSE 0 END) AS falsos_positivos
FROM alertas_seguridad
GROUP BY tipo_alerta
ORDER BY total_alertas DESC;


-- 4.2 Alertas por nivel de riesgo
SELECT 
    nivel_riesgo,
    COUNT(*) AS total_alertas,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM alertas_seguridad
GROUP BY nivel_riesgo
ORDER BY 
    CASE nivel_riesgo 
        WHEN 'critico' THEN 1 
        WHEN 'alto' THEN 2 
        WHEN 'medio' THEN 3 
        WHEN 'bajo' THEN 4 
    END;


-- 4.3 Tasa de resolución de alertas
SELECT 
    COUNT(*) AS total_alertas,
    SUM(CASE WHEN estado IN ('resuelto_confirmado', 'resuelto_falso_positivo') THEN 1 ELSE 0 END) AS resueltas,
    SUM(CASE WHEN estado IN ('pendiente', 'investigando') THEN 1 ELSE 0 END) AS abiertas,
    ROUND(
        SUM(CASE WHEN estado IN ('resuelto_confirmado', 'resuelto_falso_positivo') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS tasa_resolucion_pct
FROM alertas_seguridad;


-- 4.4 Tasa de falsos positivos vs fraudes confirmados
SELECT 
    SUM(CASE WHEN estado = 'resuelto_confirmado' THEN 1 ELSE 0 END) AS fraudes_confirmados,
    SUM(CASE WHEN estado = 'resuelto_falso_positivo' THEN 1 ELSE 0 END) AS falsos_positivos,
    ROUND(
        SUM(CASE WHEN estado = 'resuelto_confirmado' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN estado IN ('resuelto_confirmado', 'resuelto_falso_positivo') THEN 1 ELSE 0 END), 0),
        2
    ) AS tasa_fraude_real_pct
FROM alertas_seguridad;


-- 4.5 Tiempo promedio de resolución de alertas
SELECT 
    tipo_alerta,
    COUNT(*) AS alertas_resueltas,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (fecha_resolucion - fecha_hora)) / 3600),
        2
    ) AS tiempo_promedio_horas
FROM alertas_seguridad
WHERE fecha_resolucion IS NOT NULL
GROUP BY tipo_alerta
ORDER BY tiempo_promedio_horas DESC;


-- 4.6 Alertas pendientes de revisión (prioridad)
SELECT 
    a.id_alerta,
    a.tipo_alerta,
    a.nivel_riesgo,
    a.descripcion,
    a.fecha_hora,
    c.nombre AS cliente,
    cu.numero_cuenta
FROM alertas_seguridad a
JOIN cuentas cu ON a.id_cuenta = cu.id_cuenta
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE a.estado IN ('pendiente', 'investigando')
ORDER BY 
    CASE a.nivel_riesgo 
        WHEN 'critico' THEN 1 
        WHEN 'alto' THEN 2 
        WHEN 'medio' THEN 3 
        WHEN 'bajo' THEN 4 
    END,
    a.fecha_hora;


-- 4.7 Rendimiento de analistas de seguridad
SELECT 
    usuario_revisor,
    COUNT(*) AS alertas_revisadas,
    SUM(CASE WHEN estado = 'resuelto_confirmado' THEN 1 ELSE 0 END) AS fraudes_detectados,
    SUM(CASE WHEN estado = 'resuelto_falso_positivo' THEN 1 ELSE 0 END) AS falsos_positivos,
    ROUND(AVG(EXTRACT(EPOCH FROM (fecha_resolucion - fecha_hora)) / 3600), 2) AS tiempo_promedio_horas
FROM alertas_seguridad
WHERE usuario_revisor IS NOT NULL AND fecha_resolucion IS NOT NULL
GROUP BY usuario_revisor
ORDER BY alertas_revisadas DESC;


-- ============================================
-- SECCIÓN 5: DETECCIÓN DE PATRONES SOSPECHOSOS
-- ============================================

-- 5.1 Transacciones en horario inusual (entre 12 AM y 5 AM)
SELECT 
    t.id_transaccion,
    t.tipo_transaccion,
    t.monto,
    t.fecha_hora,
    t.canal,
    c.nombre AS cliente,
    cu.numero_cuenta
FROM transacciones t
JOIN cuentas cu ON t.id_cuenta = cu.id_cuenta
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE EXTRACT(HOUR FROM t.fecha_hora) BETWEEN 0 AND 5
    AND t.estado = 'completada'
ORDER BY t.monto DESC;


-- 5.2 Transacciones con montos inusualmente altos (> 2 desviaciones estándar)
WITH stats AS (
    SELECT 
        AVG(monto) AS promedio,
        STDDEV(monto) AS desviacion
    FROM transacciones
    WHERE estado = 'completada'
)
SELECT 
    t.id_transaccion,
    t.tipo_transaccion,
    t.monto,
    t.fecha_hora,
    c.nombre AS cliente,
    ROUND((t.monto - s.promedio) / s.desviacion, 2) AS z_score
FROM transacciones t
JOIN cuentas cu ON t.id_cuenta = cu.id_cuenta
JOIN clientes c ON cu.id_cliente = c.id_cliente
CROSS JOIN stats s
WHERE t.estado = 'completada'
    AND t.monto > (s.promedio + 2 * s.desviacion)
ORDER BY t.monto DESC;


-- 5.3 Cuentas con múltiples transacciones rechazadas
SELECT 
    cu.numero_cuenta,
    c.nombre AS cliente,
    COUNT(*) AS transacciones_rechazadas,
    STRING_AGG(t.descripcion, '; ') AS motivos
FROM transacciones t
JOIN cuentas cu ON t.id_cuenta = cu.id_cuenta
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE t.estado = 'rechazada'
GROUP BY cu.numero_cuenta, c.nombre
HAVING COUNT(*) >= 1
ORDER BY transacciones_rechazadas DESC;


-- 5.4 Concentración de transacciones por cliente (posible lavado)
SELECT 
    c.nombre,
    c.tipo_cliente,
    COUNT(t.id_transaccion) AS num_transacciones,
    SUM(t.monto) AS monto_total,
    COUNT(DISTINCT DATE(t.fecha_hora)) AS dias_activos,
    ROUND(SUM(t.monto) / COUNT(DISTINCT DATE(t.fecha_hora)), 2) AS promedio_diario
FROM clientes c
JOIN cuentas cu ON c.id_cliente = cu.id_cliente
JOIN transacciones t ON cu.id_cuenta = t.id_cuenta
WHERE t.estado = 'completada'
    AND t.fecha_hora >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.id_cliente, c.nombre, c.tipo_cliente
HAVING COUNT(t.id_transaccion) > 5
ORDER BY promedio_diario DESC;


-- ============================================
-- SECCIÓN 6: QUERIES PARA DASHBOARD/TABLEAU
-- ============================================

-- 6.1 Vista resumen para KPIs principales
SELECT 
    (SELECT COUNT(*) FROM clientes WHERE activo = TRUE) AS total_clientes_activos,
    (SELECT COUNT(*) FROM cuentas WHERE estado = 'activa') AS total_cuentas_activas,
    (SELECT SUM(saldo_actual) FROM cuentas WHERE estado = 'activa' AND moneda = 'GTQ') AS saldo_total_gtq,
    (SELECT COUNT(*) FROM transacciones WHERE estado = 'completada' AND fecha_hora >= CURRENT_DATE - INTERVAL '30 days') AS transacciones_ultimo_mes,
    (SELECT COUNT(*) FROM alertas_seguridad WHERE estado IN ('pendiente', 'investigando')) AS alertas_pendientes;


-- 6.2 Datos para gráfico de transacciones por canal y mes
SELECT 
    TO_CHAR(fecha_hora, 'YYYY-MM') AS mes,
    canal,
    COUNT(*) AS num_transacciones,
    SUM(monto) AS monto_total
FROM transacciones
WHERE estado = 'completada'
GROUP BY TO_CHAR(fecha_hora, 'YYYY-MM'), canal
ORDER BY mes, canal;


-- 6.3 Datos para mapa de calor de alertas por tipo y nivel
SELECT 
    tipo_alerta,
    nivel_riesgo,
    COUNT(*) AS total
FROM alertas_seguridad
GROUP BY tipo_alerta, nivel_riesgo
ORDER BY tipo_alerta, nivel_riesgo;


-- 6.4 Evolución de alertas por semana
SELECT 
    DATE_TRUNC('week', fecha_hora) AS semana,
    COUNT(*) AS total_alertas,
    SUM(CASE WHEN estado = 'resuelto_confirmado' THEN 1 ELSE 0 END) AS fraudes
FROM alertas_seguridad
GROUP BY DATE_TRUNC('week', fecha_hora)
ORDER BY semana;
