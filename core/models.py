from django.db import models


class Especie(models.Model):
    """Espécie animal com classificação taxonômica e status de conservação."""

    STATUS_CONSERVACAO_CHOICES = [
        ('LC', 'Menos Preocupante'),
        ('NT', 'Quase Ameaçada'),
        ('VU', 'Vulnerável'),
        ('EN', 'Em Perigo'),
        ('CR', 'Criticamente em Perigo'),
        ('EW', 'Extinta na Natureza'),
        ('EX', 'Extinta'),
    ]

    nome_cientifico = models.CharField(max_length=200, unique=True)
    nome_comum = models.CharField(max_length=200)
    grupo_taxonomico = models.CharField(max_length=100)
    plano_manejo = models.TextField(blank=True, default='')
    quantidade = models.PositiveIntegerField(default=0)
    status_conservacao = models.CharField(
        max_length=2, choices=STATUS_CONSERVACAO_CHOICES, default='LC'
    )

    class Meta:
        verbose_name = 'Espécie'
        verbose_name_plural = 'Espécies'
        ordering = ['nome_comum']

    def __str__(self):
        return f"{self.nome_comum} ({self.nome_cientifico})"


class Recinto(models.Model):
    """Recinto onde os animais são alocados."""
    recinto_gefau = models.CharField(max_length=50, primary_key=True)
    nome = models.CharField(max_length=200)
    cap_maxima = models.PositiveIntegerField(verbose_name='Capacidade Máxima')
    qnt_animais = models.PositiveIntegerField(default=0, verbose_name='Quantidade de Animais')
    qnt_especies = models.PositiveIntegerField(default=0, verbose_name='Quantidade de Espécies')

    class Meta:
        verbose_name = 'Recinto'
        verbose_name_plural = 'Recintos'
        ordering = ['nome']

    def __str__(self):
        return f"{self.nome} ({self.recinto_gefau})"

    @property
    def percentual_ocupacao(self):
        if self.cap_maxima == 0:
            return 0
        return round((self.qnt_animais / self.cap_maxima) * 100, 1)

    @property
    def status_ocupacao(self):
        p = self.percentual_ocupacao
        if p > 100:
            return 'critico'
        elif p >= 75:
            return 'alerta'
        return 'normal'


class Animal(models.Model):
    """Animal individual pertencente ao plantel."""
    SEXO_CHOICES = [
        ('M', 'Macho'),
        ('F', 'Fêmea'),
        ('I', 'Indeterminado'),
    ]

    nro_reg = models.CharField(max_length=50, primary_key=True, verbose_name='Nº Registro')
    especie = models.ForeignKey(Especie, on_delete=models.PROTECT, related_name='animais')
    data_nasc = models.DateField(null=True, blank=True, verbose_name='Data de Nascimento')
    idade = models.CharField(max_length=50, blank=True, default='')
    marcacao_1 = models.CharField(max_length=100, blank=True, default='', verbose_name='Marcação 1')
    marcacao_2 = models.CharField(max_length=100, blank=True, default='', verbose_name='Marcação 2')
    apelido = models.CharField(max_length=100, blank=True, default='')
    sexo = models.CharField(max_length=1, choices=SEXO_CHOICES, default='I')
    plantel = models.CharField(max_length=100, blank=True, default='')
    nro_gefau = models.CharField(max_length=50, blank=True, default='', verbose_name='Nº GEFAU')
    nro_livro = models.CharField(max_length=50, blank=True, default='', verbose_name='Nº Livro')

    class Meta:
        verbose_name = 'Animal'
        verbose_name_plural = 'Animais'
        ordering = ['apelido']

    def __str__(self):
        nome = self.apelido or self.nro_reg
        return f"{nome} - {self.especie.nome_comum}"

    @property
    def recinto_atual(self):
        """Retorna o recinto atual (alocação sem data de saída)."""
        alocacao = self.alocacoes.filter(data_saida__isnull=True).first()
        return alocacao.recinto if alocacao else None


class Alocacao(models.Model):
    """Registro de alocação de um animal em um recinto."""
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='alocacoes')
    recinto = models.ForeignKey(Recinto, on_delete=models.CASCADE, related_name='alocacoes')
    data_entrada = models.DateField()
    data_saida = models.DateField(null=True, blank=True)
    motivo_saida = models.TextField(blank=True, default='')

    class Meta:
        verbose_name = 'Alocação'
        verbose_name_plural = 'Alocações'
        ordering = ['-data_entrada']

    def __str__(self):
        return f"{self.animal} → {self.recinto} ({self.data_entrada})"


class Funcionario(models.Model):
    """Funcionário do parque (veterinário, tratador, etc.)."""
    cpf = models.CharField(max_length=14, primary_key=True)
    nome = models.CharField(max_length=200)
    telefone = models.CharField(max_length=20, blank=True, default='')
    funcao = models.CharField(max_length=100, verbose_name='Função')

    class Meta:
        verbose_name = 'Funcionário'
        verbose_name_plural = 'Funcionários'
        ordering = ['nome']

    def __str__(self):
        return f"{self.nome} ({self.funcao})"


class Triagem(models.Model):
    """Registro de triagem de um animal."""
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='triagens')
    data = models.DateField()
    peso_ao_chegar = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    score_corporal = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    gravidade_veterinaria = models.CharField(max_length=100, blank=True, default='')
    observacoes = models.TextField(blank=True, default='')
    idade_na_triagem = models.CharField(max_length=50, blank=True, default='')

    class Meta:
        verbose_name = 'Triagem'
        verbose_name_plural = 'Triagens'
        ordering = ['-data']

    def __str__(self):
        return f"Triagem de {self.animal} em {self.data}"


class Registro(models.Model):
    """Registro clínico ou biológico de um animal."""
    TIPO_CHOICES = [
        ('clinico', 'Clínico'),
        ('biologico', 'Biológico'),
    ]

    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='registros')
    data = models.DateField()
    data_hora = models.DateTimeField()
    ocorrencia = models.TextField(verbose_name='Ocorrência')
    tipo_registro = models.CharField(max_length=10, choices=TIPO_CHOICES)
    detalhamento = models.TextField(blank=True, default='')
    anexo_laudo_saude = models.FileField(upload_to='laudos/', blank=True, null=True)
    tratamento = models.TextField(blank=True, default='')
    funcionario = models.ForeignKey(
        Funcionario, on_delete=models.SET_NULL, null=True, blank=True, related_name='registros'
    )

    class Meta:
        verbose_name = 'Registro'
        verbose_name_plural = 'Registros'
        ordering = ['-data_hora']

    def __str__(self):
        return f"Registro {self.tipo_registro} - {self.animal} ({self.data})"


class MedicacaoAdministrada(models.Model):
    """Medicação administrada vinculada a um registro clínico."""
    registro = models.ForeignKey(Registro, on_delete=models.CASCADE, related_name='medicacoes')
    medicamento = models.CharField(max_length=200)
    dose_pv = models.CharField(max_length=100, verbose_name='Dose PV')

    class Meta:
        verbose_name = 'Medicação Administrada'
        verbose_name_plural = 'Medicações Administradas'

    def __str__(self):
        return f"{self.medicamento} - {self.dose_pv}"


class Exame(models.Model):
    """Exame realizado vinculado a um registro."""
    registro = models.ForeignKey(Registro, on_delete=models.CASCADE, related_name='exames')
    data = models.DateField()
    tipo = models.CharField(max_length=100)
    resultado = models.TextField(blank=True, default='')
    observacao = models.TextField(blank=True, default='')

    class Meta:
        verbose_name = 'Exame'
        verbose_name_plural = 'Exames'
        ordering = ['-data']

    def __str__(self):
        return f"{self.tipo} ({self.data})"


class Restricao(models.Model):
    """Restrição registrada para um animal."""
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='restricoes')
    data = models.DateField()
    restricao = models.TextField(verbose_name='Restrição')

    class Meta:
        verbose_name = 'Restrição'
        verbose_name_plural = 'Restrições'
        ordering = ['-data']

    def __str__(self):
        return f"Restrição: {self.animal} ({self.data})"


class Risco(models.Model):
    """Risco registrado para um animal."""
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='riscos')
    data = models.DateField()
    risco = models.TextField()

    class Meta:
        verbose_name = 'Risco'
        verbose_name_plural = 'Riscos'
        ordering = ['-data']

    def __str__(self):
        return f"Risco: {self.animal} ({self.data})"


# ──────────────────────────────────────────────────────────
# Entidades secundárias (modeladas para completude do schema)
# ──────────────────────────────────────────────────────────

class Documento(models.Model):
    """Documento associado a um animal (baixa, entrada, etc.)."""
    TIPO_MIGRACAO_CHOICES = [
        ('baixa', 'Baixa'),
        ('entrada', 'Entrada'),
    ]

    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='documentos')
    tipo_documento = models.CharField(max_length=100)
    nro_documento = models.CharField(max_length=100)
    anexo = models.FileField(upload_to='documentos/', blank=True, null=True)
    data = models.DateField()
    observacao = models.TextField(blank=True, default='')
    tipo_migracao = models.CharField(
        max_length=10, choices=TIPO_MIGRACAO_CHOICES, blank=True, default=''
    )
    destino = models.CharField(max_length=200, blank=True, default='')
    origem = models.CharField(max_length=200, blank=True, default='')

    class Meta:
        verbose_name = 'Documento'
        verbose_name_plural = 'Documentos'

    def __str__(self):
        return f"{self.tipo_documento} - {self.nro_documento}"


class Prole(models.Model):
    """Relação de prole entre animais."""
    pai = models.ForeignKey(
        Animal, on_delete=models.CASCADE, related_name='prole_como_pai', null=True, blank=True
    )
    mae = models.ForeignKey(
        Animal, on_delete=models.CASCADE, related_name='prole_como_mae', null=True, blank=True
    )
    prole = models.ForeignKey(
        Animal, on_delete=models.CASCADE, related_name='prole_como_filho'
    )

    class Meta:
        verbose_name = 'Prole'
        verbose_name_plural = 'Proles'

    def __str__(self):
        return f"Prole: {self.prole}"


class Casal(models.Model):
    """Par reprodutor."""
    animal_1 = models.ForeignKey(
        Animal, on_delete=models.CASCADE, related_name='casais_como_1'
    )
    animal_2 = models.ForeignKey(
        Animal, on_delete=models.CASCADE, related_name='casais_como_2'
    )

    class Meta:
        verbose_name = 'Casal'
        verbose_name_plural = 'Casais'

    def __str__(self):
        return f"{self.animal_1} & {self.animal_2}"


class ItemCardapio(models.Model):
    """Item do cardápio alimentar de um animal."""
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='cardapio')
    alimento = models.CharField(max_length=200)
    qnt_porcao = models.CharField(max_length=100, verbose_name='Quantidade da Porção')
    observacoes = models.TextField(blank=True, default='')
    frequencia = models.CharField(max_length=100, blank=True, default='', verbose_name='Frequência')

    class Meta:
        verbose_name = 'Item de Cardápio'
        verbose_name_plural = 'Itens de Cardápio'

    def __str__(self):
        return f"{self.alimento} para {self.animal}"


class DescricaoRotina(models.Model):
    """Descrição de rotina (programa) associada a um animal."""
    TIPO_ROTINA_CHOICES = [
        ('programa', 'Programa'),
        ('cardapio', 'Cardápio'),
        ('condicionamento', 'Condicionamento'),
        ('enriquecimento', 'Enriquecimento'),
    ]

    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='rotinas')
    tipo_rotina = models.CharField(max_length=20, choices=TIPO_ROTINA_CHOICES)
    objetivo = models.TextField(blank=True, default='')
    metodologia = models.TextField(blank=True, default='')
    ferramentas = models.TextField(blank=True, default='')

    class Meta:
        verbose_name = 'Descrição de Rotina'
        verbose_name_plural = 'Descrições de Rotina'

    def __str__(self):
        return f"{self.tipo_rotina} - {self.animal}"


class RegistroRotina(models.Model):
    """Registro individual de uma rotina realizada."""
    animal = models.ForeignKey(Animal, on_delete=models.CASCADE, related_name='registros_rotina')
    tipo_rotina = models.CharField(max_length=100)
    data_horario = models.DateTimeField()
    observacoes = models.TextField(blank=True, default='')
    dia_semana = models.CharField(max_length=20, blank=True, default='')
    frequencia = models.CharField(max_length=100, blank=True, default='')
    tipo = models.CharField(max_length=100, blank=True, default='')
    comandos = models.TextField(blank=True, default='')

    class Meta:
        verbose_name = 'Registro de Rotina'
        verbose_name_plural = 'Registros de Rotina'

    def __str__(self):
        return f"Rotina {self.tipo_rotina} - {self.animal} ({self.data_horario})"
