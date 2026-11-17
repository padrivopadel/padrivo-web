"use client";
import { useState } from "react";

const links = [
  { label: "Torneos", href: "#torneos" },
  { label: "Cómo funciona", href: "#como-funciona" },
  { label: "Organizadores", href: "#organizadores" },
  { label: "Ranking", href: "#ranking" },
  { label: "Comunidad", href: "#comunidad" },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  return (
    <header className="site-header">
      <nav className="nav-shell container" aria-label="Navegación principal">
        <a href="#inicio" className="brand" onClick={() => setOpen(false)} aria-label="Padrivo Pádel, inicio">
          <span className="brand-symbol" aria-hidden="true">◢</span>
          <span>PADRIVO<span className="brand-sub">PÁDEL</span></span>
        </a>
        <button className="menu-toggle" type="button" aria-label={open ? "Cerrar menú" : "Abrir menú"} aria-expanded={open} aria-controls="primary-links" onClick={() => setOpen(!open)}>
          <span></span><span></span><span></span>
        </button>
        <div id="primary-links" className={`nav-links ${open ? "is-open" : ""}`}>
          {links.map(link => <a key={link.href} href={link.href} onClick={() => setOpen(false)}>{link.label}</a>)}
          <a className="nav-cta" href="#comunidad" onClick={() => setOpen(false)}>Sumate a Padrivo <span aria-hidden="true">↗</span></a>
        </div>
      </nav>
    </header>
  );
}
