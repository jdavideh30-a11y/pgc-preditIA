from rest_framework import generics, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from django.contrib.auth.models import User
from .models import EventoDeportivo, Prediccion, SimulacionApuesta
from .serializers import (RegistroUsuarioSerializer, UsuarioSerializer,
                           EventoDeportivoSerializer, PrediccionSerializer,
                           SimulacionApuestaSerializer)
from .ia_service import predecir_partido, calcular_cuota
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
 
 
# RF-01: Registro de usuarios
class RegistroUsuarioView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegistroUsuarioSerializer
    permission_classes = [permissions.AllowAny]
 
 
# RF-02: Perfil del usuario autenticado
@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def perfil_usuario(request):
    serializer = UsuarioSerializer(request.user)
    return Response(serializer.data)
 
 
# RF-03: Visualizacion de eventos deportivos
class EventoListView(generics.ListAPIView):
    serializer_class = EventoDeportivoSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
 
    def get_queryset(self):
        qs = EventoDeportivo.objects.all()
        deporte = self.request.query_params.get('deporte')
        estado = self.request.query_params.get('estado')
        if deporte:
            qs = qs.filter(deporte=deporte)
        if estado:
            qs = qs.filter(estado=estado)
        return qs
 
 
class EventoDetailView(generics.RetrieveAPIView):
    queryset = EventoDeportivo.objects.all()
    serializer_class = EventoDeportivoSerializer
 
 
# RF-04: Generacion de predicciones con IA
@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def generar_prediccion(request, evento_id):
    try:
        evento = EventoDeportivo.objects.get(pk=evento_id)
    except EventoDeportivo.DoesNotExist:
        return Response({'error': 'Evento no encontrado'}, status=404)
 
    if Prediccion.objects.filter(usuario=request.user, evento=evento).exists():
        pred = Prediccion.objects.get(usuario=request.user, evento=evento)
        return Response(PrediccionSerializer(pred).data)
 
    resultado_ia = predecir_partido(evento.equipo_local, evento.equipo_visitante, evento.deporte)
    pred = Prediccion.objects.create(usuario=request.user, evento=evento, **resultado_ia)
    return Response(PrediccionSerializer(pred).data, status=201)
 
 
# RF-05: Visualizacion de resultados
class PrediccionDetailView(generics.RetrieveAPIView):
    serializer_class = PrediccionSerializer
    permission_classes = [permissions.IsAuthenticated]
 
    def get_queryset(self):
        return Prediccion.objects.filter(usuario=self.request.user)
 
 
# RF-06: Historial de predicciones
class HistorialPrediccionesView(generics.ListAPIView):
    serializer_class = PrediccionSerializer
    permission_classes = [permissions.IsAuthenticated]
 
    def get_queryset(self):
        qs = Prediccion.objects.filter(usuario=self.request.user)
        estado = self.request.query_params.get('estado')
        if estado:
            qs = qs.filter(evento__estado=estado)
        return qs
 
 
# RF-07: Simulacion de apuestas
@api_view(['POST'])
@permission_classes([permissions.IsAuthenticated])
def simular_apuesta(request, prediccion_id):
    try:
        prediccion = Prediccion.objects.get(pk=prediccion_id, usuario=request.user)
    except Prediccion.DoesNotExist:
        return Response({'error': 'Prediccion no encontrada'}, status=404)
 
    monto = float(request.data.get('monto_virtual', 0))
    resultado_sel = request.data.get('resultado_seleccionado', 'local')
 
    if monto <= 0:
        return Response({'error': 'El monto debe ser mayor a 0'}, status=400)
 
    prob_map = {
        'local': prediccion.probabilidad_local,
        'empate': prediccion.probabilidad_empate,
        'visitante': prediccion.probabilidad_visitante,
    }
    cuota = calcular_cuota(prob_map.get(resultado_sel, 0.33))
    ganancia = round(monto * cuota, 2)
 
    sim = SimulacionApuesta.objects.create(
        usuario=request.user,
        prediccion=prediccion,
        monto_virtual=monto,
        resultado_seleccionado=resultado_sel,
        cuota=cuota,
        ganancia_estimada=ganancia,
    )
    return Response({
        **SimulacionApuestaSerializer(sim).data,
        'advertencia': 'Esta es una simulacion virtual. No involucra dinero real.',
    }, status=201)
 
 
# RF-08: Chat con IA usando Groq
@csrf_exempt
def chat_ia(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Metodo no permitido'}, status=405)
    try:
        data = json.loads(request.body)
        messages = data.get('messages', [])
 
        from groq import Groq
        client = Groq(api_key="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")
 
        completion = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": "Eres un asistente experto en futbol. Responde siempre en espanol. Se amigable y apasionado."},
                *messages
            ],
            max_tokens=1024,
        )
        reply = completion.choices[0].message.content
        return JsonResponse({'reply': reply})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)