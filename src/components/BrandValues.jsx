const values = [
  { num: "01", icon: "✦", title: "PREMIUM", text: "Calidad en cada detalle." },
  { num: "02", icon: "↗", title: "COMPETITIVO", text: "Evolucioná en la cancha." },
  { num: "03", icon: "◈", title: "MODERNO", text: "Tecnología que conecta." },
  { num: "04", icon: "◎", title: "COMUNIDAD", text: "Más que partidos." },
];
export default function BrandValues() {
  return <section className="values-section" id="comunidad"><div className="container values-grid">{values.map(v => <article className="value-card" key={v.num}><div className="value-top"><span>{v.num} / 04</span><span className="value-icon" aria-hidden="true">{v.icon}</span></div><h3>{v.title}</h3><p>{v.text}</p></article>)}</div></section>;
}
