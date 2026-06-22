import type { ReactNode } from "react";

interface KpiCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon?: ReactNode;
  variant?: "default" | "success" | "warning" | "danger";
}

const variants = {
  default: { bg: "bg-white", iconBg: "bg-primary-50", iconColor: "text-primary-600" },
  success: { bg: "bg-success-50", iconBg: "bg-success-100", iconColor: "text-success-600" },
  warning: { bg: "bg-warning-50", iconBg: "bg-warning-100", iconColor: "text-warning-600" },
  danger: { bg: "bg-danger-50", iconBg: "bg-danger-100", iconColor: "text-danger-600" },
};

export function KpiCard({ title, value, subtitle, icon, variant = "default" }: KpiCardProps) {
  const s = variants[variant];
  return (
    <div className={`flex flex-col rounded-2xl border border-gray-200 p-5 shadow-sm ${s.bg}`}>
      <div className="mb-4 flex items-start justify-between">
        <h3 className="text-sm font-semibold text-gray-500">{title}</h3>
        {icon && (
          <div className={`flex h-9 w-9 items-center justify-center rounded-xl ${s.iconBg} ${s.iconColor}`}>
            {icon}
          </div>
        )}
      </div>
      <span className="text-3xl font-bold text-gray-900">{value}</span>
      {subtitle && <p className="mt-1 text-sm text-gray-500">{subtitle}</p>}
    </div>
  );
}
