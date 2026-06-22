import { RouterProvider } from "react-router-dom";
import { router } from "./router";
import { MockUserProvider } from "./contexts/MockUserContext";

export default function App() {
  return (
    <MockUserProvider>
      <RouterProvider router={router} />
    </MockUserProvider>
  );
}
