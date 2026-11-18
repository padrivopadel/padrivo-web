import RegistroForm from "./RegistroForm";

export const metadata = {
  title: "Registro | PADRIVO PÁDEL",
  description: "Creá tu cuenta de jugador en PADRIVO PÁDEL.",
};

export default function RegistroPage() {
  return (
    <main className="container">
      <section className="section">
        <p className="section-kicker">/ SUMATE A PADRIVO</p>
        <h1>Creá tu cuenta.</h1>
        <p>Tu próximo partido empieza acá.</p>

        <RegistroForm />
      </section>
    </main>
  );
}
