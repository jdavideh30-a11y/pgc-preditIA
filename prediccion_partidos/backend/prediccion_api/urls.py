from django.urls import path
from . import views

urlpatterns = [
    # Autenticacion (RF-01, RF-02)
    path('registro/', views.RegistroUsuarioView.as_view(), name='registro'),
    path('perfil/', views.perfil_usuario, name='perfil'),

    # Eventos deportivos (RF-03)
    path('eventos/', views.EventoListView.as_view(), name='eventos-list'),
    path('eventos/<int:pk>/', views.EventoDetailView.as_view(), name='evento-detail'),

    # Predicciones IA (RF-04, RF-05)
    path('eventos/<int:evento_id>/predecir/', views.generar_prediccion, name='generar-prediccion'),
    path('predicciones/<int:pk>/', views.PrediccionDetailView.as_view(), name='prediccion-detail'),

    # Historial (RF-06)
    path('historial/', views.HistorialPrediccionesView.as_view(), name='historial'),

    # Simulacion apuestas (RF-07)
    path('predicciones/<int:prediccion_id>/simular/', views.simular_apuesta, name='simular-apuesta'),
]
