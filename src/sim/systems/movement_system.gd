class_name MovementSystem
extends SimSystem

# =============================================================
# OU JE VAIS.
# Ce systeme applique la physique du deplacement : inertie, separation,
# clamp a l'arene. La direction desiree est calculee par OrderSystem
# et stockee dans f.desired_vel.
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
	var desired := f.desired_vel

	desired += Steering.separation(f, state.fighters, cfg.radius * 2.0, cfg.separation_force)

	f.vel = Steering.apply_inertia(f.vel, desired, cfg.speed, cfg.accel_time, cfg.dt())
	f.pos += f.vel * cfg.dt()
	f.pos = Steering.clamp_to_arena(f.pos, cfg.arena_size, cfg.radius)


func _record_trail(state: CombatState, f: CombatFighter) -> void:
	f.trail.append(f.pos)
	if f.trail.size() > state.config.trail_length:
		f.trail.pop_front()
