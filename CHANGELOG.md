# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et le projet adhère au
[Semantic Versioning](https://semver.org/lang/fr/).

## [Unreleased]

## [1.0.0] - 2026-06-02

### Added

- Distribution via Homebrew : `brew install --cask jherduin/tap/clawdnotch` (tap
  [`jherduin/homebrew-tap`](https://github.com/jherduin/homebrew-tap)).

Première version stable. Aucun changement de comportement de l'app depuis `0.1.0`.

## [0.1.0] - 2026-06-02

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

### Changed

- Halo affiné : trait hairline épousant la silhouette visible du notch (coins bas arrondis au rayon
  réel), dégradé concentrant l'éclat sur le bord inférieur, et lueur plus présente pour le bleu
  (`waiting`) que pour l'orange (`working`).
- README : la configuration des hooks se fait désormais via un prompt à copier dans Claude Code
  (fusion automatique avec les hooks existants) ; le bloc JSON manuel reste en fallback dans
  `docs/hooks.md`.

[Unreleased]: https://github.com/jherduin/ClawdNotch/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/jherduin/ClawdNotch/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/jherduin/ClawdNotch/releases/tag/v0.1.0
