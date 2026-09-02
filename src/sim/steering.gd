class_name Steering
extends RefCounted

# =============================================================
# LES BRIQUES DE DEPLACEMENT.
# Chaque fonction repond a une seule question et ne connait rien du combat.
# Elles seront reutilisees par tout ce qui bouge : les combattants,
# plus tard les projectiles, les invocations, les reculs et les charges.
# =============================================================


# Aller vers un point a pleine vitesse.
static func seek(from: Vector2, to: Vector2, speed: float) -> Vector2:
	var delta := to - from
	if delta.length() < 0.001:
		return Vector2.ZERO
	return delta.normalized() * speed


# S'eloigner d'un point.
static func flee(from: Vector2, threat: Vector2, speed: float) -> Vector2:
	return -seek(from, threat, speed)


# Tourner autour d'un point, dans le sens indique par le signe.
# Pas encore utilise. Servira pour le reglage tactique "flanquer".
static func orbit(from: Vector2, center: Vector2, speed: float, direction: float = 1.0) -> Vector2:
	var radial := from - center
	if radial.length() < 0.001:
		return Vector2.ZERO
	return radial.normalized().orthogonal() * speed * signf(direction)


# Force qui empeche deux corps de se superposer.
# Sans elle, les combattants se traversent et s'empilent au meme endroit.
static func separation(subject: CombatFighter, others: Array, min_distance: float, force: float) -> Vector2:
	var push := Vector2.ZERO
	for other in others:
		if other.id == subject.id:
			continue
		var d: float = subject.pos.distance_to(other.pos)
		if d < min_distance and d > 0.01:
			push += (subject.pos - other.pos).normalized() * (min_distance - d) * force
	return push


# Applique l'inertie : on ne change pas de direction instantanement.
# C'est cette fonction qui fait la difference entre un insecte et un combattant.
static func apply_inertia(current_vel: Vector2, desired_vel: Vector2, max_speed: float, accel_time: float, dt: float) -> Vector2:
	var target := desired_vel
	if target.length() > max_speed:
		target = target.normalized() * max_speed
	var accel: float = max_speed / maxf(accel_time, 0.001)
	return current_vel.move_toward(target, accel * dt)


static func clamp_to_arena(pos: Vector2, arena_size: Vector2, radius: float) -> Vector2:
	return Vector2(
		clampf(pos.x, radius, arena_size.x - radius),
		clampf(pos.y, radius, arena_size.y - radius)
	)
