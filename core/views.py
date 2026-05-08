from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse
from django.db.models import Count, Q, Sum
from django.utils import timezone
from .models import (
    Especie, Animal, Recinto, Alocacao, Triagem,
    Registro, MedicacaoAdministrada, Exame, Restricao, Risco, Funcionario,
)
from .forms import RegistroForm, MedicacaoForm, ExameForm


# ──────────────────────────────────────────
# Contexto global mock (usuário fictício)
# ──────────────────────────────────────────

def _mock_user_context():
    """Retorna contexto com dados do usuário mock."""
    return {
        'user_name': 'Dr. Marina Silva',
        'user_role': 'Veterinária',
        'user_initials': 'MS',
    }


# ──────────────────────────────────────────
# Home
# ──────────────────────────────────────────

def home(request):
    """Tela inicial com cards de funcionalidades."""
    context = _mock_user_context()
    context['total_animais'] = Animal.objects.count()
    context['total_especies'] = Especie.objects.count()
    context['total_recintos'] = Recinto.objects.count()
    return render(request, 'home.html', context)


# ──────────────────────────────────────────
# Dashboard de Conservação
# ──────────────────────────────────────────

def dashboard_conservacao(request):
    """Dashboard analítico com indicadores de conservação."""
    context = _mock_user_context()

    # KPIs
    total_animais = Animal.objects.count()
    total_especies = Especie.objects.count()

    especies_ameacadas = Especie.objects.filter(
        status_conservacao__in=['VU', 'EN', 'CR', 'EW', 'EX']
    ).count()
    pct_ameacadas = round((especies_ameacadas / total_especies * 100), 1) if total_especies else 0

    recintos_alerta = Recinto.objects.filter(qnt_animais__gt=0).extra(
        where=["qnt_animais >= cap_maxima * 0.75"]
    ).count() if False else 0  # Fallback below
    # Calcular recintos em alerta via Python
    recintos = Recinto.objects.all()
    recintos_alerta = sum(1 for r in recintos if r.percentual_ocupacao >= 75)

    context['total_animais'] = total_animais
    context['total_especies'] = total_especies
    context['especies_ameacadas'] = especies_ameacadas
    context['pct_ameacadas'] = pct_ameacadas
    context['recintos_alerta'] = recintos_alerta

    # Distribuição por status de conservação (para gráfico donut)
    status_dist = list(
        Especie.objects.values('status_conservacao')
        .annotate(count=Count('id'))
        .order_by('status_conservacao')
    )
    # Mapear labels
    status_labels = dict(Especie.STATUS_CONSERVACAO_CHOICES)
    for item in status_dist:
        item['label'] = status_labels.get(item['status_conservacao'], item['status_conservacao'])
    context['status_distribuicao'] = status_dist

    # Distribuição por grupo taxonômico
    grupo_dist = list(
        Especie.objects.values('grupo_taxonomico')
        .annotate(count=Sum('quantidade'))
        .order_by('-count')
    )
    context['grupo_distribuicao'] = grupo_dist

    # Distribuição por sexo
    sexo_dist = list(
        Animal.objects.values('sexo')
        .annotate(count=Count('nro_reg'))
        .order_by('sexo')
    )
    sexo_labels = dict(Animal.SEXO_CHOICES)
    for item in sexo_dist:
        item['label'] = sexo_labels.get(item['sexo'], item['sexo'])
    context['sexo_distribuicao'] = sexo_dist

    # Capacidade dos recintos
    recintos_data = []
    for r in recintos:
        recintos_data.append({
            'nome': r.nome,
            'gefau': r.recinto_gefau,
            'ocupacao': r.qnt_animais,
            'capacidade': r.cap_maxima,
            'percentual': r.percentual_ocupacao,
            'status': r.status_ocupacao,
        })
    context['recintos_capacidade'] = sorted(recintos_data, key=lambda x: -x['percentual'])

    # Últimas alocações
    ultimas_alocacoes = Alocacao.objects.select_related('animal', 'recinto')[:5]
    context['ultimas_alocacoes'] = ultimas_alocacoes

    return render(request, 'dashboard.html', context)


# ──────────────────────────────────────────
# Prontuário Digital
# ──────────────────────────────────────────

def prontuario_selecao(request):
    """Tela de seleção de animal para o prontuário."""
    context = _mock_user_context()
    query = request.GET.get('q', '')
    animais = Animal.objects.select_related('especie').all()

    if query:
        animais = animais.filter(
            Q(apelido__icontains=query) |
            Q(nro_reg__icontains=query) |
            Q(especie__nome_comum__icontains=query) |
            Q(nro_gefau__icontains=query)
        )

    context['animais'] = animais
    context['query'] = query
    return render(request, 'prontuario/selecao.html', context)


def prontuario_detalhes(request, nro_reg):
    """Dashboard individual do animal com histórico completo."""
    context = _mock_user_context()
    animal = get_object_or_404(
        Animal.objects.select_related('especie'), nro_reg=nro_reg
    )
    context['animal'] = animal
    context['recinto_atual'] = animal.recinto_atual

    # Triagens (evolução de peso e score)
    triagens = list(
        Triagem.objects.filter(animal=animal)
        .order_by('data')
        .values('data', 'peso_ao_chegar', 'score_corporal', 'gravidade_veterinaria')
    )
    context['triagens'] = triagens

    # Converter para dados de gráfico
    context['triagem_datas'] = [t['data'].isoformat() for t in triagens]
    context['triagem_pesos'] = [float(t['peso_ao_chegar']) if t['peso_ao_chegar'] else None for t in triagens]
    context['triagem_scores'] = [float(t['score_corporal']) if t['score_corporal'] else None for t in triagens]

    # Registros clínicos (timeline)
    registros = Registro.objects.filter(animal=animal).select_related('funcionario').prefetch_related(
        'medicacoes', 'exames'
    )
    context['registros'] = registros

    # Medicações recentes
    medicacoes = MedicacaoAdministrada.objects.filter(
        registro__animal=animal
    ).select_related('registro').order_by('-registro__data')[:10]
    context['medicacoes'] = medicacoes

    # Exames recentes
    exames = Exame.objects.filter(
        registro__animal=animal
    ).select_related('registro').order_by('-data')[:10]
    context['exames'] = exames

    # Alertas (restrições e riscos ativos)
    restricoes = Restricao.objects.filter(animal=animal).order_by('-data')[:5]
    riscos = Risco.objects.filter(animal=animal).order_by('-data')[:5]
    context['restricoes'] = restricoes
    context['riscos'] = riscos

    return render(request, 'prontuario/detalhes.html', context)


def prontuario_novo_registro(request, nro_reg):
    """Formulário de novo registro clínico/biológico."""
    context = _mock_user_context()
    animal = get_object_or_404(Animal, nro_reg=nro_reg)
    context['animal'] = animal

    if request.method == 'POST':
        form = RegistroForm(request.POST, request.FILES)
        if form.is_valid():
            registro = form.save()

            # Processar medicações dinâmicas
            med_count = int(request.POST.get('med_count', 0))
            for i in range(med_count):
                medicamento = request.POST.get(f'med_medicamento_{i}', '').strip()
                dose = request.POST.get(f'med_dose_{i}', '').strip()
                if medicamento:
                    MedicacaoAdministrada.objects.create(
                        registro=registro,
                        medicamento=medicamento,
                        dose_pv=dose,
                    )

            # Processar exames dinâmicos
            exam_count = int(request.POST.get('exam_count', 0))
            for i in range(exam_count):
                tipo = request.POST.get(f'exam_tipo_{i}', '').strip()
                data_exam = request.POST.get(f'exam_data_{i}', '').strip()
                resultado = request.POST.get(f'exam_resultado_{i}', '').strip()
                obs = request.POST.get(f'exam_obs_{i}', '').strip()
                if tipo and data_exam:
                    Exame.objects.create(
                        registro=registro,
                        data=data_exam,
                        tipo=tipo,
                        resultado=resultado,
                        observacao=obs,
                    )

            return redirect('prontuario_detalhes', nro_reg=animal.nro_reg)
    else:
        form = RegistroForm(initial={'animal': animal, 'data': timezone.now().date(), 'data_hora': timezone.now()})

    context['form'] = form
    context['funcionarios'] = Funcionario.objects.all()
    return render(request, 'prontuario/registro_form.html', context)


# ──────────────────────────────────────────
# Recintos
# ──────────────────────────────────────────

def recintos_selecao(request):
    """Tela de seleção de recinto."""
    context = _mock_user_context()
    query = request.GET.get('q', '')
    recintos = Recinto.objects.all()

    if query:
        recintos = recintos.filter(
            Q(nome__icontains=query) |
            Q(recinto_gefau__icontains=query)
        )

    context['recintos'] = recintos
    context['query'] = query
    return render(request, 'recintos/selecao.html', context)


def recinto_detalhes(request, recinto_gefau):
    """Dashboard detalhado de um recinto."""
    context = _mock_user_context()
    recinto = get_object_or_404(Recinto, recinto_gefau=recinto_gefau)
    context['recinto'] = recinto

    # Animais atualmente alocados (sem data de saída)
    alocacoes_atuais = Alocacao.objects.filter(
        recinto=recinto, data_saida__isnull=True
    ).select_related('animal', 'animal__especie')
    context['alocacoes_atuais'] = alocacoes_atuais

    # Espécies presentes
    especies_ids = alocacoes_atuais.values_list('animal__especie', flat=True).distinct()
    especies_presentes = Especie.objects.filter(id__in=especies_ids)
    context['especies_presentes'] = especies_presentes

    # Histórico de alocações
    historico = Alocacao.objects.filter(
        recinto=recinto
    ).select_related('animal', 'animal__especie').order_by('-data_entrada')[:20]
    context['historico_alocacoes'] = historico

    return render(request, 'recintos/detalhes.html', context)


# ──────────────────────────────────────────
# API endpoints (para gráficos via fetch)
# ──────────────────────────────────────────

def api_dashboard_data(request):
    """Retorna dados do dashboard em JSON para Chart.js."""
    # Status de conservação
    status_dist = list(
        Especie.objects.values('status_conservacao')
        .annotate(count=Count('id'))
        .order_by('status_conservacao')
    )
    status_labels = dict(Especie.STATUS_CONSERVACAO_CHOICES)
    for item in status_dist:
        item['label'] = status_labels.get(item['status_conservacao'], '')

    # Grupo taxonômico
    grupo_dist = list(
        Especie.objects.values('grupo_taxonomico')
        .annotate(count=Sum('quantidade'))
        .order_by('-count')
    )

    # Sexo
    sexo_dist = list(
        Animal.objects.values('sexo')
        .annotate(count=Count('nro_reg'))
    )
    sexo_labels = dict(Animal.SEXO_CHOICES)
    for item in sexo_dist:
        item['label'] = sexo_labels.get(item['sexo'], '')

    return JsonResponse({
        'status_conservacao': status_dist,
        'grupo_taxonomico': grupo_dist,
        'sexo': sexo_dist,
    })
