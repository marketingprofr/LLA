class_name ArenaPalette
extends RefCounted

# =============================================================
# LES COULEURS, A UN SEUL ENDROIT.
# Aucun autre fichier d'affichage ne doit contenir de couleur en dur.
# =============================================================

const TEAM_0 := Color(0.35, 0.65, 1.0)
const TEAM_1 := Color(1.0, 0.45, 0.35)

const ARENA_BORDER := Color(0.25, 0.25, 0.28)
const TEXT := Color(0.90, 0.90, 0.90)
const TEXT_DIM := Color(0.55, 0.55, 0.55)

const DEAD := Color(0.30, 0.30, 0.30, 0.80)
const WINDUP := Color(1.0, 1.0, 1.0, 0.90)
const VELOCITY := Color(1.0, 1.0, 1.0, 0.60)

const HP_BACK := Color(0.10, 0.10, 0.10, 0.80)
const HP_HIGH := Color(0.40, 0.85, 0.40)
const HP_MID := Color(0.90, 0.70, 0.20)
const HP_LOW := Color(0.90, 0.30, 0.30)

const PANEL_BACK := Color(0.08, 0.08, 0.10, 0.94)
const PANEL_BORDER := Color(0.50, 0.50, 0.50, 0.80)


static func team(index: int) -> Color:
	return TEAM_0 if index == 0 else TEAM_1


static func hp(ratio: float) -> Color:
	if ratio <= 0.2:
		return HP_LOW
	if ratio <= 0.4:
		return HP_MID
	return HP_HIGH
