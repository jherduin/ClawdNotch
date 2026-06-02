# Contribuer à ClawdNotch

Merci de l'intérêt que tu portes au projet ! Ce guide décrit les conventions à suivre pour qu'une
contribution soit fusionnée rapidement.

## Avant de commencer

- Ouvre (ou commente) une **issue** pour discuter d'un changement non trivial avant de coder.
- Pour un bug, utilise le template _Bug report_ ; pour une idée, le template _Feature request_.
- Ce projet suit un [Code de conduite](CODE_OF_CONDUCT.md) — sois respectueux.

## Prérequis de développement

- macOS 14.0+ et Xcode 15+.
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) : `project.yml` est la
  **source de vérité** du projet Xcode. Régénère le `.xcodeproj` après toute modification de `project.yml` :
  ```sh
  xcodegen generate
  ```
- Build en ligne de commande :
  ```sh
  swift build                 # squelette buildable
  xcodebuild -scheme ClawdNotch -configuration Debug build
  ```

## Conventions de commit — Conventional Commits

Format : `<type>(<scope>): <description>`

Types acceptés : `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`.

Exemples :

```
feat(overlay): ajoute une transition douce entre les états
fix(geometry): gère le changement de résolution multi-écrans
docs(readme): documente l'installation manuelle
```

## Modèle de branches

- **`main`** est protégée : toujours releasable, **aucun commit direct**.
- Travaille sur une branche dédiée :
  - `feat/xxx` pour une nouvelle fonctionnalité,
  - `fix/xxx` pour un correctif,
  - `docs/xxx`, `chore/xxx`, etc. selon le type.
- `release/vX.Y.Z` sert à préparer une version (bump + CHANGELOG) avant le merge et le tag.

## Versioning — SemVer 2.0.0

`MAJOR.MINOR.PATCH`. Le projet reste en `v0.x.x` jusqu'à stabilisation.

| Incrément | Quand |
|---|---|
| `PATCH` | bug fix, ajustement mineur |
| `MINOR` | nouvelle fonctionnalité rétrocompatible |
| `MAJOR` | changement cassant |

## Process de Pull Request

1. Forke / branche depuis `main` à jour.
2. Code, puis vérifie que ça compile **sans warning** (`xcodebuild` → `BUILD SUCCEEDED`).
3. Teste **avec et sans notch** quand le changement touche l'affichage (le `NotchGeometry` doit
   renvoyer `nil` proprement sur un Mac sans notch).
4. Mets à jour le [CHANGELOG](CHANGELOG.md) (section `[Unreleased]`) si le changement impacte l'utilisateur.
5. Ouvre la PR vers `main` en remplissant le template (type de changement, CHANGELOG, tests, commits conformes).
6. Une PR = une intention claire ; garde l'historique lisible.

## CHANGELOG

Le projet suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/). Ajoute tes entrées sous
`[Unreleased]` dans la catégorie adéquate (`Added`, `Changed`, `Fixed`, `Removed`…). La section est
renommée en `[vX.Y.Z] - YYYY-MM-DD` au moment de la release.

Merci ! 🧡
