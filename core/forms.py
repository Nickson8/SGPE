from django import forms
from .models import Registro, MedicacaoAdministrada, Exame


class RegistroForm(forms.ModelForm):
    """Formulário para criação de registro clínico/biológico."""

    class Meta:
        model = Registro
        fields = [
            'animal', 'data', 'data_hora', 'tipo_registro',
            'ocorrencia', 'detalhamento', 'tratamento',
            'anexo_laudo_saude', 'funcionario',
        ]
        widgets = {
            'data': forms.DateInput(attrs={'type': 'date'}),
            'data_hora': forms.DateTimeInput(attrs={'type': 'datetime-local'}),
            'ocorrencia': forms.Textarea(attrs={'rows': 3}),
            'detalhamento': forms.Textarea(attrs={'rows': 3}),
            'tratamento': forms.Textarea(attrs={'rows': 2}),
        }


class MedicacaoForm(forms.ModelForm):
    """Formulário para medicação administrada."""

    class Meta:
        model = MedicacaoAdministrada
        fields = ['medicamento', 'dose_pv']


class ExameForm(forms.ModelForm):
    """Formulário para exame realizado."""

    class Meta:
        model = Exame
        fields = ['data', 'tipo', 'resultado', 'observacao']
        widgets = {
            'data': forms.DateInput(attrs={'type': 'date'}),
            'resultado': forms.Textarea(attrs={'rows': 2}),
            'observacao': forms.Textarea(attrs={'rows': 2}),
        }
