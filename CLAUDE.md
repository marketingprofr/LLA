# LLA — prototype d'auto-battler d'arene

## Le projet

Jeu sous Godot 4.3 combinant deux references :

- **Eslabong** : combats d'arene automatises, gestion d'effectif, saisons et ligues,
  beaucoup d'ecrans de statistiques. Le joueur ne controle personne pendant le combat,
  il regle des comportements avant, et peut ajuster entre les rounds.
- **Amazing Cultivation Simulator** : une base construite sur une grille, des pieces
  specialisees posees a partir de plans, des objets et reliques qui donnent des bonus
  selon la piece ou on les place.

La boucle visee : combattre en arene, rapporter des ressources, ameliorer sa base,
equiper et faire progresser ses personnages, retourner combattre. Un match fait
avancer d'une semaine.

**Etat actuel : uniquement le prototype de combat.** Rien de la base n'existe encore.

## L'utilisateur

Debutant complet sur Godot. Il sait lire du code et diagnostiquer un comportement,
mais pas encore ecrire du GDScript seul.

Consequences directes :

- Explique ce que tu changes et pourquoi, en francais, avant de le faire.
- Garde les commentaires en tete de fichier a jour : ils expliquent le role du fichier.
- Ne propose pas dix choses a la fois. Une modification, un test, un constat.
- Si une decision de design t'est necessaire, pose la question au lieu de deviner.

## Les regles d'architecture

Ces trois regles ne se negocient pas. Elles ont deja rendu possibles le calcul
en arriere-plan et l'outil d'equilibrage.

**1. `src/sim/` ne connait pas l'ecran.** Aucun fichier de ce dossier ne doit
referencer une couleur, un dessin, un noeud, l'arbre de scenes, une touche ou
`get_node`. C'est ce qui permet de lancer la simulation dans un fil d'execution
separe et sans affichage.

**2. `src/view/` ne decide de rien.** L'affichage lit l'etat et le dessine. Il ne
modifie jamais un combattant, ne calcule aucune regle.

**3. Un comportement, un fichier.** Ajouter une mecanique veut dire ajouter un
fichier dans `src/sim/systems/` et une ligne dans la liste de `combat_sim.gd`.
Jamais gonfler une fonction existante.

## Conventions

- Commentaires et noms d'affichage en francais, sans accents dans les commentaires.
- Tous les nombres reglables vivent dans `src/sim/combat_config.gd`, nulle part ailleurs.
- Toutes les couleurs vivent dans `src/view/arena_palette.gd`, nulle part ailleurs.
- Tout ce qui se produit en combat passe par le journal (`EventLog`). Les ecrans de
  statistiques se construisent en relisant le journal, jamais avec des compteurs separes.
- Le hasard passe toujours par `state.rng`, jamais par `randi()` ou `randf()` globaux.
  Une meme graine doit rejouer un combat a l'identique.
- Rien n'est instantane : toute action a un temps d'armement, une resolution, une
  recuperation, comptes en pas de simulation.

## Structure

```
main.tscn, project.godot
src/sim/            la simulation, ne connait pas l'ecran
  combat_config.gd    tous les nombres reglables
  combat_state.gd     l'etat d'un combat + les requetes de base
  combat_fighter.gd   les donnees d'un combattant
  combat_sim.gd       l'orchestrateur, enchaine les systemes
  event_log.gd        le journal
  combat_stats.gd     journal -> chiffres
  combat_stat_line.gd une ligne de stats
  steering.gd         briques de deplacement reutilisables
  systems/            un fichier par comportement
src/app/            controle du temps, lancement du batch
src/view/           affichage, ne decide de rien
tools/              outil en ligne de commande
```

Ordre d'execution des systemes, a chaque pas : viser, agir, se deplacer,
verifier la fin. L'ordre compte.

## Comment tester

La simulation tourne a 20 pas par seconde, en temps fixe, decouplee de la boucle
de rendu.

Rapport d'equilibrage en ligne de commande :

```
godot --headless --script res://tools/batch_sim.gd
```

Ou la touche B pendant que le jeu tourne, qui lance le meme calcul dans un fil separe.

**Le test de non-regression le plus important** : les deux equipes sont strictement
identiques, donc le taux de victoire doit rester proche de 50 %. Un ecart de plus de
5 points signale une asymetrie cachee dans la simulation. Ce test a deja attrape un
biais a 57 % cause par l'ordre de traitement des combattants, corrige en melangeant
cet ordre a chaque pas avec le generateur du combat.

Controles en jeu : espace pause, fleche droite un pas, 1/2/3 vitesse, R nouveau
combat, entree rejouer la meme graine, T trainees, C lignes de cible, B equilibrage.

## Ce qui est fait

- Deplacement de groupe avec inertie, separation des corps, stabilite des decisions
  de ciblage (verrou de duree plus marge a battre).
- Attaque de base en trois temps, points de vie, morts, fin de combat.
- Journal d'evenements et tableau de statistiques de fin construit depuis ce journal.
- Visualiseur de debug : trainees, lignes de cible, controle du temps, pas a pas.
- Outil d'equilibrage en arriere-plan.

## La prochaine etape

Ajouter les reglages tactiques, **un seul a la fois**, en validant chacun avant de
passer au suivant. Le premier est l'ordre de maintien : tenir, pousser, flanquer,
derriere les allies, poursuivre.

Le critere de validation n'est pas technique : un observateur qui ne connait pas le
reglage d'un combattant doit pouvoir le deviner en regardant sa trajectoire. Si ce
n'est pas le cas, le reglage ne sert a rien au joueur.

**La structure imposee pour ces reglages : des poids, jamais des conditions imbriquees.**
A chaque pas, un combattant liste ses actions possibles et attribue une note a chacune.
Un reglage tactique modifie ces notes. C'est ce qui permettra d'en ajouter douze sans
que le code explose, et de deboguer en affichant pourquoi une action a ete choisie.

`steering.gd` contient deja `flee` et `orbit`, inutilises, prevus pour "en retrait"
et "flanquer".

## Ce qu'il ne faut pas faire

- Ne pas ajouter de contenu (classes, capacites, objets) tant que la boucle de combat
  n'est pas jugee agreable a regarder.
- Ne pas coupler la simulation au moteur, meme pour un petit gain de commodite.
- Ne pas remplacer le deplacement maison par le moteur physique de Godot : la physique
  n'est pas reproductible et ne tourne pas sans affichage.
- Ne pas introduire de dependance externe.
- Ne pas refactoriser au-dela de ce qui est demande.

## Installation de Godot (environnement headless)

Le projet utilise Godot 4.3 stable. Il n'existe pas de build serveur separe :
le binaire de l'editeur gere `--headless`.

### Procedure manuelle

```bash
# 1. Telecharger le binaire Linux x86_64 depuis les releases GitHub
curl -sSL -o /tmp/godot.zip \
  "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"

# 2. Extraire et installer dans le PATH
cd /tmp && unzip -o godot.zip
cp Godot_v4.3-stable_linux.x86_64 /usr/local/bin/godot
chmod +x /usr/local/bin/godot

# 3. Generer le cache d'import du projet (obligatoire avant --script)
cd /chemin/vers/LLA
godot --headless --import

# 4. Verifier
godot --version          # doit afficher 4.3.stable.official.*
godot --headless --script res://tools/batch_sim.gd
```

L'etape 3 (`--import`) est indispensable : sans elle, Godot ne construit pas
le registre `global_script_class_cache.cfg` et les `class_name` ne sont pas
resolues, ce qui fait echouer le script avec des erreurs "Identifier not declared".

### Configuration d'environnement recommandee (Claude Code Remote)

Pour automatiser l'installation dans les sessions Claude Code Remote, ajouter
un script d'initialisation a l'environnement :

```bash
#!/bin/bash
# setup-godot.sh — a placer dans la configuration de l'environnement Claude Code Remote
set -e

GODOT_VERSION="4.3-stable"
GODOT_BIN="/usr/local/bin/godot"

if [ ! -x "$GODOT_BIN" ]; then
  curl -sSL -o /tmp/godot.zip \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
  cd /tmp && unzip -o godot.zip
  cp "Godot_v${GODOT_VERSION}_linux.x86_64" "$GODOT_BIN"
  chmod +x "$GODOT_BIN"
  rm -f /tmp/godot.zip /tmp/Godot_v${GODOT_VERSION}_linux.x86_64
fi

# Generer le cache d'import si absent
if [ ! -d ".godot" ]; then
  godot --headless --import
fi
```

Ce script peut etre configure comme hook de demarrage de session via
https://code.claude.com/docs/en/claude-code-on-the-web (section Environments).
