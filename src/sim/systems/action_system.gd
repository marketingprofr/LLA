class_name ActionSystem
extends SimSystem

# =============================================================
# CE QUE JE FAIS.
# Une action se deroule toujours en trois temps : elle s'arme, elle se
# resout, puis on recupere. Rien n'est instantane, et c'est ce qui rend
# le combat lisible pour le spectateur.
#
# Aujourd'hui il n'y a qu'une action, l'attaque de base. Quand il y aura
# des capacites, elles suivront exactement le meme cycle et ce fichier
# se contentera de demander a la capacite combien de temps elle prend
# et ce qu'elle fait au moment de la resolution.
# =============================================================

func run(state: CombatState) -> void:
	for f in state.fighters:
		if f.alive:
			_advance(state, f)


func _advance(state: CombatState, f: CombatFighter) -> void:
	if f.state_ticks > 0:
		f.state_ticks -= 1

	match f.state:
		CombatFighter.State.WINDUP:
			if f.state_ticks <= 0:
				_resolve(state, f)
				f.state = CombatFighter.State.RECOVERY
				f.state_ticks = state.config.attack_recovery_ticks

		CombatFighter.State.RECOVERY:
			if f.state_ticks <= 0:
				f.state = CombatFighter.State.IDLE

		CombatFighter.State.IDLE:
			_try_start(state, f)


func _try_start(state: CombatState, f: CombatFighter) -> void:
	var t := state.get_fighter(f.target_id)
	if t == null or not t.alive:
		return
	if state.gap(f, t) > state.config.reach:
		return

	f.state = CombatFighter.State.WINDUP
	f.state_ticks = state.config.attack_windup_ticks
	f.action_target = t.id
	state.event_log.add(state.tick, EventLog.WINDUP, f.id, t.id)


func _resolve(state: CombatState, f: CombatFighter) -> void:
	var t := state.get_fighter(f.action_target)

	# La cible a pu mourir ou s'eloigner pendant l'armement. Le coup rate.
	var out_of_range: bool = t != null and state.gap(f, t) > state.config.reach + state.config.hit_tolerance
	if t == null or not t.alive or out_of_range:
		state.event_log.add(state.tick, EventLog.MISS, f.id, f.action_target)
		return

	_apply_damage(state, f, t, state.config.attack_damage)


# Isole volontairement : tout ce qui infligera des degats plus tard
# (capacites, zones, brulures, tir ami) passera par cette porte unique.
func _apply_damage(state: CombatState, source: CombatFighter, target: CombatFighter, amount: float) -> void:
	target.hp -= amount
	state.event_log.add(state.tick, EventLog.DAMAGE, source.id, target.id, amount)

	if target.hp <= 0.0:
		target.hp = 0.0
		target.alive = false
		target.state = CombatFighter.State.IDLE
		target.vel = Vector2.ZERO
		state.event_log.add(state.tick, EventLog.KILL, source.id, target.id)
