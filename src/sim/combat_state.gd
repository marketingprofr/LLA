class_name CombatState
extends RefCounted

# =============================================================
# L'ETAT COMPLET D'UN COMBAT A UN INSTANT DONNE.
# Les systemes recoivent cet objet, le lisent et le modifient.
# Les fonctions ci-dessous sont des REQUETES, pas des decisions :
# elles repondent a "qui est proche", jamais a "que dois-je faire".
# =============================================================

var config: CombatConfig
var fighters: Array = []          # de CombatFighter
var tick: int = 0
var rng := RandomNumberGenerator.new()
var event_log := EventLog.new()

var is_over: bool = false
var winner: int = -1              # 0, 1, ou -1 pour egalite


func _init(cfg: CombatConfig = null) -> void:
	config = cfg if cfg != null else CombatConfig.new()


func get_fighter(id: int) -> CombatFighter:
	if id < 0 or id >= fighters.size():
		return null
	return fighters[id]


# Distance entre deux corps, bord a bord. C'est toujours celle-ci qu'on veut,
# jamais la distance entre les centres.
func gap(a: CombatFighter, b: CombatFighter) -> float:
	return a.pos.distance_to(b.pos) - config.radius - config.radius


func enemies_of(f: CombatFighter, only_alive: bool = true) -> Array:
	var out: Array = []
	for other in fighters:
		if other.team == f.team:
			continue
		if only_alive and not other.alive:
			continue
		out.append(other)
	return out


func allies_of(f: CombatFighter, include_self: bool = false, only_alive: bool = true) -> Array:
	var out: Array = []
	for other in fighters:
		if other.team != f.team:
			continue
		if not include_self and other.id == f.id:
			continue
		if only_alive and not other.alive:
			continue
		out.append(other)
	return out


func nearest(f: CombatFighter, candidates: Array) -> CombatFighter:
	var best: CombatFighter = null
	var best_dist := INF
	for c in candidates:
		var d: float = f.pos.distance_to(c.pos)
		if d < best_dist:
			best_dist = d
			best = c
	return best


func alive_count(team: int) -> int:
	var n := 0
	for f in fighters:
		if f.alive and f.team == team:
			n += 1
	return n


func elapsed_seconds() -> float:
	return float(tick) * config.dt()
