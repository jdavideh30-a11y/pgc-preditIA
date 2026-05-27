# Plataforma de Predicción de Partidos con IA
## Estructura del Proyecto

```
prediccion_partidos/
├── backend/          → Django REST API + Modelos de IA
├── frontend/         → App Flutter (móvil + web)
└── docs/             → Documentación del proyecto
```

## Requisitos
- Python 3.11+
- Flutter 3.x
- Docker (opcional para despliegue)

## Inicio Rápido

### Backend (Django)
```bash
cd backend
python -m venv venv
source venv/bin/activate   # Linux/Mac
venv\Scripts\activate      # Windows
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run                # móvil/emulador
flutter run -d chrome      # web
```
