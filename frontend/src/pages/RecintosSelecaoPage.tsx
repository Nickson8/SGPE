import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Search } from "lucide-react";
import { api } from "../lib/api";
import type { RecintoResumo } from "../types";
import { OccupancyBar } from "../components/ui/OccupancyBar";
import { Spinner } from "../components/ui/Spinner";

export function RecintosSelecaoPage() {
  const [query, setQuery] = useState("");
  const [recintos, setRecintos] = useState<RecintoResumo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => {
      setLoading(true);
      api
        .get<RecintoResumo[]>("/recintos", { params: query ? { q: query } : {} })
        .then((r) => setRecintos(r.data))
        .finally(() => setLoading(false));
    }, 250);
    return () => clearTimeout(t);
  }, [query]);

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Recintos</h1>
        <p className="mt-1 text-gray-500">Ocupação e detalhes dos recintos do parque.</p>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Buscar por nome ou código GEFAU…"
          className="w-full rounded-xl border border-gray-200 bg-white py-3 pl-11 pr-4 text-sm outline-none focus:border-primary-400 focus:ring-2 focus:ring-primary-100"
        />
      </div>

      {loading ? (
        <Spinner />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {recintos.map((r) => (
            <Link
              key={r.recinto_gefau}
              to={`/recintos/${r.recinto_gefau}`}
              className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md"
            >
              <div className="flex items-start justify-between">
                <div>
                  <p className="font-bold text-gray-900">{r.nome}</p>
                  <p className="text-xs text-gray-400">{r.recinto_gefau}</p>
                </div>
                <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-500">
                  {r.qnt_especies} esp.
                </span>
              </div>
              <div className="mt-4 mb-1 flex items-center justify-between text-sm">
                <span className="text-gray-500">Ocupação</span>
                <span className="font-medium text-gray-700">
                  {r.qnt_animais}/{r.capacidade_max} ({r.percentual_ocupacao}%)
                </span>
              </div>
              <OccupancyBar percentual={r.percentual_ocupacao} status={r.status_ocupacao} />
            </Link>
          ))}
          {recintos.length === 0 && (
            <p className="col-span-full text-center text-gray-400">Nenhum recinto encontrado.</p>
          )}
        </div>
      )}
    </div>
  );
}
