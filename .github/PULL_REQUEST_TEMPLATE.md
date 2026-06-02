<!-- Merci pour votre contribution ! Merci de remplir les sections ci-dessous. -->

## Description

Résumé du changement et de sa motivation. Lier l'issue concernée le cas échéant (`Closes #123`).

## Type de changement

- [ ] `fix` — correction de bug (non cassant)
- [ ] `feat` — nouvelle fonctionnalité (non cassant)
- [ ] `BREAKING CHANGE` — changement cassant (comportement existant modifié)
- [ ] `docs` — documentation uniquement
- [ ] `refactor` / `style` / `perf` / `test` / `chore` / `ci`

## Checklist

- [ ] Les commits suivent la convention [Conventional Commits](https://www.conventionalcommits.org/) (`<type>(<scope>): <description>`)
- [ ] Le `CHANGELOG.md` (section `[Unreleased]`) est mis à jour si le changement impacte l'utilisateur
- [ ] Testé sur un Mac **avec** notch (positionnement et halo corrects)
- [ ] Testé sur un Mac **sans** notch (aucune fenêtre créée, aucun crash) — ou simulé `safeAreaInsets.top == 0`
- [ ] L'app compile sans warning (`xcodegen generate` puis `xcodebuild`)
- [ ] La branche cible est `main` et part d'une branche `feat/xxx` ou `fix/xxx`

## Notes pour le relecteur

Points d'attention, décisions de conception, captures avant/après, etc.
