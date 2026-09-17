import Navbar from "@/components/Navbar";
import Hero from "@/components/Hero";
import BrandValues from "@/components/BrandValues";
import HowWorks from "@/components/HowWorks";
import TournamentCard from "@/components/TournamentCard";
import Ranking from "@/components/Ranking";
import Organizer from "@/components/Organizer";
import Footer from "@/components/Footer";

export default function Home(){
 return (
  <main>
   <Navbar/>
   <Hero/>
   <BrandValues/>
   <HowWorks/>
   <section className="section">
    <h2>Torneos destacados</h2>
    <div className="grid">
     <TournamentCard title="Open Primavera PADRIVO" category="6ta categoría" location="Resistencia"/>
     <TournamentCard title="Copa Sunset" category="5ta categoría" location="Corrientes"/>
     <TournamentCard title="Torneo Aniversario" category="7ma categoría" location="Posadas"/>
    </div>
   </section>
   <Ranking/>
   <Organizer/>
   <Footer/>
  </main>
 )
}
