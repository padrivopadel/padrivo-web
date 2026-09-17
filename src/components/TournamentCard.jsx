export default function TournamentCard({title,category,location}){
return <div className="card"><h3>{title}</h3><p>📍 {location}</p><p>🎾 {category}</p><p>🏆 Paletas · Bolsos · Remeras</p></div>
}
