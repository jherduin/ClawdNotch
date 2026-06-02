# ClawdNotch

<sub>🇬🇧 [Read in English](README.md)</sub>

> _🎞️ Démo animée à venir — le halo autour du notch en action._

<!-- <p align="center"><img src="docs/demo.gif" alt="ClawdNotch — halo autour du notch" width="720"></p> -->

[![Release](https://img.shields.io/github/v/release/jherduin/ClawdNotch?include_prereleases&sort=semver)](https://github.com/jherduin/ClawdNotch/releases)
[![License: MIT](https://img.shields.io/github/license/jherduin/ClawdNotch)](LICENSE)
[![Build](https://img.shields.io/github/actions/workflow/status/jherduin/ClawdNotch/build.yml?branch=main&label=build)](https://github.com/jherduin/ClawdNotch/actions/workflows/build.yml)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)](https://www.apple.com/macos/)

**ClawdNotch est une petite app macOS qui dessine un halo ambiant autour du notch de ton MacBook pour refléter ce que fait Claude Code en temps réel.**
Aucune fenêtre, aucune icône dans le Dock — juste une lueur discrète qui te dit, d'un coup d'œil, si l'agent travaille, attend ta réponse, ou est inactif.

| État | Valeur dans `~/.claude/notch_status` | Visuel |
|---|---|---|
| **Travaille** | `working` | halo orange animé |
| **Attend ta réponse** | `waiting` | pulsation bleue douce |
| **Inactif** | `idle` | invisible |

> Sur un Mac sans notch, l'app reste en mémoire et ne dessine simplement rien — aucun crash, aucune gêne.

---

## Installation

### Homebrew _(prévu dès la v1.0.0)_

```sh
brew install --cask jherduin/tap/clawdnotch
```

> Pas encore disponible — le cask Homebrew arrivera avec la première version stable. En attendant, utilise le téléchargement manuel.

### Téléchargement manuel

1. Récupère le dernier `ClawdNotch.dmg` sur la page [Releases](https://github.com/jherduin/ClawdNotch/releases).
2. Ouvre le `.dmg` et glisse **ClawdNotch** dans `/Applications`.
3. Au premier lancement, macOS peut bloquer l'app (build non signé par un Developer ID) :
   clic droit sur l'app → **Ouvrir** → **Ouvrir** pour confirmer.

## Lancer

L'app tourne en arrière-plan, sans fenêtre ni icône dans le Dock. Lance-la avec :

```sh
open -a ClawdNotch
```

Pour qu'elle démarre à l'ouverture de session, ajoute-la dans
**Réglages Système → Général → Ouverture → Ouverture automatique**.

> Rien ne s'affiche ? C'est normal quand Claude Code est inactif. Déclenche une activité, ou écris une
> valeur de test directement : `echo working > ~/.claude/notch_status` doit allumer le halo orange.

## Arrêter

Comme l'app n'a ni icône Dock ni élément de barre de menus, quitte-la depuis le terminal :

```sh
killall ClawdNotch
```

(Ou via le **Moniteur d'activité** : cherche `ClawdNotch` et quitte le processus.) Si tu l'as ajoutée
aux éléments d'ouverture, retire-la aussi pour qu'elle ne revienne pas à la prochaine session.

## Désinstaller

```sh
killall ClawdNotch                  # arrête l'app
rm -rf /Applications/ClawdNotch.app # supprime l'app
rm -f ~/.claude/notch_status        # supprime le fichier de statut (optionnel)
```

Supprime ensuite l'entrée ClawdNotch dans **Réglages Système → Général → Ouverture**, et retire les
hooks ClawdNotch que tu as ajoutés à `~/.claude/settings.json` (voir ci-dessous).

---

## Configuration des hooks

ClawdNotch est **passif** : il lit `~/.claude/notch_status` et affiche le halo correspondant.
Ce sont les **hooks Claude Code** qui mettent ce fichier à jour en temps réel.

Colle ce bloc dans `~/.claude/settings.json` :

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "echo working > \"$HOME/.claude/notch_status\"" }] }
    ],
    "PreToolUse": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "echo working > \"$HOME/.claude/notch_status\"" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "echo waiting > \"$HOME/.claude/notch_status\"" }] }
    ],
    "SessionEnd": [
      { "hooks": [{ "type": "command", "command": "echo idle > \"$HOME/.claude/notch_status\"" }] }
    ]
  }
}
```

Le halo reste orange pendant tout le tour (même avec plusieurs outils enchaînés), passe au bleu quand
Claude te rend la main, et disparaît à la fin de la session.

⚠️ Si ton `settings.json` contient déjà une clé `hooks`, **ajoute** ces blocs aux tableaux existants
au lieu d'écraser la clé. Détails, cohabitation avec d'autres hooks et étapes de vérification :
**[docs/hooks.md](docs/hooks.md)**.

---

## Contribuer

Les contributions sont bienvenues — voir **[CONTRIBUTING.md](CONTRIBUTING.md)** pour les conventions
de commit, le modèle de branches et le process de PR. Ce projet suit un
[Code de conduite](CODE_OF_CONDUCT.md).

## Licence

[MIT](LICENSE) — © 2026 jherduin.
