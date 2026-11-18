
const details = [
  {
    eyebrow: "OPEN / PRIMAVERA",
    tone: "court",
    badge: "RESISTENCIA",
  },
  {
    eyebrow: "COPA / SUNSET",
    tone: "sunset",
    badge: "CORRIENTES",
  },
  {
    eyebrow: "TOUR / ANIVERSARIO",
    tone: "night",
    badge: "POSADAS",
  },
];

export default function TournamentCard({
  title,
  category,
  location,
  index = 0,
}) {
  const d = details[index % details.length];

  return (
    <article className="tournament-card tournament-card-pro">
      <div
        className={`tournament-art tournament-art-pro tournament-theme-${d.tone}`}
        role="img"
        aria-label={`Gráfica ilustrativa de pádel para ${title}`}
      >
        <span className="tournament-art-label">
          PADRIVO <span className="art-slash">/</span> TOUR
        </span>

        <span
          className="tournament-scene-court"
          aria-hidden="true"
        />

        <span
          className="tournament-scene-ball"
          aria-hidden="true"
        />

        <span className="tournament-scene-name">
          {d.eyebrow}
        </span>

        <span className="tournament-art-index">
          0{index + 1}
        </span>
      </div>

      <div className="tournament-body">
        <div className="tournament-card-overline">
          <span className="tournament-tag">
            TORNEO ILUSTRATIVO
          </span>

          <span className="tournament-location-pill">
            {d.badge}
          </span>
        </div>

        <h3>{title}</h3>

        <div className="tournament-meta">
          <span>⌖ {location}</span>
          <span>◈ {category}</span>
        </div>

        <div className="tournament-bottom">
          <span>PRÓXIMAMENTE · SIN INSCRIPCIONES</span>
          <span aria-hidden="true">↗</span>
        </div>
      </div>
    </article>
  );
}
