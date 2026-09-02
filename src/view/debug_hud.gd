class_name DebugHud
extends RefCounted

# =============================================================
# LA BARRE D'INFO ET L'AIDE DES TOUCHES.
# Outil de developpement, destine a disparaitre. Isole pour cette raison :
# le jour ou on le supprime, on supprime un fichier.
# =============================================================

const HELP := "espace pause  |  fleche droite un pas  |  1 ralenti  2 normal  3 rapide  |  R nouveau combat  |  entree rejouer  |  T trainees  C cibles"


func draw_all(ci: CanvasItem, font: Font, runner: SimRunner) -> void:
	var state := runner.state()

	var line := "pas %d   %.1f s   %s   graine %d" % [
		state.tick,
		state.elapsed_seconds(),
		runner.speed_label(),
		runner.current_seed,
	]
	ci.draw_string(font, Vector2(50.0, 30.0), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ArenaPalette.TEXT)

	var y: float = state.config.arena_size.y + 80.0
	ci.draw_string(font, Vector2(50.0, y), HELP, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ArenaPalette.TEXT_DIM)
