"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

export default function CerrarSesionButton() {
  const router = useRouter();
  const [cerrando, setCerrando] = useState(false);
  const [error, setError] = useState("");

  async function cerrarSesion() {
    setCerrando(true);
    setError("");

    try {
      const supabase = createClient();
      const { error: signOutError } = await supabase.auth.signOut();

      if (signOutError) {
        throw signOutError;
      }

      router.replace("/login");
      router.refresh();
    } catch {
      setError("No se pudo cerrar la sesión. Intentá nuevamente.");
      setCerrando(false);
    }
  }

  return (
    <div>
      <button
        type="button"
        onClick={cerrarSesion}
        disabled={cerrando}
        className="jugador-logout"
        style={{ cursor: cerrando ? "wait" : "pointer" }}
      >
        {cerrando ? "Cerrando sesión..." : "Cerrar sesión"}
      </button>

      {error && (
        <p role="alert" style={{ color: "#ff9b9b", marginTop: "12px" }}>
          {error}
        </p>
      )}
    </div>
  );
}

