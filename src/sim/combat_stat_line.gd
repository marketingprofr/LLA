class_name CombatStatLine
extends RefCounted

# =============================================================
# UNE LIGNE DE STATISTIQUES POUR UN COMBATTANT.
# Fichier separe et non classe interne : les classes internes appelees
# depuis une fonction statique posent probleme selon les versions de Godot.
# Un fichier par type, c'est aussi la regle qu'on s'est donnee.
#
# Ajouter une colonne a tes ecrans de stats commence ici.
# =============================================================

var id: int = 0
var display_name: String = ""
var team: int = 0
var alive: bool = true
var hp: float = 0.0

var damage_dealt: float = 0.0
var damage_taken: float = 0.0
var kills: int = 0
var attacks: int = 0
var misses: int = 0


func accuracy() -> float:
	if attacks <= 0:
		return 0.0
	return float(attacks - misses) / float(attacks)


func accuracy_text() -> String:
	return str(int(accuracy() * 100.0)) + "%"
