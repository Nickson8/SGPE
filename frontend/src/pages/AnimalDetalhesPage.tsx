import { useEffect, useState } from "react";
import type { ReactNode } from "react";
import { Link, useParams } from "react-router-dom";
import { ArrowLeft, AlertTriangle, ShieldAlert } from "lucide-react";
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { api } from "../lib/api";
import type { AnimalDetalhe } from "../types";
import { Spinner } from "../components/ui/Spinner";

const SEXO_LABEL: Record<string, string> = { M: "Macho", F: "Fêmea", I: "Indeterminado" };

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
      <h2 className="mb-4 text-sm font-semibold text-gray-700">{title}</h2>
      {children}
    </div>
  );
}

export function AnimalDetalhesPage() {
  const { nroReg } = useParams();
  const [animal, setAnimal] = useState<AnimalDetalhe | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    api
      .get<AnimalDetalhe>(`/animais/${nroReg}`)
      .then((r) => setAnimal(r.data))
      .catch(() => setAnimal(null))
      .finally(() => setLoading(false));
  }, [nroReg]);

  if (loading) return <Spinner />;
  if (!animal) return <p className="text-gray-500">Animal não encontrado.</p>;

  const chartData = animal.triagens.map((t) => ({
    data: t.data_triagem,
    peso: t.peso_ao_chegar,
    score: t.score_corporal,
  }));

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <Link to="/prontuario" className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-900">
        <ArrowLeft className="h-4 w-4" /> Voltar
      </Link>

      {/* Ficha */}
      <div className="rounded-3xl bg-gradient-to-br from-primary-600 to-primary-800 p-6 text-white">
        <h1 className="text-2xl font-extrabold">{animal.apelido ?? `#${animal.nro_reg}`}</h1>
        <p className="text-primary-100">
          {animal.especie_nome_comum} · <em>{animal.especie_nome_cientifico}</em>
        </p>
        <div className="mt-4 grid grid-cols-2 gap-3 text-sm sm:grid-cols-4">
          <Info label="Nº Registro" value={`#${animal.nro_reg}`} />
          <Info label="Sexo" value={animal.sexo ? SEXO_LABEL[animal.sexo] ?? animal.sexo : "—"} />
          <Info label="GEFAU" value={animal.nro_gefau ?? "—"} />
          <Info label="Recinto atual" value={animal.recinto_atual_nome ?? "Sem alocação"} />
          <Info label="Grupo" value={animal.grupo_taxonomico ?? "—"} />
          <Info label="Nascimento" value={animal.data_nasc} />
          <Info label="Nº Livro" value={String(animal.nro_livro)} />
          <Info label="Plantel" value={animal.plantel === "S" ? "Sim" : "Não"} />
        </div>
      </div>

      {/* Alertas */}
      {(animal.restricoes.length > 0 || animal.riscos.length > 0) && (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          {animal.restricoes.length > 0 && (
            <div className="rounded-2xl border border-warning-200 bg-warning-50 p-4">
              <p className="mb-2 flex items-center gap-2 text-sm font-semibold text-warning-700">
                <AlertTriangle className="h-4 w-4" /> Restrições
              </p>
              <ul className="space-y-1 text-sm text-gray-700">
                {animal.restricoes.map((r, i) => (
                  <li key={i}>• {r.texto} <span className="text-gray-400">({r.data_triagem})</span></li>
                ))}
              </ul>
            </div>
          )}
          {animal.riscos.length > 0 && (
            <div className="rounded-2xl border border-danger-200 bg-danger-50 p-4">
              <p className="mb-2 flex items-center gap-2 text-sm font-semibold text-danger-600">
                <ShieldAlert className="h-4 w-4" /> Riscos
              </p>
              <ul className="space-y-1 text-sm text-gray-700">
                {animal.riscos.map((r, i) => (
                  <li key={i}>• {r.texto} <span className="text-gray-400">({r.data_triagem})</span></li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      {/* Gráficos de evolução */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Section title="Evolução de peso (kg)">
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#eef2f6" />
              <XAxis dataKey="data" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 11 }} />
              <Tooltip />
              <Line type="monotone" dataKey="peso" stroke="#059669" strokeWidth={2} dot={{ r: 3 }} />
            </LineChart>
          </ResponsiveContainer>
        </Section>
        <Section title="Evolução do score corporal (0–5)">
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#eef2f6" />
              <XAxis dataKey="data" tick={{ fontSize: 11 }} />
              <YAxis domain={[0, 5]} tick={{ fontSize: 11 }} />
              <Tooltip />
              <Line type="monotone" dataKey="score" stroke="#f59e0b" strokeWidth={2} dot={{ r: 3 }} />
            </LineChart>
          </ResponsiveContainer>
        </Section>
      </div>

      {/* Medicações & Exames */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Section title="Medicações administradas">
          {animal.medicacoes.length === 0 ? (
            <p className="text-sm text-gray-400">Sem medicações registradas.</p>
          ) : (
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-xs uppercase text-gray-400">
                  <th className="pb-2">Medicamento</th>
                  <th className="pb-2">Dose (PV)</th>
                  <th className="pb-2">Data</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {animal.medicacoes.map((m, i) => (
                  <tr key={i}>
                    <td className="py-2 text-gray-700">{m.medicamento}</td>
                    <td className="py-2 text-gray-500">{m.dose_pv ?? "—"}</td>
                    <td className="py-2 text-gray-500">{m.data_hora.slice(0, 10)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </Section>

        <Section title="Exames recentes">
          {animal.exames.length === 0 ? (
            <p className="text-sm text-gray-400">Sem exames registrados.</p>
          ) : (
            <div className="space-y-3">
              {animal.exames.map((e, i) => (
                <div key={i} className="rounded-xl border border-gray-100 p-3">
                  <div className="flex items-center justify-between">
                    <p className="text-sm font-medium text-gray-800">{e.tipo_exame}</p>
                    <span className="text-xs text-gray-400">{e.data_exame}</span>
                  </div>
                  <p className="mt-1 text-sm text-gray-600">{e.resultados}</p>
                </div>
              ))}
            </div>
          )}
        </Section>
      </div>

      {/* Timeline */}
      <Section title="Histórico de registros">
        {animal.timeline.length === 0 ? (
          <p className="text-sm text-gray-400">Sem registros clínicos ou biológicos.</p>
        ) : (
          <ol className="relative space-y-5 border-l border-gray-200 pl-5">
            {animal.timeline.map((r, i) => (
              <li key={i}>
                <span className="absolute -left-[7px] mt-1 h-3 w-3 rounded-full border-2 border-white bg-primary-500" />
                <div className="flex flex-wrap items-center gap-2">
                  <span
                    className={`rounded-full px-2 py-0.5 text-xs font-medium ${
                      r.tipo === "clinico"
                        ? "bg-danger-50 text-danger-600"
                        : "bg-primary-50 text-primary-700"
                    }`}
                  >
                    {r.tipo === "clinico" ? "Clínico" : "Biológico"}
                  </span>
                  <span className="text-xs text-gray-400">{r.data_hora.replace("T", " ").slice(0, 16)}</span>
                </div>
                <p className="mt-1 text-sm font-medium text-gray-800">{r.ocorrencia}</p>
                {r.detalhamento && <p className="text-sm text-gray-600">{r.detalhamento}</p>}
                {r.funcionario_nome && (
                  <p className="mt-0.5 text-xs text-gray-400">Responsável: {r.funcionario_nome}</p>
                )}
              </li>
            ))}
          </ol>
        )}
      </Section>
    </div>
  );
}

function Info({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-white/10 px-3 py-2">
      <p className="text-xs text-primary-100">{label}</p>
      <p className="text-sm font-semibold">{value}</p>
    </div>
  );
}
