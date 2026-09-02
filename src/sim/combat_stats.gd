class_name CombatStats
extends RefCounted

# =============================================================
# DU JOURNAL VERS LES CHIFFRES.
# Ce fichier ne connait ni l'ecran ni la simulation en cours : il ne lit
# qu'une liste d'evenements. C'est pour ca qu'il sert a la fois a l'ecran
# de fin de combat et a l'outil d'equilibrage.
# =============================================================

static func from_state(state: CombatState) -> Array:
	var lines: Array = []
	if state == null:
		return lines

	var by_id := {}
	for f in state.fighters:
		var line := CombatStatLine.new()
		line.id = f.id
		line.display_name = f.display_name
		line.team = f.team
		line.alive = f.alive
		line.hp = f.hp
		lines.append(line)
		by_id[f.id] = line

	for e in state.event_log.entries:
		var source: int = e["source"]
		var target: int = e["target"]
		match e["type"]:
			EventLog.WINDUP:
				if by_id.has(source):
					by_id[source].attacks += 1
			EventLog.DAMAGE:
				if by_id.has(source):
					by_id[source].damage_dealt += e["value"]
				if by_id.has(target):
					by_id[target].damage_taken += e["value"]
			EventLog.MISS:
				if by_id.has(source):
					by_id[source].misses += 1
			EventLog.KILL:
				if by_id.has(source):
					by_id[source].kills += 1

	return lines
