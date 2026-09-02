class_name EndConditionSystem
extends SimSystem

# =============================================================
# EST-CE QUE C'EST FINI.
# Fichier separe parce que la condition de victoire changera : rounds
# gagnants, limite de temps, objectifs de zone, survie contre des vagues.
# Chaque mode de jeu aura sa propre version de ce systeme.
# =============================================================

func run(state: CombatState) -> void:
	if state.is_over:
		return

	var alive_0 := state.alive_count(0)
	var alive_1 := state.alive_count(1)

	if alive_0 > 0 and alive_1 > 0:
		return

	state.is_over = true
	if alive_0 == 0 and alive_1 == 0:
		state.winner = -1
	elif alive_0 == 0:
		state.winner = 1
	else:
		state.winner = 0

	state.event_log.add(state.tick, EventLog.END, -1, -1, float(state.winner))
