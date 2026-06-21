import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Search, PawPrint } from "lucide-react";
import { api } from "../lib/api";
import type { AnimalResumo } from "../types";
import { Spinner } from "../components/ui/Spinner";

const SEXO_LABEL: Record<string, string> = { M: "Macho", F: "Fêmea", I: "Indeterminado" };

export function AnimaisSelecaoPage() {
  const [query, setQuery] = useState("");
  const [animais, setAnimais] = useState<AnimalResumo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => {
      setLoading(true);
      api
        .get<AnimalResumo[]>("/animais", { params: query ? { q: query } : {} })
        .then((r) => setAnimais(r.data))
        .finally(() => setLoading(false));
    }, 250);
    return () => clearTimeout(t);
  }, [query]);

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Prontuário Digital</h1>
        <p className="mt-1 text-gray-500">Selecione um animal para ver o histórico completo.</p>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-400" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Buscar por apelido, registro, espécie ou GEFAU…"
          className="w-full rounded-xl border border-gray-200 bg-white py-3 pl-11 pr-4 text-sm outline-none focus:border-primary-400 focus:ring-2 focus:ring-primary-100"
        />
      </div>

      {loading ? (
        <Spinner />
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {animais.map((a) => (
            <Link
              key={a.nro_reg}
              to={`/prontuario/${a.nro_reg}`}
              className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md"
            >
              <div className="mb-3 flex h-10 w-10 items-center justify-center rounded-xl bg-primary-50 text-primary-600">
                <PawPrint className="h-5 w-5" />
              </div>
              <p className="text-lg font-bold text-gray-900">{a.apelido ?? `#${a.nro_reg}`}</p>
              <p className="text-sm text-gray-500">{a.especie_nome_comum}</p>
              <div className="mt-3 flex flex-wrap gap-2 text-xs text-gray-500">
                <span className="rounded-full bg-gray-100 px-2 py-0.5">#{a.nro_reg}</span>
                {a.sexo && (
                  <span className="rounded-full bg-gray-100 px-2 py-0.5">
                    {SEXO_LABEL[a.sexo] ?? a.sexo}
                  </span>
                )}
                {a.recinto_atual_nome && (
                  <span className="rounded-full bg-primary-50 px-2 py-0.5 text-primary-700">
                    {a.recinto_atual_nome}
                  </span>
                )}
              </div>
            </Link>
          ))}
          {animais.length === 0 && (
            <p className="col-span-full text-center text-gray-400">Nenhum animal encontrado.</p>
          )}
        </div>
      )}
    </div>
  );
}
