class_name TargetingSystem
extends SimSystem

# =============================================================
# QUI J'ATTAQUE.
# Le point crucial ici n'est pas de trouver la meilleure cible, c'est de
# ne pas en changer sans arret. Un combattant a egale distance de deux
# ennemis vibrerait entre les deux et son deplacement aurait l'air stupide.
# Deux garde-fous : un verrou de duree, et une marge a battre.
#
# C'est aussi ici que viendra plus tard le reglage "priorite de cible"
# (ligne arriere, plus faible, plus proche...). La structure ne changera pas :
# on remplacera "le plus proche" par un score.
# =============================================================

func run(state: CombatState) -> void:
	for f in state.fighters:
		if f.alive:
			_pick(state, f)


func _pick(state: CombatState, f: CombatFighter) -> void:
	if f.target_lock > 0:
		f.target_lock -= 1

	var current := state.get_fighter(f.target_id)
	if current != null and not current.alive:
		current = null
		f.target_id = -1
		f.target_lock = 0

	# Verrou actif et cible valide : on ne rediscute pas.
	if current != null and f.target_lock > 0:
		return

	var candidate := state.nearest(f, state.enemies_of(f))
	if candidate == null:
		return

	if current == null:
		_assign(state, f, candidate)
		return

	# On ne change que si le nouveau candidat est nettement meilleur.
	var current_dist: float = f.pos.distance_to(current.pos)
	var candidate_dist: float = f.pos.distance_to(candidate.pos)
	if candidate_dist < current_dist * state.config.switch_margin:
		_assign(state, f, candidate)


func _assign(state: CombatState, f: CombatFighter, target: CombatFighter) -> void:
	f.target_id = target.id
	f.target_lock = state.config.target_lock_ticks
