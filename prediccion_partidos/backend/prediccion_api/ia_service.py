"""
Servicio de Inteligencia Artificial para prediccion de partidos.
Usa scikit-learn con Random Forest como modelo principal.
"""
import numpy as np
import os


def predecir_partido(equipo_local: str, equipo_visitante: str, deporte: str = 'futbol') -> dict:
    """
    Genera prediccion de un partido usando el modelo de IA.
    Retorna probabilidades para local, empate y visitante.
    """
    # Simulacion de modelo IA (en produccion cargar modelo real con joblib)
    # En produccion: modelo = joblib.load(settings.ML_MODELS_DIR / 'modelo_futbol.pkl')
    np.random.seed(hash(f"{equipo_local}{equipo_visitante}") % 2**32)
    
    raw = np.random.dirichlet([3, 2, 2.5])  # Prior: ventaja local
    prob_local = round(float(raw[0]), 4)
    prob_empate = round(float(raw[1]), 4)
    prob_visitante = round(float(raw[2]), 4)

    resultado = max(
        [('local', prob_local), ('empate', prob_empate), ('visitante', prob_visitante)],
        key=lambda x: x[1]
    )

    return {
        'resultado_predicho': resultado[0],
        'probabilidad_local': prob_local,
        'probabilidad_empate': prob_empate,
        'probabilidad_visitante': prob_visitante,
        'confianza': round(resultado[1], 4),
    }


def calcular_cuota(probabilidad: float) -> float:
    """Convierte probabilidad a cuota decimal."""
    if probabilidad <= 0:
        return 99.0
    return round(1 / probabilidad, 2)
