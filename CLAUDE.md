# CLAUDE.md

Orientações para o Claude Code neste repositório: um estudo de métodos sobre MrP, e não anotações de disciplina.

## Exceção deste livro: texto escrito com IA

O texto dos capítulos foi escrito com o Claude, a pedido do autor. Por isso, **neste livro**, a regra de `::: nota-ia` (abaixo, em "Política de conteúdo") não vale para o corpo dos capítulos: cada capítulo abre com `{{< include _aviso-ia.qmd >}}`, logo depois do cabeçalho, e o texto segue sem caixas. Quando o autor revisar um capítulo, o aviso daquele capítulo é trocado por um que diga "revisado pelo autor". Comentários que o próprio autor acrescentar ficam fora de qualquer caixa. As demais convenções do template (estilo, matemática, bibliografia, figuras) continuam valendo.

## Exceção deste livro: coluna de leitura mais larga

A pedido do autor (2026-09-26), a coluna de texto tem 820 px, contra 670 px do template, por causa das fórmulas, tabelas e blocos de código. A sobrescrita fica em `tema/largura.scss`, aplicada por cima do tema da extensão no bloco `format:` do `_quarto.yml` (a única coisa além dos dados do livro e da ordem dos capítulos). Se a mudança for levada ao template, apague os dois.

## O que é

Um livro Quarto, publicado em `felipelamarca.com/MrP/`. O visual e os componentes vêm da extensão `_extensions/felipelmc/course-notes/`, mantida em [felipelmc/Course-Notes-Template](https://github.com/felipelmc/Course-Notes-Template). O `_quarto.yml` do repositório só tem os dados da disciplina, a ordem dos capítulos e a sobrescrita da largura (seção acima).

## Comandos

```bash
quarto preview                                              # servidor local com reload
quarto render                                               # renderiza tudo e atualiza _freeze/
python3 _extensions/felipelmc/course-notes/tools/check.py pre        # checagens do CI
python3 _extensions/felipelmc/course-notes/tools/check.py post _book
quarto update extension felipelmc/Course-Notes-Template     # atualizar o template
```

## Publicação e `_freeze/`

- O CI (`.github/workflows/publish.yml`) **não executa R**. Ele renderiza com os resultados em `_freeze/`, que vai para o git, e publica no GitHub Pages (modo "GitHub Actions").
- Depois de editar qualquer página com blocos `{r}`, rode `quarto render` localmente e faça o commit de `_freeze/` junto. Se não fizer, `check.py pre` falha no CI.
- Pacotes de R usados nas páginas ficam listados no `DESCRIPTION`.
- Nunca faça o commit de `_book/` e nunca use `output-dir: docs`.

## Estrutura e convenções

- Capítulos em `capitulos/NN-slug.qmd` (dois dígitos). Cabeçalho: `title`, `description` e `eyebrow: "Capítulo NN"` (não há `aulas/` neste livro). Todo capítulo novo precisa entrar em `book.chapters` no `_quarto.yml`, com `text: "NN · Título"`; só entram capítulos prontos.
- Esqueleto de um capítulo: aviso de IA, bloco de setup (`#| include: false`), `## Intuição`, `## Formalização`, `## Em R`, `## Simulação` (OJS, opcional), `## Armadilhas`, `## Leituras`. Rótulos de blocos com prefixo `cN-`.
- Referências a outros capítulos são links (`[capítulo 2](02-modelos-multinivel.qmd)`): equações e seções só têm referência cruzada dentro da mesma página, então uma equação usada em outro capítulo é repetida.
- O mundo sintético está em `R/mundo.R` (parâmetros fictícios em `PARAMETROS`) e `dados/` (composição da PNADC e coeficientes de seleção, exportados do repositório privado de pesquisa por `estudo_mrp/R/exportar_mundo.R`). Nenhum dado do survey entra aqui. Simulações demoradas usam `com_cache()` (pasta `_cache-sim/`) e os modelos `brms` usam `file = here::here("modelos", ...)` com `file_refit = "on_change"`; as duas pastas ficam fora do git. Números no texto passam por `num()`, `pct()` e `inteiro()` de `R/utils.R` (vírgula decimal).
- Extensões do mundo para capítulos específicos ficam em arquivos próprios (`R/mundo_interacao.R`, `R/mundo_religiao.R`, `R/mundo_desfechos.R`), cada uma acrescentando o próprio md5 à chave. Nunca edite `R/mundo.R` sem necessidade: ele entra na chave de cache de todos os capítulos, e qualquer mudança refaz todos os Monte Carlos (os dos capítulos 4 e 5 levam dezenas de minutos).
- Ajustes `brms` lidos do arquivo (`file = ...`) não trazem o modelo compilado. Antes de um Monte Carlo com `update(..., recompile = FALSE)`, compile um molde com `update(fit, recompile = TRUE, chains = 1, iter = 20)` dentro da expressão de `com_cache()`, para que só rode quando o cache precisar ser refeito.
- A pós-estratificação por sorteio está em `R/mrp.R` (`pos_estratificar()`, `resumir_draws()`). Estimandos não lineares (produtos de duas partes, medianas, escores de IRT) são calculados célula a célula antes de agregar; ver o capítulo 8.
- Citações literais: `> texto [@chave, p. N]`. Uma única bibliografia, `references.bib`, com chaves `sobrenomeANOpalavra`.
- **Nunca use `::: {#refs}`**: num livro, ele junta a bibliografia inteira numa página e esconde as referências das outras. As referências saem sozinhas no fim de cada página.
- Nunca declare `format: html` no `_quarto.yml` nem nas páginas; o formato vem da extensão.
- Simulações em OJS ficam no próprio arquivo da aula, numa seção `## Simulação` no fim (nunca em arquivo incluído: o `_freeze` só enxerga o texto do arquivo da aula); o texto que as apresenta, se escrito com IA, vai em `::: {.nota-ia collapse="false" ...}`. Importe de `/_extensions/felipelmc/course-notes/ojs/notes.js`, use `rng(semente)` e `palette(scheme())`, envolva em `::: cn-sim` dentro de `::: panel-tabset` com as abas "Interativo" e "Em R" (esta com `#| eval: false`).
- Figuras em R: `source(here::here("_extensions/felipelmc/course-notes/r/notes.R"))` e `theme_notes()`. Caminhos de dados sempre com `here::here()`, nunca absolutos.

## Matemática

- Linha em branco antes e depois de `$$`; `aligned` para alinhar.
- `^\top` para transposta, `\mathbb{E}`, `\mathbb{V}`, `\text{Cov}`, `\perp\!\!\!\perp`.
- Ambientes: `::: {#def-...}`, `::: {#thm-...}`, `::: prova` (recolhível).
- Resultado central: `$\boxed{...}$`.
- Opções de bloco em `#| chave: valor`, nunca `{r, eval=F}`.

## Política de conteúdo

- **Citações são literais.** Não corrija nada dentro de `>`, a não ser trocar `(p. N)` por `[@chave, p. N]` ou consertar LaTeX quebrado. Citação em outra língua fica na língua original.
- **Os comentários e as anotações de aula são do autor.** Polimento leve é permitido (ortografia, concordância, palavra faltando, travessão, títulos em *sentence case*). Não mude afirmações, números, ordem dos argumentos nem a língua, e não apague coloquialismos.
- **Texto escrito com IA vai sempre em `::: nota-ia`** (use `ferramenta="NotebookLM"` etc. quando não for o Claude). Nunca misture explicação gerada com a voz do autor fora dessa caixa.
- Erros de conteúdo (uma derivação errada, uma afirmação duvidosa) são apontados ao autor, e não corrigidos por conta própria.
- Nunca invente citação, página ou referência.

## Estilo de escrita do autor

- Sem negrito no corpo do texto (só na primeira ocorrência de um termo definido) e sem travessão; use vírgula, dois-pontos ou parênteses.
- Dois-pontos e ponto e vírgula em enumerações são bem-vindos.
- Conectivos dele: "De fato", "Note que", "Em particular", "por sua vez", "isto é", "sobretudo", "Por fim". Nunca: "Com efeito", "Nesse sentido", "Dito isso", "Cabe destacar", "É importante notar".
- Evite marcas de IA: crucial, inovador, abrangente, robusto (fora do sentido técnico), sinergia, panorama, cenário (metafórico), ademais, notavelmente, potencializar.
- Números com vírgula decimal e `%`. Títulos em *sentence case*. Termos técnicos em inglês em itálico.
- Comentários em scripts de R e Python são escritos sem acentuação, de propósito.
