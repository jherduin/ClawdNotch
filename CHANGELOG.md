# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et le projet adhère au
[Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

### Added

- App macOS sans fenêtre ni icône Dock (`LSUIElement`), affichant un halo ambiant autour du notch.
- Trois états visuels pilotés par `~/.claude/notch_status` : `working` (orange animé),
  `waiting` (pulsation bleue), `idle` (invisible).
- Surveillance temps réel du fichier de statut via `DispatchSource` (sans polling), avec recréation
  et réarmement automatiques.
- Calcul géométrique du notch via `safeAreaInsets` ; gestion gracieuse des Macs sans notch.
- Documentation de configuration des hooks Claude Code (`docs/hooks.md`).
- Documentation open-source : `README.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
- Intégration continue (`build.yml`) : compilation Release sans signing à chaque push et PR vers `main`.
- Publication automatisée (`release.yml`) : sur tag `v*`, génération d'un `.dmg` et création de la GitHub Release avec l'asset attaché.
- Templates GitHub : rapport de bug, demande de fonctionnalité et pull request.

[Unreleased]: https://github.com/jherduin/ClawdNotch/commits/main
