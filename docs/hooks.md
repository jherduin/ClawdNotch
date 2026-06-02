# Configuration des hooks Claude Code

ClawdNotch est un signal **passif** : il lit le fichier `~/.claude/notch_status` et affiche un halo
autour du notch selon sa valeur. Il n'écrit jamais ce fichier lui-même. Ce sont les **hooks Claude
Code** qui le mettent à jour en temps réel selon l'activité du harness.

## Mapping état ↔ hook

| Hook | Valeur écrite | Visuel | Sens |
|---|---|---|---|
| `PreToolUse` | `working` | halo orange animé | un outil démarre, Claude travaille |
| `PostToolUse` | `idle` | invisible | l'outil est terminé |
| `Stop` | `waiting` | pulsation bleue douce | Claude a fini son tour, il attend ta réponse |

## Snippet prêt à copier

Colle ce bloc dans `~/.claude/settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "echo working > \"$HOME/.claude/notch_status\"" }] }
    ],
    "PostToolUse": [
      { "matcher": "", "hooks": [{ "type": "command", "command": "echo idle > \"$HOME/.claude/notch_status\"" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "echo waiting > \"$HOME/.claude/notch_status\"" }] }
    ]
  }
}
```

Détails :

- `"matcher": ""` cible **tous** les outils. Les événements `Stop` n'utilisent pas de matcher.
- On utilise `$HOME` plutôt que `~` : l'expansion du tilde dépend du shell qui exécute le hook,
  `$HOME` est fiable partout.
- `echo … >` tronque le fichier en place (événement `.write`), ce que la surveillance `DispatchSource`
  de `StatusWatcher.swift` détecte immédiatement. Le retour à la ligne ajouté par `echo` est neutralisé
  côté app (le statut est *trimmé* avant lecture).

## ⚠️ Fusion, pas remplacement

Si ton `settings.json` contient **déjà** une clé `hooks` (par exemple un autre hook `PreToolUse`),
n'écrase pas la clé entière : **ajoute** les blocs ClawdNotch aux tableaux existants. Plusieurs blocs
`matcher` coexistent sans problème dans un même événement.

Exemple de cohabitation avec un hook existant sur `PreToolUse` :

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "mon-hook-existant" }] },
      { "matcher": "",     "hooks": [{ "type": "command", "command": "echo working > \"$HOME/.claude/notch_status\"" }] }
    ]
  }
}
```

## Limitation connue

`PostToolUse → idle` éteint le halo **entre deux outils** d'un même tour : la séquence visuelle est
`working → idle → working`. C'est le comportement spécifié pour la première version ; il pourra être
raffiné plus tard (par ex. ne repasser à `idle` que via le hook `Stop`) si le clignotement gêne.

## Vérification

1. **Round-trip manuel** (l'app doit tourner pour voir le halo) :
   ```sh
   echo working > ~/.claude/notch_status   # halo orange
   echo waiting > ~/.claude/notch_status   # pulsation bleue
   echo idle    > ~/.claude/notch_status   # invisible
   ```

2. **Hooks réels** : après avoir collé le snippet, lance n'importe quelle commande dans Claude Code,
   puis inspecte le fichier :
   ```sh
   cat ~/.claude/notch_status
   ```
   Il doit valoir `working` pendant qu'un outil tourne, `idle` juste après, et `waiting` quand Claude
   a rendu la main.
