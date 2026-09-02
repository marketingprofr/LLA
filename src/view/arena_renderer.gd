class_name ArenaRenderer
extends RefCounted

# =============================================================
# LE DESSIN DE L'ARENE.
# Ne prend aucune decision, ne modifie jamais l'etat. Il lit et il dessine.
# Chaque couche est une methode separee pour pouvoir l'eteindre.
# =============================================================

var origin: Vector2 = Vector2(50.0, 50.0)
var show_trails: bool = true
var show_targets: bool = true
var show_velocity: bool = true


func draw_all(ci: CanvasItem, state: CombatState) -> void:
	_draw_arena(ci, state)
	if show_trails:
		_draw_trails(ci, state)
	if show_targets:
		_draw_target_lines(ci, state)
	_draw_dead(ci, state)
	_draw_alive(ci, state)


func _draw_arena(ci: CanvasItem, state: CombatState) -> void:
	ci.draw_rect(Rect2(origin, state.config.arena_size), ArenaPalette.ARENA_BORDER, false, 2.0)


# La trainee est le meilleur outil pour juger le naturel d'un deplacement :
# un combattant qui hesite laisse un gribouillis, un combattant propre
# laisse une courbe lisible.
func _draw_trails(ci: CanvasItem, state: CombatState) -> void:
	for f in state.fighters:
		if not f.alive or f.trail.size() < 2:
			continue
		var col: Color = ArenaPalette.team(f.team)
		col.a = 0.30
		for i in range(1, f.trail.size()):
			ci.draw_line(origin + f.trail[i - 1], origin + f.trail[i], col, 2.0)


func _draw_target_lines(ci: CanvasItem, state: CombatState) -> void:
	for f in state.fighters:
		if not f.alive:
			continue
		var t := state.get_fighter(f.target_id)
		if t == null or not t.alive:
			continue
		var col: Color = ArenaPalette.team(f.team)
		col.a = 0.20
		ci.draw_line(origin + f.pos, origin + t.pos, col, 1.0)


func _draw_dead(ci: CanvasItem, state: CombatState) -> void:
	for f in state.fighters:
		if f.alive:
			continue
		ci.draw_circle(origin + f.pos, state.config.radius * 0.6, ArenaPalette.DEAD)


func _draw_alive(ci: CanvasItem, state: CombatState) -> void:
	for f in state.fighters:
		if not f.alive:
			continue
		var p: Vector2 = origin + f.pos
		ci.draw_circle(p, state.config.radius, ArenaPalette.team(f.team))
		_draw_windup(ci, state, f, p)
		if show_velocity and f.vel.length() > 1.0:
			ci.draw_line(p, p + f.vel * 0.20, ArenaPalette.VELOCITY, 2.0)
		_draw_hp_bar(ci, state, f, p)


# Un cercle blanc qui se referme sur le combattant pendant l'armement.
# Sans ce signal, les degats sortent de nulle part et le combat devient illisible.
func _draw_windup(ci: CanvasItem, state: CombatState, f: CombatFighter, p: Vector2) -> void:
	if f.state != CombatFighter.State.WINDUP:
		return
	var total: float = float(state.config.attack_windup_ticks)
	var remaining: float = float(f.state_ticks)
	var r: float = state.config.radius + 14.0 * (remaining / maxf(total, 1.0))
	ci.draw_arc(p, r, 0.0, TAU, 24, ArenaPalette.WINDUP, 2.0)


func _draw_hp_bar(ci: CanvasItem, state: CombatState, f: CombatFighter, p: Vector2) -> void:
	var w := 32.0
	var h := 4.0
	var top: Vector2 = p + Vector2(-w * 0.5, -state.config.radius - 10.0)
	ci.draw_rect(Rect2(top, Vector2(w, h)), ArenaPalette.HP_BACK)
	var ratio: float = f.hp_ratio()
	ci.draw_rect(Rect2(top, Vector2(w * ratio, h)), ArenaPalette.hp(ratio))
