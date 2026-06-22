import { useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { AlertTriangle, Check, ChevronDown, Stethoscope } from "lucide-react";
import { api } from "../../lib/api";
import type { AnimalEmAlerta, Especie } from "../../types";
import { Spinner } from "../ui/Spinner";

/**
 * Consulta parametrizada: o usuário escolhe uma ou mais espécies (caixas de
 * seleção) e o sistema lista os animais dessas espécies em estado de alerta
 * (gravidade veterinária da triagem mais recente ≠ "Normal"), com o recinto
 * atual e o último peso. Implementa a Consulta 1 em forma parametrizada.
 */
export function ConsultaAlertaCard() {
  const [especies, setEspecies] = useState<Especie[]>([]);
  const [selecionadas, setSelecionadas] = useState<Set<string>>(new Set());
  const [resultados, setResultados] = useState<AnimalEmAlerta[]>([]);
  const [loading, setLoading] = useState(false);
  const [aberto, setAberto] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Carrega as espécies para montar as caixas de seleção.
  useEffect(() => {
    api.get<Especie[]>("/especies").then((r) => setEspecies(r.data));
  }, []);

  // Fecha o dropdown ao clicar fora.
  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setAberto(false);
      }
    };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  // Busca os animais em alerta sempre que a seleção muda.
  useEffect(() => {
    if (selecionadas.size === 0) {
      setResultados([]);
      return;
    }
    setLoading(true);
    const params = new URLSearchParams();
    selecionadas.forEach((nome) => params.append("especie", nome));
    api
      .get<AnimalEmAlerta[]>(`/dashboard/animais-em-alerta?${params.toString()}`)
      .then((r) => setResultados(r.data))
      .finally(() => setLoading(false));
  }, [selecionadas]);

  const toggle = (nome: string) => {
    setSelecionadas((prev) => {
      const next = new Set(prev);
      if (next.has(nome)) next.delete(nome);
      else next.add(nome);
      return next;
    });
  };

  const rotulo =
    selecionadas.size === 0
      ? "Selecione as espécies…"
      : `${selecionadas.size} espécie${selecionadas.size > 1 ? "s" : ""} selecionada${
          selecionadas.size > 1 ? "s" : ""
        }`;

  return (
    <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
      <h2 className="mb-1 flex items-center gap-2 text-sm font-semibold text-gray-700">
        <Stethoscope className="h-4 w-4" /> Animais em estado de alerta por espécie
      </h2>
      <p className="mb-4 text-xs text-gray-500">
        Escolha uma ou mais espécies para ver os animais cuja triagem mais recente
        indica gravidade veterinária diferente de “Normal”.
      </p>

      {/* Dropdown com caixas de seleção (multi-seleção). */}
      <div ref={dropdownRef} className="relative mb-4">
        <button
          type="button"
          onClick={() => setAberto((v) => !v)}
          className="flex w-full items-center justify-between rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 outline-none focus:border-primary-400 focus:ring-2 focus:ring-primary-100"
        >
          <span className={selecionadas.size === 0 ? "text-gray-400" : ""}>{rotulo}</span>
          <ChevronDown
            className={`h-4 w-4 text-gray-400 transition-transform ${aberto ? "rotate-180" : ""}`}
          />
        </button>

        {aberto && (
          <div className="absolute z-10 mt-1 max-h-64 w-full overflow-auto rounded-xl border border-gray-200 bg-white p-1 shadow-lg">
            {especies.length === 0 && (
              <p className="px-3 py-2 text-sm text-gray-400">Carregando espécies…</p>
            )}
            {especies.map((e) => {
              const marcada = selecionadas.has(e.nome_cientifico);
              return (
                <button
                  key={e.nome_cientifico}
                  type="button"
                  onClick={() => toggle(e.nome_cientifico)}
                  className="flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm hover:bg-gray-50"
                >
                  <span
                    className={`flex h-4 w-4 shrink-0 items-center justify-center rounded border ${
                      marcada
                        ? "border-primary-600 bg-primary-600 text-white"
                        : "border-gray-300 bg-white"
                    }`}
                  >
                    {marcada && <Check className="h-3 w-3" />}
                  </span>
                  <span className="text-gray-700">
                    {e.nome_comum ?? e.nome_cientifico}
                    <span className="text-gray-400"> · {e.nome_cientifico}</span>
                  </span>
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Resultado da consulta. */}
      {loading ? (
        <Spinner />
      ) : selecionadas.size === 0 ? (
        <p className="py-6 text-center text-sm text-gray-400">
          Nenhuma espécie selecionada.
        </p>
      ) : resultados.length === 0 ? (
        <p className="py-6 text-center text-sm text-gray-400">
          Nenhum animal em estado de alerta para a seleção.
        </p>
      ) : (
        <div className="divide-y divide-gray-100">
          {resultados.map((a) => (
            <div key={a.nro_reg} className="flex items-center justify-between gap-3 py-2.5 text-sm">
              <div className="min-w-0">
                <Link
                  to={`/prontuario/${a.nro_reg}`}
                  className="font-medium text-primary-700 hover:underline"
                >
                  {a.apelido ?? `#${a.nro_reg}`}
                </Link>
                <span className="text-gray-400"> · {a.especie_nome_comum}</span>
                <p className="truncate text-xs text-gray-500">
                  {a.recinto_atual_nome ?? "Sem recinto atual"}
                  {" · "}
                  {a.ultimo_peso != null ? `${a.ultimo_peso} kg` : "peso n/d"}
                  {" · "}triagem {a.data_ultima_triagem}
                </p>
              </div>
              <span className="flex shrink-0 items-center gap-1 rounded-full bg-warning-50 px-2 py-0.5 text-xs font-medium text-warning-600">
                <AlertTriangle className="h-3 w-3" />
                {a.gravidade_veterinaria}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
