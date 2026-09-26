# MrP

Estudo de métodos sobre regressão multinível com pós-estratificação (MrP), publicado em **[felipelamarca.com/MrP](https://felipelamarca.com/MrP/)**.

O texto foi escrito com o Claude (Anthropic); cada capítulo abre com um aviso que diz se já foi revisado pelo autor. Os exemplos usam um mundo sintético: a composição da PNAD Contínua 2022, a seleção de um painel _online_ brasileiro e efeitos fictícios definidos em `R/mundo.R`.

Feito com o [Course Notes](https://felipelamarca.com/Course-Notes-Template/).

## Reproduzir

```bash
Rscript -e 'pak::local_install_deps()'
Rscript -e 'cmdstanr::install_cmdstan()'
quarto render
```

## Licença

Código sob [MIT](LICENSE). Textos sob [CC BY 4.0](LICENSE-CONTENT.md).
