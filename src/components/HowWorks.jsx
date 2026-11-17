const steps = [
  { number: "01", title: "ENCONTRÁ", text: "Descubrí torneos para tu categoría." },
  { number: "02", title: "INSCRIBITE", text: "Elegí dónde querés competir." },
  { number: "03", title: "COMPETÍ", text: "Viví cada punto dentro de la cancha." },
  { number: "04", title: "EVOLUCIONÁ", text: "Seguí tu progreso en el ranking." },
];
export default function HowWorks() {
  return <section className="section how-section" id="como-funciona"><div className="container"><div className="section-heading"><div><p className="section-kicker">/ ASÍ SE JUEGA</p><h2>DEL PRIMER PUNTO<br /><span className="accent">A TU MEJOR VERSIÓN.</span></h2></div><p>Una forma más simple de vivir el pádel, desde la inscripción hasta el último punto.</p></div><div className="steps-grid">{steps.map(s => <article className="step-card" key={s.number}><span className="step-number">{s.number}</span><div><h3>{s.title}</h3><p>{s.text}</p></div><span className="step-arrow" aria-hidden="true">↗</span></article>)}</div></div></section>;
}
