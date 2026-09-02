class_name CombatSim
extends RefCounted

# =============================================================
# L'ORCHESTRATEUR.
# Il ne contient aucune regle de jeu. Il cree l'etat, place les combattants,
# et appelle les systemes dans l'ordre a chaque pas de temps.
#
# Ce fichier ne connait pas l'ecran. Il peut tourner sans affichage,
# des milliers de fois par seconde. C'est la regle a ne jamais casser.
# =============================================================

var state: CombatState
var systems: Array = []


func _init(config: CombatConfig = null) -> void:
	state = CombatState.new(config)
	systems = [
		TargetingSystem.new(),
		ActionSystem.new(),
		MovementSystem.new(),
		EndConditionSystem.new(),
	]


func setup(combat_seed: int) -> void:
	state.rng.seed = combat_seed
	state.fighters.clear()
	state.event_log.clear()
	state.tick = 0
	state.is_over = false
	state.winner = -1

	var cfg := state.config
	for team in 2:
		for i in cfg.team_size:
			state.fighters.append(_spawn(cfg, team, i))


func _spawn(cfg: CombatConfig, team: int, index: int) -> CombatFighter:
	var f := CombatFighter.new()
	f.id = state.fighters.size()
	f.team = team
	f.display_name = ("B" if team == 0 else "R") + str(index + 1)
	f.max_hp = cfg.max_hp
	f.hp = cfg.max_hp

	var x: float = 150.0 if team == 0 else cfg.arena_size.x - 150.0
	var y: float = cfg.arena_size.y * (float(index) + 1.0) / (float(cfg.team_size) + 1.0)
	# Un leger decalage aleatoire pour que deux graines donnent deux combats differents.
	f.pos = Vector2(
		x + state.rng.randf_range(-30.0, 30.0),
		y + state.rng.randf_range(-20.0, 20.0)
	)
	return f


func step() -> void:
	if state.is_over:
		return
	state.tick += 1
	for system in systems:
		system.run(state)


# Joue le combat jusqu'au bout, sans affichage.
# C'est la fonction qu'utilise l'outil d'equilibrage.
func run_to_end(max_ticks: int = 4000) -> void:
	while not state.is_over and state.tick < max_ticks:
		step()
