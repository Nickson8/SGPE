import { createContext, useContext } from "react";
import type { ReactNode } from "react";

// Esta versão não possui autenticação. Mantemos um usuário fictício, igual
// ao app Django original, apenas para exibir nome/função na barra superior.
export interface MockUser {
  name: string;
  role: string;
  initials: string;
}

const MOCK_USER: MockUser = {
  name: "Dra. Marina Silva",
  role: "Veterinária",
  initials: "MS",
};

const MockUserContext = createContext<MockUser>(MOCK_USER);

export function MockUserProvider({ children }: { children: ReactNode }) {
  return (
    <MockUserContext.Provider value={MOCK_USER}>
      {children}
    </MockUserContext.Provider>
  );
}

export function useMockUser() {
  return useContext(MockUserContext);
}
