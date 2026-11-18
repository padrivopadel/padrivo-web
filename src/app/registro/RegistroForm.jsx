"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

export default function RegistroForm() {
  const [nombre, setNombre] = useState("");
  const [apellido, setApellido] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [mensaje, setMensaje] = useState("");
  const [cargando, setCargando] = useState(false);

  async function registrar(event) {
    event.preventDefault();
    if (cargando) return;

    setCargando(true);
    setMensaje("");

    try {
      const supabase = createClient();

      const { data, error } = await supabase.auth.signUp({
        email: email.trim(),
        password,
        options: {
          data: {
            nombre: nombre.trim(),
            apellido: apellido.trim(),
          },
        },
      });

      if (error) {
        setMensaje("No se pudo completar el registro. Revisá los datos e intentá nuevamente.");
        return;
      }

      setMensaje(
        data.session
          ? "Cuenta creada correctamente."
          : "Solicitud recibida. Revisá tu correo para confirmar la cuenta."
      );
    } catch {
      setMensaje("No se pudo conectar con el servicio de autenticación.");
    } finally {
      setCargando(false);
    }
  }

  return (
    <form onSubmit={registrar} className="registro-form">
      <label>
        Nombre
        <input required maxLength={100} value={nombre}
          onChange={(e) => setNombre(e.target.value)} />
      </label>

      <label>
        Apellido
        <input required maxLength={100} value={apellido}
          onChange={(e) => setApellido(e.target.value)} />
      </label>

      <label>
        Correo electrónico
        <input required type="email" autoComplete="email"
          value={email} onChange={(e) => setEmail(e.target.value)} />
      </label>

      <label>
        Contraseña
        <input required type="password" minLength={8}
          autoComplete="new-password" value={password}
          onChange={(e) => setPassword(e.target.value)} />
      </label>

      <button type="submit" disabled={cargando}>
        {cargando ? "Creando cuenta..." : "Crear cuenta"}
      </button>

      {mensaje && <p role="status">{mensaje}</p>}
    </form>
  );
}
