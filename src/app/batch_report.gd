class_name BatchReport
extends RefCounted

# =============================================================
# LE RAPPORT D'EQUILIBRAGE.
# Joue N combats sans rien afficher et renvoie un texte.
# Ce fichier ne sait pas qui va lire ce texte : la console de l'editeur,
# un terminal, ou plus tard un fichier CSV. C'est pour ca qu'il renvoie
# une chaine au lieu d'imprimer lui-meme.
# =============================================================

static func run(config: CombatConfig = null, combats: int = 500) -> String:
	var cfg: CombatConfig = config if config != null else CombatConfig.new()

	var wins := [0, 0]
	var draws := 0
	var total_ticks := 0
	var total_events := 0

	var started := Time.get_ticks_msec()

	for i in combats:
		var sim := CombatSim.new(cfg)
		sim.setup(i + 1)
		sim.run_to_end()

		var state := sim.state
		if state.winner >= 0:
			wins[state.winner] += 1
		else:
			draws += 1
		total_ticks += state.tick
		total_events += state.event_log.size()

	var elapsed := Time.get_ticks_msec() - started
	var avg_seconds := float(total_ticks) / float(combats) * cfg.dt()

	var lines := PackedStringArray()
	lines.append("--- rapport d'equilibrage ---")
	lines.append("combats simules   : %d" % combats)
	lines.append("victoires bleu    : %d (%.1f %%)" % [wins[0], 100.0 * float(wins[0]) / float(combats)])
	lines.append("victoires rouge   : %d (%.1f %%)" % [wins[1], 100.0 * float(wins[1]) / float(combats)])
	lines.append("nuls              : %d" % draws)
	lines.append("duree moyenne     : %.1f s" % avg_seconds)
	lines.append("evenements moyens : %.0f" % (float(total_events) / float(combats)))
	lines.append("temps de calcul   : %d ms pour l'ensemble" % elapsed)

	return "\n".join(lines)
