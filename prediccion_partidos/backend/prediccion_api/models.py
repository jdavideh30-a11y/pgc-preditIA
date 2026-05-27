from django.db import models
from django.contrib.auth.models import User


class EventoDeportivo(models.Model):
    DEPORTES = [('futbol', 'Futbol'), ('baloncesto', 'Baloncesto'), ('tenis', 'Tenis')]
    ESTADOS = [('pendiente', 'Pendiente'), ('en_vivo', 'En Vivo'), ('finalizado', 'Finalizado')]

    deporte = models.CharField(max_length=20, choices=DEPORTES, default='futbol')
    equipo_local = models.CharField(max_length=100)
    equipo_visitante = models.CharField(max_length=100)
    fecha = models.DateTimeField()
    estado = models.CharField(max_length=20, choices=ESTADOS, default='pendiente')
    resultado_real = models.CharField(max_length=50, blank=True, null=True)
    liga = models.CharField(max_length=100, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.equipo_local} vs {self.equipo_visitante}"

    class Meta:
        ordering = ['-fecha']


class Prediccion(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='predicciones')
    evento = models.ForeignKey(EventoDeportivo, on_delete=models.CASCADE, related_name='predicciones')
    resultado_predicho = models.CharField(max_length=50)
    probabilidad_local = models.FloatField(default=0.0)
    probabilidad_empate = models.FloatField(default=0.0)
    probabilidad_visitante = models.FloatField(default=0.0)
    confianza = models.FloatField(default=0.0)
    acerto = models.BooleanField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ['usuario', 'evento']


class SimulacionApuesta(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='simulaciones')
    prediccion = models.ForeignKey(Prediccion, on_delete=models.CASCADE)
    monto_virtual = models.FloatField()
    resultado_seleccionado = models.CharField(max_length=20)
    cuota = models.FloatField()
    ganancia_estimada = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)
