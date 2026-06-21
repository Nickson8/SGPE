import axios from "axios";

// Sem autenticação nesta versão (usuário mock). Apenas o cliente HTTP base.
export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:8000/api",
  headers: { "Content-Type": "application/json" },
});
