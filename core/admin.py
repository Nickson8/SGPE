from django.contrib import admin
from .models import (
    Especie, Animal, Recinto, Alocacao, Funcionario,
    Triagem, Registro, MedicacaoAdministrada, Exame,
    Restricao, Risco, Documento, Prole, Casal,
    ItemCardapio, DescricaoRotina, RegistroRotina,
)


class MedicacaoInline(admin.TabularInline):
    model = MedicacaoAdministrada
    extra = 1


class ExameInline(admin.TabularInline):
    model = Exame
    extra = 1


@admin.register(Especie)
class EspecieAdmin(admin.ModelAdmin):
    list_display = ['nome_comum', 'nome_cientifico', 'grupo_taxonomico', 'status_conservacao', 'quantidade']
    list_filter = ['grupo_taxonomico', 'status_conservacao']
    search_fields = ['nome_comum', 'nome_cientifico']


@admin.register(Animal)
class AnimalAdmin(admin.ModelAdmin):
    list_display = ['nro_reg', 'apelido', 'especie', 'sexo', 'plantel']
    list_filter = ['sexo', 'especie__grupo_taxonomico']
    search_fields = ['apelido', 'nro_reg', 'nro_gefau']


@admin.register(Recinto)
class RecintoAdmin(admin.ModelAdmin):
    list_display = ['recinto_gefau', 'nome', 'cap_maxima', 'qnt_animais', 'qnt_especies']
    search_fields = ['nome', 'recinto_gefau']


@admin.register(Alocacao)
class AlocacaoAdmin(admin.ModelAdmin):
    list_display = ['animal', 'recinto', 'data_entrada', 'data_saida']
    list_filter = ['recinto']


@admin.register(Funcionario)
class FuncionarioAdmin(admin.ModelAdmin):
    list_display = ['nome', 'funcao', 'telefone']


@admin.register(Triagem)
class TriagemAdmin(admin.ModelAdmin):
    list_display = ['animal', 'data', 'peso_ao_chegar', 'score_corporal']
    list_filter = ['data']


@admin.register(Registro)
class RegistroAdmin(admin.ModelAdmin):
    list_display = ['animal', 'data', 'tipo_registro', 'ocorrencia', 'funcionario']
    list_filter = ['tipo_registro', 'data']
    inlines = [MedicacaoInline, ExameInline]


@admin.register(Restricao)
class RestricaoAdmin(admin.ModelAdmin):
    list_display = ['animal', 'data', 'restricao']


@admin.register(Risco)
class RiscoAdmin(admin.ModelAdmin):
    list_display = ['animal', 'data', 'risco']


admin.site.register(MedicacaoAdministrada)
admin.site.register(Exame)
admin.site.register(Documento)
admin.site.register(Prole)
admin.site.register(Casal)
admin.site.register(ItemCardapio)
admin.site.register(DescricaoRotina)
admin.site.register(RegistroRotina)
