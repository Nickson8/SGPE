import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { ArrowLeft, PawPrint } from "lucide-react";
import { api } from "../lib/api";
import type { RecintoDetalhe } from "../types";
import { OccupancyBar } from "../components/ui/OccupancyBar";
import { Spinner } from "../components/ui/Spinner";

export function RecintoDetalhesPage() {
  const { gefau } = useParams();
  const [recinto, setRecinto] = useState<RecintoDetalhe | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    api
      .get<RecintoDetalhe>(`/recintos/${gefau}`)
      .then((r) => setRecinto(r.data))
      .catch(() => setRecinto(null))
      .finally(() => setLoading(false));
  }, [gefau]);

  if (loading) return <Spinner />;
  if (!recinto) return <p className="text-gray-500">Recinto não encontrado.</p>;

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <Link to="/recintos" className="inline-flex items-center gap-1 text-sm text-gray-500 hover:text-gray-900">
        <ArrowLeft className="h-4 w-4" /> Voltar
      </Link>

      <div className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{recinto.nome}</h1>
            <p className="text-sm text-gray-400">{recinto.recinto_gefau}</p>
          </div>
          <div className="text-right">
            <p className="text-2xl font-bold text-gray-900">
              {recinto.qnt_animais}/{recinto.capacidade_max}
            </p>
            <p className="text-sm text-gray-500">{recinto.percentual_ocupacao}% ocupado</p>
          </div>
        </div>
        <div className="mt-4">
          <OccupancyBar percentual={recinto.percentual_ocupacao} status={recinto.status_ocupacao} />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-sm font-semibold text-gray-700">
            Animais alocados ({recinto.animais_alocados.length})
          </h2>
          <div className="space-y-2">
            {recinto.animais_alocados.map((a) => (
              <Link
                key={a.nro_reg}
                to={`/prontuario/${a.nro_reg}`}
                className="flex items-center gap-3 rounded-xl p-2 transition-colors hover:bg-gray-50"
              >
                <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary-50 text-primary-600">
                  <PawPrint className="h-4 w-4" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-800">{a.apelido ?? `#${a.nro_reg}`}</p>
                  <p className="text-xs text-gray-500">{a.especie_nome_comum}</p>
                </div>
              </Link>
            ))}
            {recinto.animais_alocados.length === 0 && (
              <p className="text-sm text-gray-400">Nenhum animal alocado atualmente.</p>
            )}
          </div>
        </div>

        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-sm font-semibold text-gray-700">
            Espécies presentes ({recinto.especies_presentes.length})
          </h2>
          <div className="flex flex-wrap gap-2">
            {recinto.especies_presentes.map((e) => (
              <span
                key={e.nome_cientifico}
                className="rounded-full bg-primary-50 px-3 py-1 text-sm text-primary-700"
              >
                {e.nome_comum}
              </span>
            ))}
            {recinto.especies_presentes.length === 0 && (
              <p className="text-sm text-gray-400">—</p>
            )}
          </div>
        </div>
      </div>

      <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
        <h2 className="mb-4 text-sm font-semibold text-gray-700">Histórico de alocações</h2>
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-xs uppercase text-gray-400">
              <th className="pb-2">Animal</th>
              <th className="pb-2">Entrada</th>
              <th className="pb-2">Saída</th>
              <th className="pb-2">Motivo</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {recinto.historico_alocacoes.map((h, i) => (
              <tr key={i}>
                <td className="py-2">
                  <Link to={`/prontuario/${h.nro_reg}`} className="text-primary-700 hover:underline">
                    {h.apelido ?? `#${h.nro_reg}`}
                  </Link>
                  <span className="text-gray-400"> · {h.especie_nome_comum}</span>
                </td>
                <td className="py-2 text-gray-500">{h.data_entrada}</td>
                <td className="py-2 text-gray-500">{h.data_saida ?? "—"}</td>
                <td className="py-2 text-gray-500">{h.motivo_saida ?? "—"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
