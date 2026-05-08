"""
Comando de seed para popular o banco de dados com dados fictícios de demonstração.
Uso: python manage.py seed_data
"""
import random
from datetime import date, timedelta, datetime
from django.core.management.base import BaseCommand
from django.utils import timezone
from core.models import (
    Especie, Animal, Recinto, Alocacao, Funcionario,
    Triagem, Registro, MedicacaoAdministrada, Exame,
    Restricao, Risco,
)


class Command(BaseCommand):
    help = 'Popula o banco de dados com dados fictícios para demonstração'

    def handle(self, *args, **options):
        self.stdout.write('🌱 Iniciando seed de dados...')

        # Limpar dados existentes
        for model in [Risco, Restricao, Exame, MedicacaoAdministrada, Registro,
                       Triagem, Alocacao, Animal, Recinto, Especie, Funcionario]:
            model.objects.all().delete()

        # ── Espécies ──
        especies_data = [
            ('Panthera onca', 'Onça-pintada', 'Mamíferos', 'VU', 3),
            ('Chrysocyon brachyurus', 'Lobo-guará', 'Mamíferos', 'NT', 4),
            ('Harpia harpyja', 'Harpia', 'Aves', 'VU', 2),
            ('Ara ararauna', 'Arara-canindé', 'Aves', 'LC', 8),
            ('Chelonoidis carbonarius', 'Jabuti-piranga', 'Répteis', 'LC', 12),
            ('Caiman latirostris', 'Jacaré-do-papo-amarelo', 'Répteis', 'LC', 5),
            ('Leontopithecus rosalia', 'Mico-leão-dourado', 'Mamíferos', 'EN', 6),
            ('Amazona aestiva', 'Papagaio-verdadeiro', 'Aves', 'NT', 10),
            ('Puma concolor', 'Onça-parda', 'Mamíferos', 'VU', 2),
            ('Crax blumenbachii', 'Mutum-de-bico-vermelho', 'Aves', 'EN', 4),
            ('Tapirus terrestris', 'Anta', 'Mamíferos', 'VU', 3),
            ('Eunectes murinus', 'Sucuri-verde', 'Répteis', 'LC', 2),
            ('Ateles marginatus', 'Macaco-aranha', 'Mamíferos', 'EN', 5),
            ('Ramphastos toco', 'Tucano-toco', 'Aves', 'LC', 6),
            ('Hydrochoerus hydrochaeris', 'Capivara', 'Mamíferos', 'LC', 8),
            ('Myrmecophaga tridactyla', 'Tamanduá-bandeira', 'Mamíferos', 'VU', 3),
            ('Bradypus torquatus', 'Preguiça-de-coleira', 'Mamíferos', 'VU', 2),
            ('Spheniscus magellanicus', 'Pinguim-de-magalhães', 'Aves', 'NT', 4),
            ('Boa constrictor', 'Jiboia', 'Répteis', 'LC', 3),
            ('Alouatta guariba', 'Bugio-ruivo', 'Mamíferos', 'CR', 3),
        ]
        especies = []
        for nome_cient, nome_com, grupo, status, qtd in especies_data:
            esp = Especie.objects.create(
                nome_cientifico=nome_cient,
                nome_comum=nome_com,
                grupo_taxonomico=grupo,
                status_conservacao=status,
                quantidade=qtd,
                plano_manejo=f'Plano de manejo para {nome_com}',
            )
            especies.append(esp)
        self.stdout.write(f'  ✅ {len(especies)} espécies criadas')

        # ── Recintos ──
        recintos_data = [
            ('R001', 'Recinto Felinos Grandes', 4),
            ('R002', 'Recinto Canídeos', 6),
            ('R003', 'Aviário Principal', 20),
            ('R004', 'Reptilário', 15),
            ('R005', 'Recinto Primatas', 10),
            ('R006', 'Lago dos Jacarés', 8),
            ('R007', 'Viveiro Araras', 12),
            ('R008', 'Recinto Antas', 4),
            ('R009', 'Área de Capivaras', 10),
            ('R010', 'Recinto Tamanduás', 4),
            ('R011', 'Recinto Preguiças', 3),
            ('R012', 'Viveiro Tucanos', 8),
            ('R013', 'Recinto Pinguins', 6),
            ('R014', 'Serpentário', 10),
        ]
        recintos = []
        for gefau, nome, cap in recintos_data:
            r = Recinto.objects.create(
                recinto_gefau=gefau, nome=nome,
                cap_maxima=cap, qnt_animais=0, qnt_especies=0,
            )
            recintos.append(r)
        self.stdout.write(f'  ✅ {len(recintos)} recintos criados')

        # ── Funcionários ──
        funcionarios_data = [
            ('111.222.333-44', 'Dra. Ana Beatriz', '(16) 99999-0001', 'Veterinária'),
            ('222.333.444-55', 'Carlos Eduardo', '(16) 99999-0002', 'Tratador'),
            ('333.444.555-66', 'Dra. Fernanda Lima', '(16) 99999-0003', 'Veterinária'),
            ('444.555.666-77', 'Roberto Alves', '(16) 99999-0004', 'Biólogo'),
        ]
        funcionarios = []
        for cpf, nome, tel, funcao in funcionarios_data:
            f = Funcionario.objects.create(cpf=cpf, nome=nome, telefone=tel, funcao=funcao)
            funcionarios.append(f)
        self.stdout.write(f'  ✅ {len(funcionarios)} funcionários criados')

        # ── Animais ──
        nomes_apelidos = [
            'Zeus', 'Maya', 'Thor', 'Luna', 'Pipoca', 'Juma', 'Raio',
            'Flora', 'Nilo', 'Frida', 'Olímpia', 'Zico', 'Gaia', 'Simba',
            'Mel', 'Rex', 'Pandora', 'Atlas', 'Yara', 'Cleo', 'Tito',
            'Nina', 'Apolo', 'Jade', 'Bento', 'Serena', 'Romeu', 'Kiara',
            'Nero', 'Iris', 'Brisa', 'Caio', 'Sol', 'Fênix', 'Estrela',
        ]

        recinto_map = {
            'Mamíferos': [recintos[0], recintos[1], recintos[4], recintos[7], recintos[8], recintos[9], recintos[10]],
            'Aves': [recintos[2], recintos[6], recintos[11], recintos[12]],
            'Répteis': [recintos[3], recintos[5], recintos[13]],
        }

        animais = []
        apelido_idx = 0
        for esp in especies:
            possiveis_recintos = recinto_map.get(esp.grupo_taxonomico, recintos)
            for i in range(esp.quantidade):
                sexo = random.choice(['M', 'F', 'I'])
                data_nasc = date.today() - timedelta(days=random.randint(365, 365 * 15))
                apelido = nomes_apelidos[apelido_idx % len(nomes_apelidos)]
                apelido_idx += 1

                animal = Animal.objects.create(
                    nro_reg=f'AN-{len(animais)+1:04d}',
                    especie=esp,
                    data_nasc=data_nasc,
                    idade=f'{(date.today() - data_nasc).days // 365} anos',
                    apelido=apelido,
                    sexo=sexo,
                    plantel='Principal',
                    nro_gefau=f'GF-{len(animais)+1:04d}',
                    nro_livro=f'LV-{len(animais)+1:04d}',
                )
                animais.append(animal)

                # Alocar no recinto
                rec = random.choice(possiveis_recintos)
                Alocacao.objects.create(
                    animal=animal,
                    recinto=rec,
                    data_entrada=date.today() - timedelta(days=random.randint(30, 1000)),
                )

        # Atualizar contagem nos recintos
        for rec in recintos:
            alocados = Alocacao.objects.filter(recinto=rec, data_saida__isnull=True)
            rec.qnt_animais = alocados.count()
            esp_ids = alocados.values_list('animal__especie', flat=True).distinct()
            rec.qnt_especies = esp_ids.count()
            rec.save()

        self.stdout.write(f'  ✅ {len(animais)} animais criados e alocados')

        # ── Triagens ──
        triagem_count = 0
        for animal in animais:
            num_triagens = random.randint(2, 6)
            base_peso = random.uniform(1, 200)
            base_score = random.uniform(2, 5)
            for j in range(num_triagens):
                data_triagem = date.today() - timedelta(days=random.randint(1, 730))
                peso = round(base_peso + random.uniform(-5, 10) * (j + 1) / num_triagens, 2)
                score = round(min(5, max(1, base_score + random.uniform(-0.5, 0.5))), 1)
                Triagem.objects.create(
                    animal=animal,
                    data=data_triagem,
                    peso_ao_chegar=max(0.1, peso),
                    score_corporal=score,
                    gravidade_veterinaria=random.choice(['Leve', 'Moderada', 'Grave', 'Estável']),
                    observacoes=random.choice([
                        'Animal em bom estado geral.',
                        'Apresentou apatia leve.',
                        'Apetite normal, pelagem saudável.',
                        'Necessita acompanhamento.',
                        'Sem alterações significativas.',
                    ]),
                )
                triagem_count += 1
        self.stdout.write(f'  ✅ {triagem_count} triagens criadas')

        # ── Registros clínicos ──
        medicamentos = [
            'Enrofloxacina', 'Meloxicam', 'Ivermectina', 'Dexametasona',
            'Amoxicilina', 'Tramadol', 'Cetoprofeno', 'Metronidazol',
        ]
        exames_tipos = [
            'Hemograma completo', 'Bioquímico', 'Coproparasitológico',
            'Radiografia', 'Ultrassonografia', 'Citologia',
        ]
        registro_count = 0
        for animal in animais[:30]:  # Registros para os primeiros 30 animais
            num_registros = random.randint(1, 5)
            for _ in range(num_registros):
                dt = timezone.now() - timedelta(days=random.randint(1, 500))
                reg = Registro.objects.create(
                    animal=animal,
                    data=dt.date(),
                    data_hora=dt,
                    tipo_registro=random.choice(['clinico', 'biologico']),
                    ocorrencia=random.choice([
                        'Consulta de rotina',
                        'Ferimento observado na pata',
                        'Perda de apetite nos últimos dias',
                        'Avaliação pós-tratamento',
                        'Queda de penas/pelos anormal',
                        'Dificuldade de locomoção',
                        'Verificação de parasitas',
                    ]),
                    detalhamento=random.choice([
                        'Exame físico sem alterações dignas de nota.',
                        'Prescrição de medicação anti-inflamatória.',
                        'Encaminhado para exames complementares.',
                        'Melhora clínica observada desde última avaliação.',
                        'Necessário acompanhamento semanal.',
                    ]),
                    tratamento=random.choice([
                        'Medicação oral por 7 dias',
                        'Curativo local diário',
                        'Observação por 48h',
                        'Suplementação alimentar',
                        '',
                    ]),
                    funcionario=random.choice(funcionarios),
                )
                registro_count += 1

                # Medicações
                if random.random() > 0.4:
                    for _ in range(random.randint(1, 3)):
                        MedicacaoAdministrada.objects.create(
                            registro=reg,
                            medicamento=random.choice(medicamentos),
                            dose_pv=f'{random.uniform(0.1, 10):.1f} mg/kg',
                        )

                # Exames
                if random.random() > 0.5:
                    for _ in range(random.randint(1, 2)):
                        Exame.objects.create(
                            registro=reg,
                            data=reg.data,
                            tipo=random.choice(exames_tipos),
                            resultado=random.choice([
                                'Dentro dos parâmetros normais',
                                'Leve alteração, monitorar',
                                'Positivo para parasitas intestinais',
                                'Sem alterações',
                                'Anemia leve detectada',
                            ]),
                            observacao='',
                        )

        self.stdout.write(f'  ✅ {registro_count} registros clínicos criados')

        # ── Restrições e Riscos ──
        restricao_count = 0
        risco_count = 0
        for animal in random.sample(animais, min(15, len(animais))):
            if random.random() > 0.5:
                Restricao.objects.create(
                    animal=animal,
                    data=date.today() - timedelta(days=random.randint(0, 60)),
                    restricao=random.choice([
                        'Não manipular sem sedação',
                        'Dieta restrita - sem frutas cítricas',
                        'Evitar contato com outros animais',
                        'Restrição de movimentação',
                        'Isolamento temporário',
                    ]),
                )
                restricao_count += 1

            if random.random() > 0.6:
                Risco.objects.create(
                    animal=animal,
                    data=date.today() - timedelta(days=random.randint(0, 30)),
                    risco=random.choice([
                        'Risco de automutilação',
                        'Comportamento agressivo recente',
                        'Histórico de fuga',
                        'Alergia a medicamentos (penicilina)',
                        'Animal idoso - risco anestésico',
                    ]),
                )
                risco_count += 1

        self.stdout.write(f'  ✅ {restricao_count} restrições e {risco_count} riscos criados')
        self.stdout.write(self.style.SUCCESS('\n🎉 Seed concluído com sucesso!'))
