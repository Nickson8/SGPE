import { useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { Plus, Search } from "lucide-react";
import { api } from "../lib/api";
import type { RecintoCreate, RecintoResumo } from "../types";
import { Modal } from "../components/ui/Modal";
import { OccupancyBar } from "../components/ui/OccupancyBar";
import { Spinner } from "../components/ui/Spinner";

const EMPTY_FORM: RecintoCreate = { recinto_gefau: "", nome: "", capacidade_max: 1 };

export function RecintosSelecaoPage() {
  const [query, setQuery] = useState("");
  const [recintos, setRecintos] = useState<RecintoResumo[]>([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState<RecintoCreate>(EMPTY_FORM);
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const refreshRef = useRef<() => void>(() => {});

  const fetchRecintos = (q: string) => {
    setLoading(true);
    api
      .get<RecintoResumo[]>("/recintos", { params: q ? { q } : {} })
      .then((r) => setRecintos(r.data))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    refreshRef.current = () => fetchRecintos(query);
  }, [query]);

  useEffect(() => {
    const t = setTimeout(() => fetchRecintos(query), 250);
    return () => clearTimeout(t);
  }, [query]);

  const openModal = () => {
    setForm(EMPTY_FORM);
    setFormError(null);
    setShowModal(true);
  };

  const closeModal = () => setShowModal(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setFormError(null);
    try {
      await api.post("/recintos", form);
      closeModal();
      fetchRecintos(query);
    } catch (err: unknown) {
      const detail =
        (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail;
      setFormError(detail ?? "Erro ao cadastrar recinto.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="mx-auto max-w-5xl space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Recintos</h1>
          <p className="mt-1 text-gray-500">Ocupação e detalhes dos recintos do parque.</p>
        </div>
        <button
          onClick={openModal}
          className="flex items-center gap-2 rounded-xl bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
        >
          <Plus className="h-4 w-4" />
          Novo Recinto
        </button>
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

      {showModal && (
        <Modal title="Novo Recinto" onClose={closeModal}>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                Código GEFAU
              </label>
              <input
                required
                maxLength={30}
                value={form.recinto_gefau}
                onChange={(e) => setForm((f) => ({ ...f, recinto_gefau: e.target.value }))}
                placeholder="ex: REC-001"
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-primary-400 focus:ring-2 focus:ring-primary-100"
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">Nome</label>
              <input
                required
                maxLength={50}
                value={form.nome}
                onChange={(e) => setForm((f) => ({ ...f, nome: e.target.value }))}
                placeholder="ex: Recinto dos Felinos"
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-primary-400 focus:ring-2 focus:ring-primary-100"
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                Capacidade Máxima
              </label>
              <input
                required
                type="number"
                min={1}
                value={form.capacidade_max}
                onChange={(e) =>
                  setForm((f) => ({ ...f, capacidade_max: Number(e.target.value) }))
                }
                className="w-full rounded-xl border border-gray-200 px-3 py-2 text-sm outline-none focus:border-primary-400 focus:ring-2 focus:ring-primary-100"
              />
            </div>

            {formError && (
              <p className="rounded-lg bg-danger-50 px-3 py-2 text-sm text-danger-600">
                {formError}
              </p>
            )}

            <div className="flex justify-end gap-3 pt-1">
              <button
                type="button"
                onClick={closeModal}
                className="rounded-xl border border-gray-200 px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={submitting}
                className="rounded-xl bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-60"
              >
                {submitting ? "Salvando…" : "Cadastrar"}
              </button>
            </div>
          </form>
        </Modal>
      )}
    </div>
  );
}
