# ClawdNotch

Application macOS minimaliste qui affiche un indicateur visuel autour du notch pour signaler l'état de Claude Code en temps réel.

> Projet open-source — MIT License

---

## Vue d'ensemble

ClawdNotch est une app macOS sans fenêtre visible et sans icône dans le Dock. Son seul rôle : afficher un halo coloré autour du notch du MacBook selon l'état courant de Claude Code. Elle lit un fichier de statut (`~/.claude/notch_status`) mis à jour par les hooks Claude Code.

**Trois états :**

| État | Valeur fichier | Visuel |
|---|---|---|
| Travaille | `working` | Halo orange animé |
| Attend une réponse | `waiting` | Pulsation bleue douce |
| Inactif | `idle` | Invisible |

---

## Stack technique

- Swift 5.9+ / SwiftUI + AppKit
- macOS 14.0 minimum
- Xcode 15+
- Aucune dépendance externe

---

## Structure du repo

```
clawd-notch/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   ├── workflows/
│   │   ├── build.yml          # CI : compile sur push/PR
│   │   └── release.yml        # CD : GitHub Release sur tag v*
│   └── PULL_REQUEST_TEMPLATE.md
├── ClawdNotch/               # Sources Swift
├── ClawdNotch.xcodeproj/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── LICENSE                    # MIT
├── README.md
└── CLAUDE.md
```

---

## Architecture applicative

Cinq fichiers Swift, responsabilité unique chacun :

- **`ClawdNotchApp.swift`** — point d'entrée, suppression de l'icône Dock, pas de fenêtre principale
- **`NotchWindowController.swift`** — création et positionnement d'une `NSWindow` transparente, sans ombre, non-interactive, au-dessus de la menu bar, couvrant tous les espaces
- **`NotchGeometry.swift`** — calcul de la position et des dimensions du notch à partir des `safeAreaInsets` de l'écran principal ; gestion gracieuse des Macs sans notch
- **`StatusWatcher.swift`** — surveillance en temps réel de `~/.claude/notch_status` via `DispatchSource` (pas de polling), création du fichier s'il est absent, publication de l'état courant
- **`NotchOverlayView.swift`** — vue SwiftUI rendu dans la fenêtre, trois comportements visuels distincts selon l'état, animations subtiles (le notch est un signal ambiant, pas une notification)

---

## Hooks Claude Code

Trois hooks à configurer dans `~/.claude/settings.json` :

- **`PreToolUse`** → écrire `working` dans le fichier de statut
- **`PostToolUse`** → écrire `idle`
- **`Stop`** → écrire `waiting`

---

## Comportement sur Mac sans notch

Si `safeAreaInsets.top == 0`, aucune fenêtre n'est créée. L'app reste en mémoire sans rien afficher. Aucun crash.

---

## Standards open-source et GitHub

### Versioning — Semantic Versioning 2.0.0

`MAJOR.MINOR.PATCH` — le projet démarre en `v0.x.x` jusqu'à stabilisation.

| Incrément | Quand |
|---|---|
| `PATCH` | Bug fix, ajustement mineur |
| `MINOR` | Nouvelle fonctionnalité rétrocompatible |
| `MAJOR` | Changement cassant |

### Commits — Conventional Commits

Format : `<type>(<scope>): <description>`

Types : `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`

### Branching

- `main` protégée — toujours releasable, aucun commit direct
- `feat/xxx` et `fix/xxx` mergées via PR uniquement
- `release/vX.Y` pour préparer chaque version (bump + CHANGELOG) avant merge et tag

### CHANGELOG — Keep a Changelog

Section `[Unreleased]` mise à jour à chaque PR impactant l'utilisateur. Renommée en `[vX.Y.Z] - YYYY-MM-DD` au moment de la release.

### Process de release

1. Branche `release/vX.Y.Z`
2. Bump version dans le projet Xcode
3. Finalisation du CHANGELOG
4. Commit `chore(release): bump version to X.Y.Z`
5. Merge dans `main`
6. Tag `vX.Y.Z` → déclenche le workflow de release

### GitHub Actions

- **`build.yml`** — build sans signing sur chaque push et PR vers `main`, runner `macos-14`
- **`release.yml`** — déclenché sur tag `v*`, produit un `.dmg`, crée la GitHub Release et l'attache automatiquement

### Templates GitHub

- **Bug report** : version macOS, modèle MacBook, version ClawdNotch, étapes de reproduction, logs Console.app
- **Feature request** : problème résolu, solution proposée, alternatives
- **PR template** : type de changement, CHANGELOG mis à jour, testé avec et sans notch, commits conformes

### Licence

MIT. Fichier `LICENSE` à la racine, copyright au nom du mainteneur.

### README

Dans cet ordre : GIF du notch animé, badges (version / license / build / macOS), description deux lignes, installation (Homebrew prioritaire dès v1.0.0, téléchargement manuel en fallback), setup des hooks, lien CONTRIBUTING.

### Homebrew (objectif v1.0.0)

Publier un cask dans un tap personnel pointant vers le `.dmg` de la GitHub Release.
