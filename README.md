# Course Notes

Template para as anotações das disciplinas que curso, publicado em **[felipelamarca.com/Course-Notes-Template](https://felipelamarca.com/Course-Notes-Template/)**.

*A Quarto book template and extension for course notes: annotated readings with verbatim quotes, class notes, in-browser simulations (OJS) and a coursework showcase, styled after [felipelamarca.com](https://felipelamarca.com/).*

Cada disciplina vira um livro Quarto com o mesmo desenho:

- leituras anotadas, com citações literais e página;
- anotações de aula, com definições, teoremas e provas recolhíveis;
- simulações interativas que rodam no navegador, com o código equivalente em R;
- uma vitrine dos trabalhos entregues, cada um com página própria, PDF e slides.

O visual segue o do site pessoal: texto corrido em Newsreader, interface em Geist, código em Geist Mono, modos claro e escuro sincronizados com o site.

## Disciplina nova

```bash
gh repo create felipelmc/Minha-Disciplina --public --template felipelmc/Course-Notes-Template --clone
cd Minha-Disciplina
./scripts/novo-curso.sh "Minha Disciplina" "Subtítulo" "IESP-UERJ" "2026.2"
quarto preview
```

## Repositório existente

```bash
quarto add felipelmc/Course-Notes-Template
```

Depois, troque `type: book` por `type: course-notes` no `_quarto.yml`. O passo a passo está no [guia](https://felipelamarca.com/Course-Notes-Template/guia/comecando.html).

## Atualizar

```bash
quarto update extension felipelmc/Course-Notes-Template
```

## O que está aqui

| Caminho | Conteúdo |
|:--|:--|
| `_extensions/felipelmc/course-notes/` | a extensão: tema, fontes, bloco de título, filtros, vitrine, utilitários de OJS e R, checagens |
| `guia/`, `aulas/`, `trabalhos/` | o livro de demonstração, que também é a documentação |
| `.github/workflows/publish.yml` | render com `_freeze/` e publicação no GitHub Pages |
| `CLAUDE.md` | convenções para o Claude Code, copiadas para cada disciplina |

## Licença

Código sob [MIT](LICENSE). Textos do livro de demonstração sob [CC BY 4.0](LICENSE-CONTENT.md). As fontes Geist, Geist Mono e Newsreader são distribuídas sob a SIL Open Font License 1.1 (ver `_extensions/felipelmc/course-notes/fonts/`). O estilo ABNT em `csl/` vem do [Quarto-Model-IESP](https://github.com/felipelmc/Quarto-Model-IESP).
