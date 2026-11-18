import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import CerrarSesionButton from "./CerrarSesionButton";

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
    .select("nombre, apellido, rol")
    .eq("id", data.user.id)
    .single();

  if (perfilError || !perfil || perfil.rol !== "jugador") {
    redirect("/");
  }

  const nombreCompleto =
    [perfil.nombre, perfil.apellido].filter(Boolean).join(" ") ||
    "Jugador";

  return (
    <main className="container">
      <section className="section jugador-dashboard">
        <div className="jugador-header">
          <div>
            <p className="section-kicker">/ MI PADRIVO</p>
            <h1>Hola, {nombreCompleto}.</h1>
            <p>
              Tu espacio para vivir el pádel dentro y fuera de la cancha.
            </p>
          </div>

          <CerrarSesionButton />
        </div>

        <div className="jugador-grid">
          <article className="jugador-card jugador-card-profile">
            <span className="jugador-card-label">01 / MI CUENTA</span>
            <h2>Mi perfil</h2>
            <div className="jugador-avatar" aria-hidden="true">
              {nombreCompleto.charAt(0).toUpperCase()}
            </div>
            <p className="jugador-profile-name">{nombreCompleto}</p>
            <p className="jugador-profile-email">{data.user.email}</p>
            <span className="jugador-role">JUGADOR</span>
          </article>

          <article className="jugador-card">
            <span className="jugador-card-label">02 / COMPETICIÓN</span>
            <h2>Mis torneos</h2>
            <div className="jugador-card-symbol" aria-hidden="true">◎</div>
            <h3>Tu próxima competencia empieza acá.</h3>
            <p>
              Próximamente podrás consultar tus inscripciones
              y torneos desde este espacio.
            </p>
            <span className="jugador-coming-soon">PRÓXIMAMENTE</span>
          </article>

          <article className="jugador-card">
            <span className="jugador-card-label">03 / RENDIMIENTO</span>
            <h2>Mi actividad</h2>
            <div className="jugador-card-symbol" aria-hidden="true">↗</div>
            <h3>Cada partido cuenta.</h3>
            <p>
              Acá podrás seguir tus partidos, resultados
              y estadísticas cuando estén disponibles.
            </p>
            <span className="jugador-coming-soon">PRÓXIMAMENTE</span>
          </article>
        </div>
      </section>
    </main>
  );
}
