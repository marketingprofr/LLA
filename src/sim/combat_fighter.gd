class_name CombatFighter
extends RefCounted

# =============================================================
# UN COMBATTANT. Des donnees, rien d'autre.
# Aucune methode qui decide quoi que ce soit : ce sont les systemes
# qui lisent et modifient cet etat.
# =============================================================

enum State { IDLE, WINDUP, RECOVERY }

# --- Identite ---
var id: int = 0
var team: int = 0
var display_name: String = ""
var initiative: float = 0.0

# --- Physique ---
var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO

# --- Vitalite ---
var hp: float = 0.0
var max_hp: float = 0.0
var alive: bool = true

# --- Decision ---
var target_id: int = -1
var target_lock: int = 0

# --- Action en cours ---
var state: int = State.IDLE
var state_ticks: int = 0       # pas restants dans l'etat courant
var action_target: int = -1    # cible verrouillee au moment d'armer

# --- Trace pour l'affichage de debug ---
var trail: Array = []


func hp_ratio() -> float:
	if max_hp <= 0.0:
		return 0.0
	return clampf(hp / max_hp, 0.0, 1.0)
