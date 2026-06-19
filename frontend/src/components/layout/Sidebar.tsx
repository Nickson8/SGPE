import { NavLink } from "react-router-dom";
import { LayoutDashboard, Home, Stethoscope, Warehouse, Leaf } from "lucide-react";

const links = [
  { to: "/", label: "Início", icon: Home, end: true },
  { to: "/dashboard", label: "Dashboard", icon: LayoutDashboard, end: false },
  { to: "/prontuario", label: "Prontuário", icon: Stethoscope, end: false },
  { to: "/recintos", label: "Recintos", icon: Warehouse, end: false },
];

export function Sidebar() {
  return (
    <aside className="flex w-60 flex-col border-r border-gray-200 bg-white">
      <div className="flex items-center gap-2 px-6 py-5">
        <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary-600 text-white">
          <Leaf className="h-5 w-5" />
        </div>
        <div>
          <p className="text-lg font-extrabold leading-none text-gray-900">SGPE</p>
          <p className="text-xs text-gray-500">Parques Ecológicos</p>
        </div>
      </div>

      <nav className="flex flex-1 flex-col gap-1 px-3 py-2">
        {links.map(({ to, label, icon: Icon, end }) => (
          <NavLink
            key={to}
            to={to}
            end={end}
            className={({ isActive }) =>
              `flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors ${
                isActive
                  ? "bg-primary-50 text-primary-700"
                  : "text-gray-600 hover:bg-gray-100 hover:text-gray-900"
              }`
            }
          >
            <Icon className="h-5 w-5" />
            {label}
          </NavLink>
        ))}
      </nav>

      <div className="px-6 py-4 text-xs text-gray-400">
        🌿 Conservação da biodiversidade
      </div>
    </aside>
  );
}
