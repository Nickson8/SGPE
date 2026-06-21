export function Spinner() {
  return (
    <div className="flex h-full min-h-[200px] w-full items-center justify-center">
      <div className="h-8 w-8 animate-spin rounded-full border-b-2 border-primary-600" />
    </div>
  );
}
