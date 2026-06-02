# Plan de développement — ClawdNotch

> App macOS minimaliste affichant un halo coloré autour du notch selon l'état de Claude Code.
> Ce document liste toutes les étapes, de l'amorçage du projet jusqu'à la release `v1.0.0` (Homebrew).

**Légende :** `[ ]` à faire · `[~]` en cours · `[x]` fait

---

## Phase 0 — Amorçage du dépôt

État actuel : seuls `LICENSE`, `.gitattributes` et `claude.md` existent. Tout le reste est à créer.

- [x] Renommer/normaliser `claude.md` → `CLAUDE.md` (cohérence avec la convention) ou confirmer le choix de casse
- [x] Créer `.gitignore` adapté à Xcode/Swift (`build/`, `DerivedData/`, `*.xcuserstate`, `.DS_Store`, `xcuserdata/`)
- [x] Vérifier que `LICENSE` (MIT) porte bien le copyright du mainteneur — OK, MIT, © 2026 jherduin
- [x] Créer la branche de travail `feat/bootstrap` (jamais de commit direct sur `main`)

---

## Phase 1 — Squelette du projet Xcode

> **Approche retenue (option C) :** un `Package.swift` (executableTarget, macOS 14) sert
> de squelette buildable pour valider le code avec `swift build`. Le `.xcodeproj` est
> généré par **XcodeGen** depuis `project.yml` (source de vérité), par-dessus les mêmes sources.
> ✅ `Package.swift` · `swift build` sans warning · `.xcodeproj` généré · `xcodebuild` → BUILD SUCCEEDED.

- [x] Créer le projet Xcode `ClawdNotch.xcodeproj` (app macOS, SwiftUI lifecycle) — généré via `project.yml` + XcodeGen
  - [x] Target macOS 14.0 minimum
  - [x] Swift 5.9+
  - [x] Aucune dépendance externe
- [x] Configurer `Info.plist` :
  - [x] `LSUIElement = YES` (pas d'icône Dock, app en arrière-plan) — vérifié dans le bundle
  - [x] Bundle identifier (`com.jherduin.clawdnotch`)
  - [x] Version `0.1.0`
- [x] Vérifier que l'app compile (`xcodebuild` → BUILD SUCCEEDED, `.app` produit)
- [ ] Vérifier qu'elle se lance sans fenêtre ni icône Dock — _test live à faire (signature ad-hoc requise sur Apple Silicon)_

---

## Phase 2 — Implémentation des 5 fichiers Swift

Architecture : une responsabilité par fichier (cf. CLAUDE.md).

### 2.1 `ClawdNotchApp.swift` — point d'entrée
- [x] Définir l'`@main` App SwiftUI sans `WindowGroup` principal (`Settings { EmptyView() }`)
- [x] Supprimer l'icône Dock (`NSApp.setActivationPolicy(.accessory)`)
- [x] Instancier le `NotchWindowController` et le `StatusWatcher` au lancement
- [x] Câbler le cycle de vie (AppDelegate via `NSApplicationDelegateAdaptor`)

### 2.2 `NotchGeometry.swift` — calcul géométrique
- [x] Lire les `safeAreaInsets` de l'écran principal (`NSScreen.main`)
- [x] Calculer position (x, y) et dimensions (largeur, hauteur) du notch (via `auxiliaryTopLeftArea`/`auxiliaryTopRightArea`)
- [x] Cas Mac sans notch : `safeAreaInsets.top == 0` → retourner `nil` (pas de rendu)
- [ ] Gérer le changement d'écran / résolution (recalcul) — _à câbler en Phase 3 (observer `NSApplication.didChangeScreenParametersNotification`)_

### 2.3 `NotchWindowController.swift` — fenêtre overlay
- [x] Créer une `NSWindow` :
  - [x] transparente (`backgroundColor = .clear`, `isOpaque = false`)
  - [x] sans ombre (`hasShadow = false`)
  - [x] non-interactive (`ignoresMouseEvents = true`)
  - [x] niveau au-dessus de la menu bar (`level = .statusBar`)
  - [x] visible sur tous les espaces (`collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]`)
- [x] Positionner la fenêtre via `NotchGeometry`
- [x] Héberger la `NotchOverlayView` (SwiftUI dans `NSHostingView`)
- [x] Ne pas créer la fenêtre si `NotchGeometry` renvoie `nil`

### 2.4 `StatusWatcher.swift` — surveillance du fichier
- [x] Chemin cible : `~/.claude/notch_status`
- [x] Créer le fichier (et `~/.claude/` si absent) avec valeur initiale `idle`
- [x] Surveiller via `DispatchSource` (FileSystemObject) — **pas de polling**
- [x] Parser les 3 valeurs : `working`, `waiting`, `idle`
- [x] Publier l'état courant (`@Published` / `ObservableObject`)
- [x] Gérer la recréation du fichier s'il est supprimé/remplacé (réarmer la source)

### 2.5 `NotchOverlayView.swift` — rendu visuel
- [x] Vue SwiftUI pilotée par l'état du `StatusWatcher`
- [x] État `working` → halo orange animé
- [x] État `waiting` → pulsation bleue douce
- [x] État `idle` → invisible
- [x] Animations subtiles (signal ambiant, pas notification agressive)
- [x] Transitions douces entre états (`.animation(.easeInOut, value:)`)

---

## Phase 3 — Intégration & tests manuels

- [ ] Tester l'écriture manuelle dans le fichier de statut :
  - [ ] `echo working > ~/.claude/notch_status` → halo orange
  - [ ] `echo waiting > ~/.claude/notch_status` → pulsation bleue
  - [ ] `echo idle > ~/.claude/notch_status` → invisible
- [ ] Tester sur Mac **avec** notch (positionnement correct)
- [ ] Tester sur Mac **sans** notch (aucun crash, aucune fenêtre) — ou simuler `safeAreaInsets.top == 0`
- [ ] Vérifier comportement multi-écrans / changement de résolution
- [ ] Vérifier l'absence d'icône Dock et de fenêtre dans le sélecteur d'apps
- [ ] Vérifier la consommation CPU au repos (≈ 0 grâce à `DispatchSource`)

---

## Phase 4 — Hooks Claude Code

- [x] Documenter la config des hooks dans `~/.claude/settings.json` :
  - [x] `UserPromptSubmit` + `PreToolUse` → écrire `working` dans `~/.claude/notch_status`
  - [x] `Stop` → écrire `waiting`
  - [x] `SessionEnd` → écrire `idle`
  - _Mapping corrigé après test live : `PostToolUse → idle` retiré car il faisait clignoter le halo
    entre deux outils d'un même tour (`working → idle → working`)._
- [x] Fournir un snippet JSON prêt à copier (voir `docs/hooks.md` ; le README y renverra en Phase 5)
- [x] Tester le cycle complet en lançant une vraie commande Claude Code

---

## Phase 5 — Documentation open-source

- [~] `README.md` (dans l'ordre imposé par CLAUDE.md) :
  - [ ] GIF du notch animé (à enregistrer une fois l'app lancée — emplacement réservé `docs/demo.gif`)
  - [x] Badges : version / license / build / macOS
  - [x] Description deux lignes
  - [x] Installation (Homebrew prioritaire dès v1.0.0, téléchargement manuel en fallback)
  - [x] Setup des hooks
  - [x] Lien vers CONTRIBUTING
- [x] `CONTRIBUTING.md` (conventions de commit, branching, process de PR)
- [x] `CODE_OF_CONDUCT.md` (Contributor Covenant)
- [x] `CHANGELOG.md` (format Keep a Changelog, section `[Unreleased]`)

---

## Phase 6 — Templates & automatisation GitHub

- [ ] `.github/ISSUE_TEMPLATE/bug_report.md` (version macOS, modèle MacBook, version ClawdNotch, repro, logs Console.app)
- [ ] `.github/ISSUE_TEMPLATE/feature_request.md` (problème résolu, solution, alternatives)
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` (type de changement, CHANGELOG, testé avec/sans notch, commits conformes)
- [ ] `.github/workflows/build.yml` :
  - [ ] runner `macos-14`
  - [ ] build sans signing sur push et PR vers `main`
- [ ] `.github/workflows/release.yml` :
  - [ ] déclenché sur tag `v*`
  - [ ] produit un `.dmg`
  - [ ] crée la GitHub Release et attache le `.dmg`
- [ ] Protéger la branche `main` (réglage GitHub : PR obligatoire, pas de push direct)

---

## Phase 7 — Première release `v0.1.0`

- [ ] Créer branche `release/v0.1.0`
- [ ] Vérifier le bump de version dans le projet Xcode
- [ ] Finaliser le CHANGELOG (`[Unreleased]` → `[v0.1.0] - YYYY-MM-DD`)
- [ ] Commit `chore(release): bump version to 0.1.0`
- [ ] Merge dans `main` via PR
- [ ] Tag `v0.1.0` → vérifier le déclenchement de `release.yml`
- [ ] Vérifier que la GitHub Release contient bien le `.dmg`

---

## Phase 8 — Route vers `v1.0.0` (Homebrew)

- [ ] Stabiliser l'app sur plusieurs cycles `v0.x.x` (retours utilisateurs, bug fixes)
- [ ] Créer un tap Homebrew personnel
- [ ] Écrire le cask pointant vers le `.dmg` de la GitHub Release
- [ ] Tester `brew install --cask <tap>/clawdnotch`
- [ ] Release `v1.0.0` : mettre à jour le README avec l'install Homebrew en priorité

---

## Conventions transverses (rappel)

- **Commits :** Conventional Commits — `<type>(<scope>): <description>` (types : `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`)
- **Branches :** `main` protégée ; `feat/xxx`, `fix/xxx` via PR ; `release/vX.Y` pour préparer une version
- **Versioning :** SemVer 2.0.0, `v0.x.x` jusqu'à stabilisation
- **CHANGELOG :** Keep a Changelog, section `[Unreleased]` à chaque PR impactant l'utilisateur

---

## Ordre critique des dépendances

```
Phase 0 (bootstrap)
   └─> Phase 1 (Xcode)
          └─> Phase 2 (Swift) ──> 2.2 NotchGeometry doit précéder 2.3 NotchWindowController
                 └─> Phase 3 (tests manuels)
                        └─> Phase 4 (hooks) ──> nécessaire pour Phase 5 (GIF README)
                               └─> Phase 5 (docs) + Phase 6 (CI/CD) en parallèle
                                      └─> Phase 7 (v0.1.0)
                                             └─> Phase 8 (v1.0.0 / Homebrew)
```
