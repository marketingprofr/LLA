class_name FloatingTextLayer
extends RefCounted

# =============================================================
# LES CHIFFRES QUI MONTENT.
# Cette couche ne parle jamais a la simulation : elle lit le JOURNAL.
# C'est la demonstration que le journal suffit a nourrir n'importe quel
# affichage, present ou futur, sans toucher a la simulation.
# =============================================================

const LIFETIME := 0.8
const RISE_SPEED := 25.0

var origin: Vector2 = Vector2(50.0, 50.0)

var _items: Array = []
var _events_read: int = 0


func reset() -> void:
	_items.clear()
	_events_read = 0


func consume(state: CombatState) -> void:
	var fresh: Array = state.event_log.since(_events_read)
	_events_read = state.event_log.size()

	for e in fresh:
		if e["type"] != EventLog.DAMAGE:
			continue
		var target := state.get_fighter(e["target"])
		if target == null:
			continue
		_items.append({
			"pos": target.pos,
			"text": str(int(e["value"])),
			"life": LIFETIME,
		})


func update(delta: float) -> void:
	var kept: Array = []
	for item in _items:
		item["life"] -= delta
		item["pos"] = item["pos"] + Vector2(0.0, -RISE_SPEED * delta)
		if item["life"] > 0.0:
			kept.append(item)
	_items = kept


func draw_all(ci: CanvasItem, font: Font) -> void:
	for item in _items:
		var alpha: float = clampf(item["life"] / LIFETIME, 0.0, 1.0)
		ci.draw_string(
			font,
			origin + item["pos"] + Vector2(6.0, -20.0),
			item["text"],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14,
			Color(1.0, 1.0, 1.0, alpha)
		)
