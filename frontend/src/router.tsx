import { createBrowserRouter } from "react-router-dom";
import { AppShell } from "./components/layout/AppShell";
import { HomePage } from "./pages/HomePage";
import { DashboardPage } from "./pages/DashboardPage";
import { AnimaisSelecaoPage } from "./pages/AnimaisSelecaoPage";
import { AnimalDetalhesPage } from "./pages/AnimalDetalhesPage";
import { RecintosSelecaoPage } from "./pages/RecintosSelecaoPage";
import { RecintoDetalhesPage } from "./pages/RecintoDetalhesPage";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppShell />,
    children: [
      { index: true, element: <HomePage /> },
      { path: "dashboard", element: <DashboardPage /> },
      { path: "prontuario", element: <AnimaisSelecaoPage /> },
      { path: "prontuario/:nroReg", element: <AnimalDetalhesPage /> },
      { path: "recintos", element: <RecintosSelecaoPage /> },
      { path: "recintos/:gefau", element: <RecintoDetalhesPage /> },
    ],
  },
]);
