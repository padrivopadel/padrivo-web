import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import BrandValues from "@/components/BrandValues";
import HowWorks from "@/components/HowWorks";
import TournamentCard from "@/components/TournamentCard";
import Ranking from "@/components/Ranking";
import Organizer from "@/components/Organizer";
import Footer from "@/components/Footer";

export default function Home() {
  return <main>
    <Navbar />
    <Hero />
    <BrandValues />
    <HowWorks />
    <section className="section tournaments-section" id="torneos">
      <div className="container">
        <div className="section-heading"><div><p className="section-kicker">/ ENTRÁ EN JUEGO</p><h2>TORNEOS QUE<br /><span className="accent">SE HACEN SENTIR.</span></h2></div><p>Elegí tu próximo desafío y viví la competencia desde adentro.</p></div>
        <div className="tournaments-grid">
          <TournamentCard title="Open Primavera PADRIVO" category="6ta categoría" location="Resistencia" index={0} />
          <TournamentCard title="Copa Sunset" category="5ta categoría" location="Corrientes" index={1} />
          <TournamentCard title="Torneo Aniversario" category="7ma categoría" location="Posadas" index={2} />
        </div>
      </div>
    </section>
    <Ranking />
    <Organizer />
    <Footer />
  </main>;
}
