"use client";

import { useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";

export default function LoginForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [mensaje, setMensaje] = useState("");
  const [cargando, setCargando] = useState(false);

  async function iniciarSesion(event) {
    event.preventDefault();
    if (cargando) return;

    setCargando(true);
    setMensaje("");

    try {
      const supabase = createClient();

      const { error } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password,
      });

      if (error) {
        setMensaje("Correo electrónico o contraseña incorrectos.");
        return;
      }

      setPassword("");
      setMensaje("Sesión iniciada correctamente.");
    } catch {
      setMensaje("No se pudo conectar con el servicio de autenticación.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <form onSubmit={iniciarSesion} className="registro-form">
      <label>
        Correo electrónico
        <input
          required
          type="email"
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </label>

      <label>
        Contraseña
        <input
          required
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </label>

      <button type="submit" disabled={cargando}>
        {cargando ? "Ingresando..." : "Iniciar sesión"}
      </button>

      {mensaje && <p role="status">{mensaje}</p>}

      <p>
        ¿Todavía no tenés cuenta?{" "}
        <Link href="/registro">Registrate acá</Link>
      </p>
    </form>
  );
}
