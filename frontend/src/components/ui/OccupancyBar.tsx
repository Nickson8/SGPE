interface OccupancyBarProps {
  percentual: number;
  status: string; // 'normal' | 'alerta' | 'critico'
}

const colors: Record<string, string> = {
  normal: "bg-success-500",
  alerta: "bg-warning-500",
  critico: "bg-danger-500",
};

export function OccupancyBar({ percentual, status }: OccupancyBarProps) {
  return (
    <div className="h-2.5 w-full overflow-hidden rounded-full bg-gray-200">
      <div
        className={`h-full rounded-full ${colors[status] ?? "bg-primary-500"}`}
        style={{ width: `${Math.min(percentual, 100)}%` }}
      />
    </div>
  );
}
