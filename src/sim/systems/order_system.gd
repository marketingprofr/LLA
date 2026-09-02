class_name OrderSystem
extends SimSystem

# =============================================================
# OU JE VEUX ALLER.
# Calcule la vitesse desiree de chaque combattant selon son ordre tactique.
# Le resultat est stocke dans f.desired_vel, lu ensuite par MovementSystem
# qui applique l'inertie, la separation et le clamp.
#
# HOLD      : ne bouge pas
# FRONTLINE : avance vers l'ennemi le plus proche, tanke pour la backline
# BACKLINE  : reste derriere les allies frontline
# FLANK     : fonce sur sa cible en deviant pour eviter les autres ennemis
# BREACH    : tout droit vers sa cible assignee
# =============================================================


func run(state: CombatState) -> void:
	for f in state.fighters:
		if not f.alive:
			f.desired_vel = Vector2.ZERO
			continue
		if f.state == CombatFighter.State.WINDUP:
			f.desired_vel = Vector2.ZERO
			continue
		match f.order:
			CombatFighter.Order.HOLD:
				f.desired_vel = _hold()
			CombatFighter.Order.FRONTLINE:
				f.desired_vel = _frontline(state, f)
			CombatFighter.Order.BACKLINE:
				f.desired_vel = _backline(state, f)
			CombatFighter.Order.FLANK:
				f.desired_vel = _flank(state, f)
			CombatFighter.Order.BREACH:
				f.desired_vel = _breach(state, f)
			_:
				f.desired_vel = _breach(state, f)


func _hold() -> Vector2:
	return Vector2.ZERO


func _breach(state: CombatState, f: CombatFighter) -> Vector2:
	var target := state.get_fighter(f.target_id)
	if target == null or not target.alive:
		return Vector2.ZERO
	if state.gap(f, target) <= state.config.reach:
		return Vector2.ZERO
	return Steering.seek(f.pos, target.pos, state.config.speed)


func _frontline(state: CombatState, f: CombatFighter) -> Vector2:
	var enemies := state.enemies_of(f)
	if enemies.is_empty():
		return Vector2.ZERO
	var nearest_enemy := state.nearest(f, enemies)
	if state.gap(f, nearest_enemy) <= state.config.reach:
		return Vector2.ZERO
	return Steering.seek(f.pos, nearest_enemy.pos, state.config.speed)


func _backline(state: CombatState, f: CombatFighter) -> Vector2:
	var target := state.get_fighter(f.target_id)
	if target == null or not target.alive:
		return Vector2.ZERO
	if state.gap(f, target) <= state.config.reach:
		return Vector2.ZERO

	var frontliners: Array = []
	for ally in state.allies_of(f):
		if ally.order == CombatFighter.Order.FRONTLINE:
			frontliners.append(ally)

	if frontliners.is_empty():
		return Steering.seek(f.pos, target.pos, state.config.speed)

	var enemy_center := _centroid(state.enemies_of(f))
	var my_dist := f.pos.distance_to(enemy_center)
	var front_dist := INF
	for fl in frontliners:
		front_dist = minf(front_dist, fl.pos.distance_to(enemy_center))

	if my_dist < front_dist + state.config.backline_offset:
		return Steering.flee(f.pos, enemy_center, state.config.speed)

	return Steering.seek(f.pos, target.pos, state.config.speed)


func _flank(state: CombatState, f: CombatFighter) -> Vector2:
	var target := state.get_fighter(f.target_id)
	if target == null or not target.alive:
		return Vector2.ZERO
	if state.gap(f, target) <= state.config.reach:
		return Vector2.ZERO

	var to_target := target.pos - f.pos
	var dist := to_target.length()
	if dist < 0.001:
		return Vector2.ZERO

	var max_angle := deg_to_rad(state.config.flank_max_angle_deg)
	var angle := max_angle * clampf(dist / 300.0, 0.0, 1.0)

	var direction := 1.0
	var obstacle_sum := Vector2.ZERO
	var obstacle_count := 0
	for e in state.enemies_of(f):
		if e.id != f.target_id:
			obstacle_sum += e.pos
			obstacle_count += 1
	if obstacle_count > 0:
		var obstacle_center := obstacle_sum / float(obstacle_count)
		var cross := to_target.cross(obstacle_center - f.pos)
		if absf(cross) > 0.1:
			direction = -signf(cross)

	return to_target.rotated(angle * direction).normalized() * state.config.speed


func _centroid(fighters: Array) -> Vector2:
	if fighters.is_empty():
		return Vector2.ZERO
	var sum := Vector2.ZERO
	for f in fighters:
		sum += f.pos
	return sum / float(fighters.size())
