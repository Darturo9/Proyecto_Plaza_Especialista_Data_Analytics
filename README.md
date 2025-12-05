# Banco Analytics - Analisis de Datos Bancarios

Proyecto de analisis de datos bancarios desarrollado como ejercicio practico para el puesto de **Especialista Data Analytics y Proyectos** en Banco Industrial, Guatemala.

## Descripcion del Proyecto

Sistema integral de analisis de transacciones bancarias y monitoreo de seguridad que incluye:

- Modelo de datos relacional para gestion de clientes, cuentas y transacciones
- Queries analiticos para extraccion de insights de negocio
- Scripts de Python para procesamiento y analisis de datos
- Dashboard interactivo en Tableau para visualizacion de metricas clave

## Tecnologias Utilizadas

| Tecnologia | Uso |
|------------|-----|
| **PostgreSQL** | Base de datos relacional (Supabase) |
| **SQL** | Modelado de datos, queries analiticos |
| **Python 3.12** | Analisis y procesamiento de datos |
| **Pandas** | Manipulacion de DataFrames |
| **Tableau Public** | Visualizacion y dashboards |

## Estructura del Proyecto

```
banco-analytics-project/
├── sql/
│   ├── 01_schema.sql            # Estructura de tablas
│   ├── 02_data.sql              # Datos de prueba
│   └── 03_queries_analiticos.sql # Consultas de analisis
├── python/
│   ├── analisis_banco.py        # Script principal de analisis
├── exports/
│   ├── transacciones_completo.csv
│   ├── alertas_seguridad.csv
│   └── clientes_resumen.csv
├── tableau/
│   └── dashboard_preview.png    # Preview del dashboard
└── README.md
```

## Modelo de Datos

El sistema cuenta con 4 tablas principales:

### Clientes
Informacion base de clientes del banco (individuales y empresariales).

### Cuentas
Productos bancarios: ahorro, monetaria, deposito a plazo, planilla.

### Transacciones
Registro de movimientos: depositos, retiros, transferencias, pagos, compras POS.

### Alertas de Seguridad
Sistema de deteccion de actividades sospechosas para la Subgerencia de Seguridad.

## Resultados del Analisis

### Distribucion de Clientes
- Premium: 38%
- Preferente: 34%
- Basico: 28%

### Transacciones por Canal
- Agencia: 40.1%
- Banca en linea: 19.1%
- POS: 14.8%
- App movil: 13.6%
- ATM: 12.3%

### Metricas de Seguridad
- Total alertas analizadas: 17
- Tasa de fraude real: 38.5%
- Alertas pendientes de revision: 4

## Dashboard

Vista interactiva del dashboard en Tableau Public:

[Ver Dashboard Completo](https://public.tableau.com/app/profile/danilo.giron/viz/ProyectoparalaplazadeDataAnalytics/DashboardGeneral)

El dashboard incluye:
- Tendencia mensual de transacciones
- Distribucion por canal
- Volumen por tipo de transaccion
- Monto por segmento de cliente

## Como Ejecutar el Proyecto

### Requisitos Previos
- Python 3.10+
- Cuenta en Supabase (o PostgreSQL local)
- Tableau Public (opcional, para visualizacion)

### Instalacion

1. Clonar el repositorio:
```bash
git clone https://github.com/Darturo9/Proyecto_Plaza_Especialista_Data_Analytics.git
cd Proyecto_Plaza_Especialista_Data_Analytics
```

2. Crear entorno virtual e instalar dependencias:
```bash
python -m venv .venv
source .venv/bin/activate  # En Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
# Editar .env con tus credenciales de Supabase
```

4. Ejecutar el script de analisis:
```bash
python analisis_banco.py
```

## Queries Destacados

### Transacciones en horario inusual (deteccion de fraude)
```sql
SELECT 
    t.id_transaccion,
    t.tipo_transaccion,
    t.monto,
    t.fecha_hora,
    c.nombre AS cliente
FROM transacciones t
JOIN cuentas cu ON t.id_cuenta = cu.id_cuenta
JOIN clientes c ON cu.id_cliente = c.id_cliente
WHERE EXTRACT(HOUR FROM t.fecha_hora) BETWEEN 0 AND 5
ORDER BY t.monto DESC;
```

### Clientes con mayor volumen de transacciones
```sql
SELECT 
    c.nombre,
    c.segmento,
    COUNT(t.id_transaccion) AS num_transacciones,
    SUM(t.monto) AS monto_total
FROM clientes c
JOIN cuentas cu ON c.id_cliente = cu.id_cliente
JOIN transacciones t ON cu.id_cuenta = t.id_cuenta
WHERE t.estado = 'completada'
GROUP BY c.id_cliente, c.nombre, c.segmento
ORDER BY monto_total DESC
LIMIT 10;
```

## Autor

**Danilo Arturo Giron**

- GitHub: [@Darturo9](https://github.com/Darturo9)
- LinkedIn: [Tu perfil de LinkedIn]

---

Proyecto desarrollado como parte del proceso de aplicacion para Especialista Data Analytics y Proyectos - Banco Industrial, Guatemala (Diciembre 2024).
