# Configuration des hooks Claude Code

ClawdNotch est un signal **passif** : il lit le fichier `~/.claude/notch_status` et affiche un halo
autour du notch selon sa valeur. Il n'écrit jamais ce fichier lui-même. Ce sont les **hooks Claude
Code** qui le mettent à jour en temps réel selon l'activité du harness.

## Mapping état ↔ hook

| Hook | Valeur écrite | Visuel | Sens |
|---|---|---|---|
| `UserPromptSubmit` | `working` | halo orange animé | tu envoies un prompt, Claude se met au travail |
| `PreToolUse` | `working` | halo orange animé | un outil démarre, Claude travaille toujours |
| `Stop` | `waiting` | pulsation bleue douce | Claude a fini son tour, il attend ta réponse |
| `SessionEnd` | `idle` | invisible | la session Claude Code se termine |

> **Pourquoi pas de `PostToolUse → idle` ?** Claude enchaîne souvent plusieurs outils dans un même
> tour. Repasser à `idle` après *chaque* outil ferait clignoter le halo (`working → idle → working`)
> alors que Claude est encore en train de travailler. On garde donc le halo orange pour tout le tour :
> il ne passe au bleu qu'au `Stop` (Claude rend la main) et ne devient invisible qu'en fin de session.

## Snippet prêt à copier

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

Détails :

- `"matcher": ""` cible **tous** les outils. Les événements `UserPromptSubmit`, `Stop` et `SessionEnd`
  n'utilisent pas de matcher.
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

## Vérification

1. **Round-trip manuel** (l'app doit tourner pour voir le halo) :
   ```sh
   echo working > ~/.claude/notch_status   # halo orange
   echo waiting > ~/.claude/notch_status   # pulsation bleue
   echo idle    > ~/.claude/notch_status   # invisible
   ```

2. **Hooks réels** : après avoir collé le snippet, le halo doit **rester orange** pendant tout un tour
   de Claude (même avec plusieurs outils enchaînés), passer au **bleu** dès que Claude rend la main,
   et **disparaître** quand tu quittes Claude Code. Tu peux inspecter le fichier à tout moment :
   ```sh
   cat ~/.claude/notch_status
   ```
