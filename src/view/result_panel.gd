class_name ResultPanel
extends RefCounted

# =============================================================
# L'ECRAN DE FIN DE COMBAT.
# Il ne lit pas la simulation : il lit CombatStats, qui lit le journal.
#
# Les statistiques sont calculees UNE FOIS a la fin du combat, pas a
# chaque image. Un ecran de resultat ne bouge plus, il n'a aucune raison
# d'etre recalcule soixante fois par seconde.
# =============================================================

const PANEL_POS := Vector2(230.0, 120.0)
const PANEL_SIZE := Vector2(560.0, 400.0)

const COL_NAME := 24.0
const COL_HP := 130.0
const COL_DEALT := 210.0
const COL_TAKEN := 330.0
const COL_KILLS := 440.0
const COL_ACC := 490.0

var _lines: Array = []
var _title: String = ""
var _subtitle: String = ""


# A appeler une seule fois, au moment ou le combat se termine.
func prepare(state: CombatState) -> void:
	if state == null:
		return

	_lines = CombatStats.from_state(state)

	if state.winner == 0:
		_title = "EQUIPE BLEUE"
	elif state.winner == 1:
		_title = "EQUIPE ROUGE"
	else:
		_title = "EGALITE"

	_subtitle = "%.1f secondes   %d evenements au journal" % [
		state.elapsed_seconds(),
		state.event_log.size(),
	]


func reset() -> void:
	_lines = []
	_title = ""
	_subtitle = ""


func draw_all(ci: CanvasItem, font: Font) -> void:
	if _lines.is_empty():
		return

	ci.draw_rect(Rect2(PANEL_POS, PANEL_SIZE), ArenaPalette.PANEL_BACK)
	ci.draw_rect(Rect2(PANEL_POS, PANEL_SIZE), ArenaPalette.PANEL_BORDER, false, 2.0)

	_cell(ci, font, COL_NAME, 40.0, _title, 22, ArenaPalette.TEXT)
	_cell(ci, font, COL_NAME, 66.0, _subtitle, 13, ArenaPalette.TEXT_DIM)

	_draw_header(ci, font)
	_draw_rows(ci, font)

	_cell(ci, font, COL_NAME, PANEL_SIZE.y - 20.0,
		"R pour un nouveau combat, entree pour rejouer celui-ci",
		13, ArenaPalette.TEXT_DIM)


func _draw_header(ci: CanvasItem, font: Font) -> void:
	var y := 100.0
	_cell(ci, font, COL_NAME, y, "NOM", 13, ArenaPalette.TEXT_DIM)
	_cell(ci, font, COL_HP, y, "PV", 13, ArenaPalette.TEXT_DIM)
	_cell(ci, font, COL_DEALT, y, "INFLIGES", 13, ArenaPalette.TEXT_DIM)
	_cell(ci, font, COL_TAKEN, y, "SUBIS", 13, ArenaPalette.TEXT_DIM)
	_cell(ci, font, COL_KILLS, y, "K", 13, ArenaPalette.TEXT_DIM)
	_cell(ci, font, COL_ACC, y, "PRECISION", 13, ArenaPalette.TEXT_DIM)


func _draw_rows(ci: CanvasItem, font: Font) -> void:
	var y := 122.0
	for line in _lines:
		var col: Color = ArenaPalette.team(line.team)
		if not line.alive:
			col = col.darkened(0.5)
		_cell(ci, font, COL_NAME, y, line.display_name, 14, col)
		_cell(ci, font, COL_HP, y, str(int(line.hp)), 14, ArenaPalette.TEXT)
		_cell(ci, font, COL_DEALT, y, str(int(line.damage_dealt)), 14, ArenaPalette.TEXT)
		_cell(ci, font, COL_TAKEN, y, str(int(line.damage_taken)), 14, ArenaPalette.TEXT)
		_cell(ci, font, COL_KILLS, y, str(line.kills), 14, ArenaPalette.TEXT)
		_cell(ci, font, COL_ACC, y, line.accuracy_text(), 14, ArenaPalette.TEXT)
		y += 26.0


func _cell(ci: CanvasItem, font: Font, x: float, y: float, text: String, size: int, color: Color) -> void:
	ci.draw_string(font, PANEL_POS + Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
