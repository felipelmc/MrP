#!/usr/bin/env bash
# Configura um repositório recém-criado a partir do template para uma disciplina nova.
# Uso: ./scripts/novo-curso.sh "Nome da disciplina" "Subtítulo" "Instituição" "2026.2"
set -euo pipefail
nome="${1:?nome da disciplina}"; sub="${2:-}"; inst="${3:-IESP-UERJ}"; periodo="${4:-}"
repo="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"

cat > _quarto.yml <<YML
project:
  type: course-notes
  render:
    - index.qmd
    - aulas/*.qmd
    - listas/*.qmd
    - trabalhos/index.qmd
    - trabalhos/*/index.qmd
    - referencias.qmd

book:
  title: "$nome"
  subtitle: "$sub"
  author: "Felipe Lamarca"
  date: last-modified
  site-url: https://felipelamarca.com/$repo/
  repo-url: https://github.com/felipelmc/$repo
  repo-actions: [source, issue]
  navbar:
    left:
      - text: "$nome"
        href: index.qmd
  chapters:
    - index.qmd
    - part: "Aulas"
      chapters:
        - href: aulas/aula-01.qmd
          text: "01 · Primeira aula"
    - part: "Trabalhos"
      chapters:
        - trabalhos/index.qmd
    - referencias.qmd

bibliography: [references.bib]
YML

cat > index.qmd <<QMD
---
title: "$nome"
subtitle: "$sub"
eyebrow: "$inst · $periodo"
byline: "Anotações de Felipe Lamarca"
---

Descrição da disciplina.

## Informações

- Professor(a):
- Período: $periodo
- Ementa: [PDF](ementa.pdf)

## Plano de aulas

| Aula | Tema |
|:--|:--|
| 01 | |

::: {.callout-note}
## Anotações pessoais
Estas são anotações de aluno, feitas durante a disciplina, e podem conter erros. Citações literais ficam como no original, com a página. Explicações escritas com auxílio de IA aparecem em caixas identificadas.
:::
QMD

rm -rf guia trabalhos/snow-tabela-ix trabalhos/apresentacao listas _freeze _book
mkdir -p aulas trabalhos
git mv -f aulas/aula-01.qmd aulas/_modelo.qmd 2>/dev/null || mv aulas/aula-01.qmd aulas/_modelo.qmd
_extensions/felipelmc/course-notes/tools/nova-aula.sh 1 "Primeira aula" >/dev/null
: > references.bib
sed -i.bak "s/Disciplinas que usam o template.*//" README.md 2>/dev/null && rm -f README.md.bak
rm -f scripts/novo-curso.sh
rmdir scripts 2>/dev/null || true
echo "Pronto. Rode 'quarto preview' para ver o site."
