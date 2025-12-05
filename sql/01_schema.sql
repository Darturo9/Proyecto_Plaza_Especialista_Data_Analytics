
-- 1. TABLA CLIENTES
-- Almacena información base de los clientes del banco
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    dpi VARCHAR(13) UNIQUE NOT NULL,
    tipo_cliente VARCHAR(20) CHECK (tipo_cliente IN ('individual', 'empresarial')),
    segmento VARCHAR(20) CHECK (segmento IN ('basico', 'preferente', 'premium')),
    fecha_apertura DATE NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(15),
    departamento VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 2. TABLA CUENTAS
-- Productos bancarios asociados a cada cliente
CREATE TABLE cuentas (
    id_cuenta SERIAL PRIMARY KEY,
    id_cliente INTEGER REFERENCES clientes(id_cliente),
    numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
    tipo_cuenta VARCHAR(30) CHECK (tipo_cuenta IN ('ahorro', 'monetaria', 'deposito_plazo', 'planilla')),
    moneda VARCHAR(3) CHECK (moneda IN ('GTQ', 'USD')),
    saldo_actual DECIMAL(15,2) DEFAULT 0,
    fecha_apertura DATE NOT NULL,
    estado VARCHAR(15) CHECK (estado IN ('activa', 'inactiva', 'bloqueada')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. TABLA TRANSACCIONES
-- Registro de todos los movimientos financieros
CREATE TABLE transacciones (
    id_transaccion SERIAL PRIMARY KEY,
    id_cuenta INTEGER REFERENCES cuentas(id_cuenta),
    tipo_transaccion VARCHAR(20) CHECK (tipo_transaccion IN ('deposito', 'retiro', 'transferencia_in', 'transferencia_out', 'pago_servicios', 'compra_pos')),
    monto DECIMAL(15,2) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    canal VARCHAR(20) CHECK (canal IN ('agencia', 'atm', 'banca_en_linea', 'app_movil', 'pos')),
    descripcion VARCHAR(200),
    referencia VARCHAR(50),
    estado VARCHAR(15) CHECK (estado IN ('completada', 'pendiente', 'rechazada')),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. TABLA ALERTAS DE SEGURIDAD
-- Sistema de detección de actividades sospechosas
CREATE TABLE alertas_seguridad (
    id_alerta SERIAL PRIMARY KEY,
    id_cuenta INTEGER REFERENCES cuentas(id_cuenta),
    id_transaccion INTEGER REFERENCES transacciones(id_transaccion),
    tipo_alerta VARCHAR(50) CHECK (tipo_alerta IN (
        'monto_inusual', 
        'ubicacion_sospechosa', 
        'multiples_intentos_fallidos',
        'horario_inusual',
        'cambio_dispositivo',
        'transaccion_duplicada'
    )),
    nivel_riesgo VARCHAR(10) CHECK (nivel_riesgo IN ('bajo', 'medio', 'alto', 'critico')),
    descripcion TEXT,
    fecha_hora TIMESTAMP NOT NULL,
    estado VARCHAR(30) CHECK (estado IN ('pendiente', 'investigando', 'resuelto_falso_positivo', 'resuelto_confirmado')),
    usuario_revisor VARCHAR(50),
    fecha_resolucion TIMESTAMP,
    notas TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- =============================================

CREATE INDEX idx_transacciones_fecha ON transacciones(fecha_hora);
CREATE INDEX idx_transacciones_cuenta ON transacciones(id_cuenta);
CREATE INDEX idx_alertas_fecha ON alertas_seguridad(fecha_hora);
CREATE INDEX idx_alertas_nivel ON alertas_seguridad(nivel_riesgo);
CREATE INDEX idx_cuentas_cliente ON cuentas(id_cliente);

-- =============================================
-- DOCUMENTACIÓN DE TABLAS
-- =============================================

COMMENT ON TABLE clientes IS 'Información base de clientes del banco';
COMMENT ON TABLE cuentas IS 'Cuentas bancarias asociadas a clientes';
COMMENT ON TABLE transacciones IS 'Registro de todas las transacciones';
COMMENT ON TABLE alertas_seguridad IS 'Alertas generadas por el sistema de seguridad para revisión';
