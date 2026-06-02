# Lessons — ClawdNotch

## NSHostingView + contenu conditionnel = pas de redraw (2026-06-02)

**Symptôme** : `NotchOverlayView` ne dessinait jamais le halo piloté par le statut,
alors qu'un `Color` plein-cadre ou un style *forcé* (toujours présent) rendait
parfaitement, et que les logs prouvaient que la vue *observait* bien les
changements (`onChange status=working`).

**Cause racine** : insérer/retirer une sous-vue via `if let style = ... { Shape() }`
dans une `NSHostingView` posée comme `contentView` d'une `NSWindow` AppKit ne
déclenche pas de passe de layout/affichage correcte. La vue se ré-évalue mais le
hosting view ne redessine pas le contenu nouvellement apparu.

**Règle** : dans une `NSHostingView` hors `WindowGroup`, **ne jamais** faire
apparaître/disparaître du contenu par `if`. Garder la hiérarchie **stable** et
piloter la visibilité par `.opacity(... ? x : 0)` / couleur. Idem pour les
transitions d'état : opacité, pas insertion conditionnelle.

**Méthode de debug qui a marché** : isoler par couches —
1. `NSView` opaque (layer orange) → prouve le footprint/placement fenêtre.
2. `Color.green` plein-cadre SwiftUI → prouve que SwiftUI rend.
3. `.fill` inconditionnel → prouve la position du Shape.
4. style *forcé* (sans dépendance au statut) → isole « rendu » vs « observation ».
Chaque étape vérifiée par `screencapture -x -R` + lecture des pixels.

## Géométrie du notch : ne pas se fier à NSScreen.main

En app `.accessory` sans fenêtre clé, `NSScreen.main` peut être `nil` ou pointer
un écran externe. Détecter l'écran avec notch via
`safeAreaInsets.top > 0 && auxiliaryTopLeftArea/RightArea != nil`.
Le notch étant tout en haut, son bord *supérieur* est hors écran : on ne peut
éclairer que ses bords **visibles** (côtés + bas).

## Outils

- Logs `os.Logger` non persistés au niveau `.info` → capturer en live avec
  `/usr/bin/log stream --predicate 'subsystem == "..."' --info` (chemin absolu :
  le hook RTK réécrit `log`/`grep`/`cat` sinon).

## Git / GitHub Desktop : main local sans tracking (2026-06-02)

**Symptôme** : GitHub Desktop voulait « Publish » la branche `main` alors qu'elle
existe déjà sur le remote ; user bloqué.

**Cause** : `main` local restait à l'`Initial commit` **sans upstream** vers
`origin/main` (les PR avaient été mergées côté serveur). Desktop voyait un `main`
« inconnu » → bouton Publish (qui aurait diverge le vrai main).

**Fix** : `git fetch` → `git merge --ff-only origin/main` →
`git branch --set-upstream-to=origin/main main`. Vérifier avec `git branch -vv`
(la présence de `[origin/main]`). **Réflexe** : si Desktop propose Publish d'une
branche qui existe sur le remote, c'est un tracking cassé → Fetch/Pull, pas Publish.

**Piège annexe** : un « Discard all changes » de GitHub Desktop supprime aussi les
fichiers *untracked* (c'est ainsi que `tasks/lessons.md` a été effacé une fois).
