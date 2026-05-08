from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),

    # Dashboard de Conservação
    path('dashboard/', views.dashboard_conservacao, name='dashboard'),

    # Prontuário Digital
    path('prontuario/', views.prontuario_selecao, name='prontuario_selecao'),
    path('prontuario/<str:nro_reg>/', views.prontuario_detalhes, name='prontuario_detalhes'),
    path('prontuario/<str:nro_reg>/novo-registro/', views.prontuario_novo_registro, name='prontuario_novo_registro'),

    # Recintos
    path('recintos/', views.recintos_selecao, name='recintos_selecao'),
    path('recintos/<str:recinto_gefau>/', views.recinto_detalhes, name='recinto_detalhes'),

    # API
    path('api/dashboard/', views.api_dashboard_data, name='api_dashboard'),
]
