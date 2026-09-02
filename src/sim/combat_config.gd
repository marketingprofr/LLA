class_name CombatConfig
extends Resource

# =============================================================
# TOUS LES NOMBRES QUI SE REGLENT A L'OEIL SONT ICI, ET NULLE PART AILLEURS.
# C'est une Resource : plus tard tu pourras en sauvegarder plusieurs versions
# (.tres) et comparer deux equilibrages sans toucher au code.
# =============================================================

# --- Temps ---
@export var tick_rate: int = 20

# --- Arene et effectifs ---
@export var arena_size: Vector2 = Vector2(900.0, 600.0)
@export var team_size: int = 5

# --- Corps et deplacement ---
@export var radius: float = 15.0
@export var speed: float = 150.0
@export var accel_time: float = 0.30          # secondes pour atteindre la vitesse max
@export var separation_force: float = 6.0

# --- Decision ---
@export var reach: float = 20.0               # distance a laquelle on s'arrete devant sa cible
@export var target_lock_ticks: int = 20       # duree minimale avant de pouvoir changer de cible
@export var switch_margin: float = 0.75       # la nouvelle cible doit etre nettement plus proche

# --- Initiative ---
@export var initiative_blue: float = 1.0
@export var initiative_red: float = 2.0

# --- Attaque de base ---
@export var max_hp: float = 100.0
@export var attack_damage: float = 9.0
@export var attack_windup_ticks: int = 6      # le coup s'arme, on le voit venir
@export var attack_recovery_ticks: int = 10   # on ne peut rien faire apres
@export var hit_tolerance: float = 8.0        # marge de portee au moment de l'impact

# --- Affichage ---
@export var trail_length: int = 40


func dt() -> float:
	return 1.0 / float(tick_rate)
