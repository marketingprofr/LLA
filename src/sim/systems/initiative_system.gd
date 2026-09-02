class_name InitiativeSystem
extends SimSystem

# =============================================================
# DANS QUEL ORDRE ON AGIT.
# Trie les combattants par initiative decroissante a chaque pas.
# A initiative egale, l'ordre est melange aleatoirement via state.rng
# pour eviter tout biais lie a la position dans le tableau.
# =============================================================

func run(state: CombatState) -> void:
	var arr := state.fighters
	var n := arr.size()

	# Fisher-Yates : melange aleatoire complet d'abord
	for i in range(n - 1, 0, -1):
		var j := state.rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp

	# Tri par insertion, stable : les ex-aequo gardent l'ordre du melange
	for i in range(1, n):
		var key = arr[i]
		var k := i - 1
		while k >= 0 and arr[k].initiative < key.initiative:
			arr[k + 1] = arr[k]
			k -= 1
		arr[k + 1] = key
