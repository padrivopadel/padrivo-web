export default function Hero() {
  return (
    <section className="hero" id="inicio" aria-labelledby="hero-title">
      <div className="hero-glow" aria-hidden="true"></div>
      <div className="hero-court" aria-hidden="true"><div className="court-net"></div><div className="court-center"></div></div>
      <div className="container hero-content">
        <div className="eyebrow"><span className="eyebrow-dot"></span> LA NUEVA ERA DEL PÁDEL</div>
        <h1 id="hero-title">TU PRÓXIMO<br /><span className="hero-outline">PARTIDO</span><br /><span className="accent">EMPIEZA ACÁ.</span></h1>
        <p className="hero-description">Encontrá torneos, competí y evolucioná dentro de la comunidad de pádel. Todo empieza en la cancha.</p>
        <div className="hero-actions"><a className="button button-primary" href="#torneos">Explorar torneos <span aria-hidden="true">↗</span></a><a className="button button-secondary" href="#como-funciona">Conocé Padrivo <span aria-hidden="true">↓</span></a></div>
        <div className="hero-bottom"><span>COMPETÍ. CONECTÁ. CRECÉ.</span><span>01 / EL JUEGO COMIENZA</span></div>
      </div>
    </section>
  );
}
