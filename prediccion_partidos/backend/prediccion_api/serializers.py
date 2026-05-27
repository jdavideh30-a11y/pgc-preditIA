from rest_framework import serializers
from django.contrib.auth.models import User
from .models import EventoDeportivo, Prediccion, SimulacionApuesta


class RegistroUsuarioSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'first_name', 'last_name']

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user


class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class EventoDeportivoSerializer(serializers.ModelSerializer):
    class Meta:
        model = EventoDeportivo
        fields = '__all__'


class PrediccionSerializer(serializers.ModelSerializer):
    evento_detalle = EventoDeportivoSerializer(source='evento', read_only=True)

    class Meta:
        model = Prediccion
        fields = '__all__'
        read_only_fields = ['usuario', 'resultado_predicho', 'probabilidad_local',
                            'probabilidad_empate', 'probabilidad_visitante',
                            'confianza', 'acerto']


class SimulacionApuestaSerializer(serializers.ModelSerializer):
    class Meta:
        model = SimulacionApuesta
        fields = '__all__'
        read_only_fields = ['usuario', 'cuota', 'ganancia_estimada']
