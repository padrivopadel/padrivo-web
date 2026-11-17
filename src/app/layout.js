import "./globals.css";

export const metadata = {
  title: "Padrivo Pádel | Tu próximo partido empieza acá",
  description: "Torneos, ranking y comunidad de pádel. Competí, conectá y evolucioná con Padrivo.",
};

export default function RootLayout({ children }) {
  return <html lang="es" className="h-full antialiased"><body className="min-h-full flex flex-col">{children}</body></html>;
}
