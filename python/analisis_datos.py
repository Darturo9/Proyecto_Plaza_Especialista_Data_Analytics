"""
==============================================
BANCO ANALYTICS - ANÁLISIS DE DATOS CON PYTHON
Proyecto: Especialista Data Analytics y Proyectos
Autor: Danilo Arturo
==============================================
"""

import os
import pandas as pd
from dotenv import load_dotenv
from supabase import create_client, Client

# Cargar variables de entorno
load_dotenv()

# Configuracion de Supabase
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Crear cliente de Supabase
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def cargar_datos():
    """Carga todas las tablas desde Supabase"""
    print("Cargando datos desde Supabase...")

    # Cargar cada tabla
    clientes = supabase.table("clientes").select("*").execute()
    cuentas = supabase.table("cuentas").select("*").execute()
    transacciones = supabase.table("transacciones").select("*").execute()
    alertas = supabase.table("alertas_seguridad").select("*").execute()

    # Convertir a DataFrames
    df_clientes = pd.DataFrame(clientes.data)
    df_cuentas = pd.DataFrame(cuentas.data)
    df_transacciones = pd.DataFrame(transacciones.data)
    df_alertas = pd.DataFrame(alertas.data)

    print(f"Clientes: {len(df_clientes)} registros")
    print(f"Cuentas: {len(df_cuentas)} registros")
    print(f"Transacciones: {len(df_transacciones)} registros")
    print(f"Alertas: {len(df_alertas)} registros")

    return df_clientes, df_cuentas, df_transacciones, df_alertas


def analisis_clientes(df_clientes):
    """Analisis de la base de clientes"""
    print("\n" + "=" * 50)
    print("ANALISIS DE CLIENTES")
    print("=" * 50)

    # Distribucion por segmento
    print("\nDistribucion por segmento:")
    segmentos = df_clientes['segmento'].value_counts()
    for seg, count in segmentos.items():
        pct = count / len(df_clientes) * 100
        print(f"   {seg}: {count} ({pct:.1f}%)")

    # Distribucion por tipo
    print("\nDistribucion por tipo de cliente:")
    tipos = df_clientes['tipo_cliente'].value_counts()
    for tipo, count in tipos.items():
        print(f"   {tipo}: {count}")

    # Top departamentos
    print("\nTop 5 departamentos:")
    deptos = df_clientes['departamento'].value_counts().head(5)
    for depto, count in deptos.items():
        print(f"   {depto}: {count}")


def analisis_transacciones(df_transacciones):
    """Analisis de transacciones"""
    print("\n" + "=" * 50)
    print("ANALISIS DE TRANSACCIONES")
    print("=" * 50)

    # Filtrar solo completadas
    completadas = df_transacciones[df_transacciones['estado'] == 'completada']

    # Volumen por tipo
    print("\nVolumen por tipo de transaccion:")
    por_tipo = completadas.groupby('tipo_transaccion')['monto'].agg(['count', 'sum'])
    por_tipo = por_tipo.sort_values('sum', ascending=False)
    for tipo, row in por_tipo.iterrows():
        print(f"   {tipo}: {int(row['count'])} transacciones, Q{row['sum']:,.2f}")

    # Por canal
    print("\nTransacciones por canal:")
    por_canal = completadas['canal'].value_counts()
    for canal, count in por_canal.items():
        pct = count / len(completadas) * 100
        print(f"   {canal}: {count} ({pct:.1f}%)")

    # Estadisticas de montos
    print("\nEstadisticas de montos:")
    print(f"   Monto promedio: Q{completadas['monto'].mean():,.2f}")
    print(f"   Monto maximo: Q{completadas['monto'].max():,.2f}")
    print(f"   Monto minimo: Q{completadas['monto'].min():,.2f}")

    # Transacciones rechazadas
    rechazadas = df_transacciones[df_transacciones['estado'] == 'rechazada']
    print(f"\nTransacciones rechazadas: {len(rechazadas)}")


def analisis_seguridad(df_alertas):
    """Analisis de alertas de seguridad"""
    print("\n" + "=" * 50)
    print("ANALISIS DE SEGURIDAD")
    print("=" * 50)

    # Por tipo de alerta
    print("\nAlertas por tipo:")
    por_tipo = df_alertas['tipo_alerta'].value_counts()
    for tipo, count in por_tipo.items():
        print(f"   {tipo}: {count}")

    # Por nivel de riesgo
    print("\nAlertas por nivel de riesgo:")
    por_nivel = df_alertas['nivel_riesgo'].value_counts()
    for nivel, count in por_nivel.items():
        print(f"   {nivel}: {count}")

    # Estado de resolucion
    print("\nEstado de alertas:")
    por_estado = df_alertas['estado'].value_counts()
    for estado, count in por_estado.items():
        print(f"   {estado}: {count}")

    # Tasa de fraude real
    resueltas = df_alertas[df_alertas['estado'].isin(['resuelto_confirmado', 'resuelto_falso_positivo'])]
    if len(resueltas) > 0:
        fraudes = len(resueltas[resueltas['estado'] == 'resuelto_confirmado'])
        tasa = fraudes / len(resueltas) * 100
        print(f"\nTasa de fraude real: {tasa:.1f}% ({fraudes} de {len(resueltas)} alertas resueltas)")


def exportar_para_tableau(df_clientes, df_cuentas, df_transacciones, df_alertas):
    """Exporta datos procesados para Tableau"""
    print("\n" + "=" * 50)
    print("EXPORTANDO DATOS PARA TABLEAU")
    print("=" * 50)

    # Crear carpeta de exports si no existe
    if not os.path.exists('exports'):
        os.makedirs('exports')

    # Dataset 1: Vista completa de transacciones con info de cliente
    df_trans_completo = df_transacciones.merge(
        df_cuentas[['id_cuenta', 'id_cliente', 'tipo_cuenta', 'moneda']],
        on='id_cuenta',
        how='left'
    ).merge(
        df_clientes[['id_cliente', 'nombre', 'tipo_cliente', 'segmento', 'departamento']],
        on='id_cliente',
        how='left'
    )
    df_trans_completo.to_csv('exports/transacciones_completo.csv', index=False)
    print("Exportado: exports/transacciones_completo.csv")

    # Dataset 2: Resumen de alertas
    df_alertas.to_csv('exports/alertas_seguridad.csv', index=False)
    print("Exportado: exports/alertas_seguridad.csv")

    # Dataset 3: Resumen de clientes con saldos
    saldos_cliente = df_cuentas.groupby('id_cliente').agg({
        'saldo_actual': 'sum',
        'id_cuenta': 'count'
    }).rename(columns={'id_cuenta': 'num_cuentas', 'saldo_actual': 'saldo_total'})

    df_clientes_resumen = df_clientes.merge(saldos_cliente, on='id_cliente', how='left')
    df_clientes_resumen.to_csv('exports/clientes_resumen.csv', index=False)
    print("Exportado: exports/clientes_resumen.csv")

    print("\nDatos exportados exitosamente!")


def main():
    """Funcion principal"""
    print("\n" + "=" * 50)
    print("BANCO ANALYTICS - ANALISIS DE DATOS")
    print("=" * 50)

    # Cargar datos
    df_clientes, df_cuentas, df_transacciones, df_alertas = cargar_datos()

    # Ejecutar analisis
    analisis_clientes(df_clientes)
    analisis_transacciones(df_transacciones)
    analisis_seguridad(df_alertas)

    # Exportar para Tableau
    exportar_para_tableau(df_clientes, df_cuentas, df_transacciones, df_alertas)


if __name__ == "__main__":
    main()
