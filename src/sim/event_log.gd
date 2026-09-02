class_name EventLog
extends RefCounted

# =============================================================
# LE JOURNAL.
# Tout ce qui se produit pendant un combat passe par ici.
# Les ecrans de statistiques, les chiffres flottants, l'historique de saison
# et le codex se construiront tous a partir de cette seule liste.
# Regle : la simulation ecrit, personne d'autre.
# =============================================================

const WINDUP := "windup"
const DAMAGE := "damage"
const MISS := "miss"
const KILL := "kill"
const END := "end"

var entries: Array = []


func add(tick: int, type: String, source: int, target: int, value: float = 0.0) -> void:
	entries.append({
		"tick": tick,
		"type": type,
		"source": source,
		"target": target,
		"value": value,
	})


func clear() -> void:
	entries.clear()


func size() -> int:
	return entries.size()


# Renvoie les evenements ajoutes depuis un index donne.
# C'est ce que l'affichage utilise pour fabriquer les chiffres flottants
# sans jamais interroger la simulation directement.
func since(index: int) -> Array:
	if index >= entries.size():
		return []
	return entries.slice(index)
