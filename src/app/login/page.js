import LoginForm from "./LoginForm";

export const metadata = {
  title: "Iniciar sesión | PADRIVO PÁDEL",
  description: "Ingresá a tu cuenta de PADRIVO PÁDEL.",
};

export default function LoginPage() {
  return (
    <main className="container">
      <section className="section">
        <p className="section-kicker">/ BIENVENIDO DE NUEVO</p>
        <h1>Iniciá sesión.</h1>
        <p>Volvé a la cancha. Tu cuenta te espera.</p>
        <LoginForm />
      </section>
    </main>
  );
}
