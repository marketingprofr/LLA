class_name SimRunner
extends RefCounted

# =============================================================
# LE CONTROLE DU TEMPS.
# La simulation n'est PAS branchee sur la boucle du moteur. On accumule
# le temps ecoule et on appelle step() nous-memes autant de fois qu'il faut.
#
# C'est ce qui donne gratuitement : la pause, le ralenti, l'avance d'un
# seul pas, la vitesse fois cinquante, et l'execution sans affichage.
# Si tu couples la simulation au rendu, tu perds les cinq.
# =============================================================

const MAX_STEPS_PER_FRAME := 500

var sim: CombatSim
var config: CombatConfig
var current_seed: int = 1

var paused: bool = false
var speed_scale: float = 1.0

var _accumulator: float = 0.0
var _step_requested: bool = false


func _init(cfg: CombatConfig = null) -> void:
	config = cfg if cfg != null else CombatConfig.new()
	restart(current_seed)


func restart(combat_seed: int) -> void:
	current_seed = combat_seed
	sim = CombatSim.new(config)
	sim.setup(combat_seed)
	_accumulator = 0.0
	_step_requested = false


func replay() -> void:
	restart(current_seed)


func next_combat() -> void:
	restart(current_seed + 1)


func request_single_step() -> void:
	paused = true
	_step_requested = true


func toggle_pause() -> void:
	paused = not paused


func advance(delta: float) -> void:
	if _step_requested:
		sim.step()
		_step_requested = false
		return

	if paused:
		return

	_accumulator += delta * speed_scale
	var dt := config.dt()
	var steps := 0
	while _accumulator >= dt and steps < MAX_STEPS_PER_FRAME:
		sim.step()
		_accumulator -= dt
		steps += 1


func state() -> CombatState:
	return sim.state


func speed_label() -> String:
	if paused:
		return "PAUSE"
	return "x" + str(speed_scale)
