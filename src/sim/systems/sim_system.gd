class_name SimSystem
extends RefCounted

# =============================================================
# LA BASE DE TOUS LES SYSTEMES.
# Un systeme fait une seule chose, sur tout le monde, dans un ordre defini.
# La simulation ne fait qu'appeler run() sur chacun, dans l'ordre.
# Ajouter un comportement au jeu = ajouter un fichier ici, pas modifier
# une fonction de mille lignes.
# =============================================================

func run(_state: CombatState) -> void:
	pass
