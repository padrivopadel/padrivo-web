const players = [
  { position: "01", name: "Martín López", points: "1.250", medal: "●" },
  { position: "02", name: "Juan Pérez", points: "1.180", medal: "●" },
  { position: "03", name: "Lucas Díaz", points: "1.100", medal: "●" },
];
export default function Ranking() {
  return <section className="section ranking-section" id="ranking"><div className="container ranking-layout"><div className="ranking-intro"><p className="section-kicker">/ CADA PUNTO CUENTA</p><h2>EL RANKING<br /><span className="accent">NO MIENTE.</span></h2><p>La competencia nos impulsa. Conocé a quienes están dejando su marca en la cancha.</p><span className="ranking-note">CLASIFICACIÓN DE EJEMPLO</span></div><div className="ranking-board"><div className="ranking-board-header"><span>RANKING PADRIVO</span><span>TOP 03 <span className="accent">●</span></span></div>{players.map(p => <div className="ranking-row" key={p.position}><span className="ranking-position">{p.position}</span><span className="ranking-avatar" aria-hidden="true">{p.name.split(" ").map(n => n[0]).join("")}</span><span className="ranking-name">{p.name}</span><span className="ranking-points">{p.points} <small>PTS</small></span></div>)}<div className="ranking-board-footer">LA CANCHA DEFINE TODO <span aria-hidden="true">↗</span></div></div></div></section>;
}
