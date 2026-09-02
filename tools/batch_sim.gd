extends SceneTree

# =============================================================
# L'OUTIL EN LIGNE DE COMMANDE.
# Ne fait qu'imprimer le rapport calcule par BatchReport.
#
# Lancement depuis le dossier du projet :
#   godot --headless --script res://tools/batch_sim.gd
#
# Si le terminal te rebute, la touche B pendant le jeu fait la meme chose.
# =============================================================

func _initialize() -> void:
	print(BatchReport.run(CombatConfig.new(), 500))
	quit()
