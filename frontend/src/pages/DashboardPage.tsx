import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { PawPrint, Leaf, Warehouse, AlertTriangle } from "lucide-react";
import {
  Bar,
  BarChart,
  Cell,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { api } from "../lib/api";
import type { Dashboard } from "../types";
import { ConsultaAlertaCard } from "../components/dashboard/ConsultaAlertaCard";
import { KpiCard } from "../components/ui/KpiCard";
import { OccupancyBar } from "../components/ui/OccupancyBar";
import { Spinner } from "../components/ui/Spinner";

const PIE_COLORS = ["#059669", "#34d399", "#f59e0b", "#64748b", "#0ea5e9", "#a78bfa"];

export function DashboardPage() {
  const [data, setData] = useState<Dashboard | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api
      .get<Dashboard>("/dashboard")
      .then((r) => setData(r.data))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <Spinner />;
  if (!data) return <p className="text-gray-500">Não foi possível carregar o dashboard.</p>;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard de Conservação</h1>
        <p className="mt-1 text-gray-500">Indicadores em tempo real do plantel.</p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard title="Animais" value={data.totais.animais} icon={<PawPrint className="h-5 w-5" />} />
        <KpiCard title="Espécies" value={data.totais.especies} icon={<Leaf className="h-5 w-5" />} />
        <KpiCard
          title="Com plano de manejo"
          value={`${data.totais.pct_com_plano}%`}
          subtitle={`${data.totais.especies_com_plano} de ${data.totais.especies} espécies`}
          icon={<Leaf className="h-5 w-5" />}
          variant="success"
        />
        <KpiCard
          title="Recintos em alerta"
          value={data.totais.recintos_alerta}
          subtitle={`de ${data.totais.recintos} recintos`}
          icon={<AlertTriangle className="h-5 w-5" />}
          variant={data.totais.recintos_alerta > 0 ? "warning" : "default"}
        />
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-sm font-semibold text-gray-700">Animais por grupo taxonômico</h2>
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={data.grupo_taxonomico}>
              <XAxis dataKey="label" tick={{ fontSize: 12 }} />
              <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
              <Tooltip />
              <Bar dataKey="count" fill="#059669" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-sm font-semibold text-gray-700">Distribuição por sexo</h2>
          <ResponsiveContainer width="100%" height={260}>
            <PieChart>
              <Pie
                data={data.sexo}
                dataKey="count"
                nameKey="label"
                innerRadius={60}
                outerRadius={100}
                paddingAngle={2}
                label={(e) => `${e.label}: ${e.count}`}
              >
                {data.sexo.map((_, i) => (
                  <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 text-sm font-semibold text-gray-700">Capacidade dos recintos</h2>
          <div className="space-y-3">
            {data.recintos_capacidade.map((r) => (
              <Link
                key={r.gefau}
                to={`/recintos/${r.gefau}`}
                className="block rounded-lg p-2 transition-colors hover:bg-gray-50"
              >
                <div className="mb-1 flex items-center justify-between text-sm">
                  <span className="font-medium text-gray-700">{r.nome}</span>
                  <span className="text-gray-500">
                    {r.ocupacao}/{r.capacidade} ({r.percentual}%)
                  </span>
                </div>
                <OccupancyBar percentual={r.percentual} status={r.status} />
              </Link>
            ))}
          </div>
        </div>

        <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
          <h2 className="mb-4 flex items-center gap-2 text-sm font-semibold text-gray-700">
            <Warehouse className="h-4 w-4" /> Últimas alocações
          </h2>
          <div className="divide-y divide-gray-100">
            {data.ultimas_alocacoes.map((a, i) => (
              <div key={i} className="flex items-center justify-between py-2.5 text-sm">
                <div>
                  <Link to={`/prontuario/${a.nro_reg}`} className="font-medium text-primary-700 hover:underline">
                    {a.apelido ?? `#${a.nro_reg}`}
                  </Link>
                  <span className="text-gray-400"> · {a.especie_nome_comum}</span>
                </div>
                <div className="text-right text-gray-500">
                  <p>{a.recinto_nome}</p>
                  <p className="text-xs">{a.data_entrada}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <ConsultaAlertaCard />
    </div>
  );
}
