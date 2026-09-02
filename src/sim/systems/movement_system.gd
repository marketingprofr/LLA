class_name MovementSystem
extends SimSystem

# =============================================================
# OU JE VAIS.
# Ce systeme ne calcule rien lui-meme : il compose les briques de Steering.
# C'est ici que viendront les reglages tactiques de deplacement
# (tenir, pousser, flanquer, derriere les allies, poursuivre), chacun
# n'etant qu'une facon differente de choisir le point vise.
# =============================================================

func run(state: CombatState) -> void:
	for f in state.fighters:
		if f.alive:
			_move(state, f)
	for f in state.fighters:
		if f.alive:
			_record_trail(state, f)


func _move(state: CombatState, f: CombatFighter) -> void:
	var cfg := state.config
	var desired := _desired_velocity(state, f)

	desired += Steering.separation(f, state.fighters, cfg.radius * 2.0, cfg.separation_force)

	f.vel = Steering.apply_inertia(f.vel, desired, cfg.speed, cfg.accel_time, cfg.dt())
	f.pos += f.vel * cfg.dt()
	f.pos = Steering.clamp_to_arena(f.pos, cfg.arena_size, cfg.radius)


func _desired_velocity(state: CombatState, f: CombatFighter) -> Vector2:
	# On ne se deplace pas pendant qu'on arme un coup.
	if f.state == CombatFighter.State.WINDUP:
		return Vector2.ZERO

	var target := state.get_fighter(f.target_id)
	if target == null or not target.alive:
		return Vector2.ZERO

	# Arrive a portee, on s'arrete.
	if state.gap(f, target) <= state.config.reach:
		return Vector2.ZERO

	return Steering.seek(f.pos, target.pos, state.config.speed)


func _record_trail(state: CombatState, f: CombatFighter) -> void:
	f.trail.append(f.pos)
	if f.trail.size() > state.config.trail_length:
		f.trail.pop_front()
