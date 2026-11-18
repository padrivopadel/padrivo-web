
export default function Footer() {
  return (
    <footer className="site-footer">
      <div className="container">
        <div className="footer-top">
          <div>
            <a
              href="#inicio"
              className="footer-brand brand brand-new"
              aria-label="Padrivo Pádel, volver al inicio"
            >
              <svg
                className="brand-mark"
                viewBox="0 0 64 64"
                aria-hidden="true"
              >
                <path
                  d="M8 49 27 16c8-11 26-11 30 2 4 14-10 26-27 24L17 57l4-22 18-17"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="7"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
                <circle cx="43" cy="23" r="6" fill="currentColor" />
              </svg>

              <span className="brand-word">
                PADRIVO
                <small>PÁDEL</small>
              </span>
            </a>

            <p>Más pádel. Mejores historias.</p>
          </div>

          <a href="#inicio" className="back-to-top">
            VOLVER ARRIBA ↑
          </a>
        </div>

        <div className="footer-bottom">
          <span>© {new Date().getFullYear()} PADRIVO PÁDEL</span>
          <span>COMUNIDAD QUE JUEGA.</span>
        </div>
      </div>
    </footer>
  );
}
