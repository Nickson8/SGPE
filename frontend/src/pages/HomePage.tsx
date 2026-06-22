import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { LayoutDashboard, Stethoscope, Warehouse } from "lucide-react";
import { api } from "../lib/api";
import type { Dashboard } from "../types";

const features = [
  {
    to: "/dashboard",
    title: "Dashboard de Conservação",
    desc: "Indicadores do plantel: taxonomia, sexo, planos de manejo e ocupação dos recintos.",
    icon: LayoutDashboard,
  },
  {
    to: "/prontuario",
    title: "Prontuário Digital",
    desc: "Histórico clínico e biológico por animal, com evolução de peso e score corporal.",
    icon: Stethoscope,
  },
  {
    to: "/recintos",
    title: "Recintos",
    desc: "Ocupação dos recintos, animais alocados e histórico de movimentações.",
    icon: Warehouse,
  },
];

export function HomePage() {
  const [totais, setTotais] = useState<Dashboard["totais"] | null>(null);

  useEffect(() => {
    api
      .get<Dashboard>("/dashboard")
      .then((r) => setTotais(r.data.totais))
      .catch(() => setTotais(null));
  }, []);

  return (
    <div className="mx-auto max-w-5xl space-y-8">
      <div className="rounded-3xl bg-gradient-to-br from-primary-600 to-primary-800 p-8 text-white">
        <h1 className="text-3xl font-extrabold">🌿 SGPE</h1>
        <p className="mt-2 max-w-2xl text-primary-50">
          Sistema de Gestão para Parques Ecológicos — centraliza informações de fauna,
          recintos e prontuários veterinários em uma plataforma integrada e rastreável.
        </p>
        {totais && (
          <div className="mt-6 flex flex-wrap gap-8">
            <div>
              <p className="text-3xl font-bold">{totais.animais}</p>
              <p className="text-sm text-primary-100">Animais</p>
            </div>
            <div>
              <p className="text-3xl font-bold">{totais.especies}</p>
              <p className="text-sm text-primary-100">Espécies</p>
            </div>
            <div>
              <p className="text-3xl font-bold">{totais.recintos}</p>
              <p className="text-sm text-primary-100">Recintos</p>
            </div>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        {features.map(({ to, title, desc, icon: Icon }) => (
          <Link
            key={to}
            to={to}
            className="group rounded-2xl border border-gray-200 bg-white p-6 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md"
          >
            <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-primary-50 text-primary-600 group-hover:bg-primary-100">
              <Icon className="h-6 w-6" />
            </div>
            <h2 className="text-lg font-bold text-gray-900">{title}</h2>
            <p className="mt-1 text-sm text-gray-500">{desc}</p>
          </Link>
        ))}
      </div>
    </div>
  );
}
