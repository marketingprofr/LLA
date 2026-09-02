extends Node2D

# =============================================================
# LE NOEUD RACINE.
# Son seul travail est de cabler les morceaux ensemble et de traduire
# les touches du clavier en appels au controleur de temps.
# Aucune regle de jeu, aucun calcul, aucun dessin fait ici directement.
# =============================================================

const ORIGIN := Vector2(50.0, 50.0)
const BATCH_COMBATS := 500

var runner: SimRunner
var arena := ArenaRenderer.new()
var floaters := FloatingTextLayer.new()
var hud := DebugHud.new()
var result := ResultPanel.new()
var font: Font

var _was_over := false


func _ready() -> void:
	font = ThemeDB.fallback_font
	arena.origin = ORIGIN
	floaters.origin = ORIGIN
	runner = SimRunner.new()


func _process(delta: float) -> void:
	runner.advance(delta)

	var state := runner.state()

	# Le combat vient de se terminer : on calcule le tableau une seule fois.
	if state.is_over and not _was_over:
		result.prepare(state)
	_was_over = state.is_over

	floaters.consume(state)
	floaters.update(delta)
	queue_redraw()


func _draw() -> void:
	arena.draw_all(self, runner.state())
	floaters.draw_all(self, font)
	hud.draw_all(self, font, runner)
	result.draw_all(self, font)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return

	match key.keycode:
		KEY_SPACE:
			runner.toggle_pause()
		KEY_RIGHT:
			runner.request_single_step()
		KEY_1:
			runner.speed_scale = 0.1
		KEY_2:
			runner.speed_scale = 1.0
		KEY_3:
			runner.speed_scale = 4.0
		KEY_R:
			_new_combat(runner.current_seed + 1)
		KEY_ENTER:
			_new_combat(runner.current_seed)
		KEY_T:
			arena.show_trails = not arena.show_trails
		KEY_C:
			arena.show_targets = not arena.show_targets
		KEY_B:
			print(BatchReport.run(runner.config, BATCH_COMBATS))


func _new_combat(combat_seed: int) -> void:
	runner.restart(combat_seed)
	floaters.reset()
	result.reset()
	_was_over = false
