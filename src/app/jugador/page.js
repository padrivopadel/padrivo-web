import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export const metadata = {
  title: "Mi cuenta | PADRIVO PÁDEL",
};

export default async function JugadorPage() {
  const supabase = await createClient();

  const { data, error } = await supabase.auth.getUser();

  if (error || !data.user) {
    redirect("/login");
  }

  const { data: perfil, error: perfilError } = await supabase
    .from("profiles")
    .select("rol")
    .eq("id", data.user.id)
    .single();

  if (perfilError || !perfil || perfil.rol !== "jugador") {
    redirect("/");
  }

  return (
    <main className="container">
      <section className="section">
        <p className="section-kicker">/ MI PADRIVO</p>
        <h1>Mi cuenta.</h1>
        <p>Bienvenido a tu espacio personal de PADRIVO PÁDEL.</p>
        <p>Tu sesión está activa.</p>
      </section>
    </main>
  );
}
