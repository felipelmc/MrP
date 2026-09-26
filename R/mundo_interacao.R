# =============================================================================
# mundo_interacao.R
# Extensao do mundo sintetico para o capitulo 5: dois desfechos em que o
# efeito da escolaridade muda com a idade, a combinacao que a selecao do
# painel distorce. Fica fora de R/mundo.R para nao mudar a chave de cache dos
# capitulos anteriores.
#   - y_int:   desfecho de interesse
#   - y_bench: "benchmark" com a mesma estrutura de interacao e efeitos
#              principais diferentes (o analista conheceria seu valor real)
# Uso: source(here::here("R/mundo.R")); source(here::here("R/mundo_interacao.R"))
# =============================================================================

# Desvios (escala logit) que se somam aos efeitos principais de PARAMETROS,
# por escolaridade (linhas) e faixa etaria (colunas). O efeito do ensino
# superior e maior entre os jovens e some entre os mais velhos.
INTERACAO <- rbind(
  "Ensino Fundamental" = c(0, 0, 0, 0, 0, 0),
  "Ensino Médio"       = c(0.25, 0.2, 0, -0.1, -0.25, -0.35),
  "Ensino Superior"    = c(0.5, 0.4, 0, -0.2, -0.5, -0.7)
)
colnames(INTERACAO) <- NIVEIS$faixa_etaria

# Parametros do benchmark: efeitos principais diferentes, mesma interacao
PARAMETROS_BENCH <- modifyList(PARAMETROS, list(
  intercepto   = -0.3,
  cor_raca     = c("Branca" = 0, "Parda" = 0.25, "Preta" = 0.2, "Outras" = 0.1),
  sexo         = c("Masculino" = 0, "Feminino" = -0.2),
  semente      = 2027
))

carregar_mundo_interacao <- function(mundo = carregar_mundo()) {
  pop <- mundo$pop
  delta <- INTERACAO[cbind(as.character(pop$escolaridade_3cat),
                           as.character(pop$faixa_etaria))]
  alpha_bench <- efeitos_estado(names(mundo$alpha_estado), PARAMETROS_BENCH)
  set.seed(PARAMETROS$semente + 10)
  pop <- pop |>
    mutate(prob_int   = plogis(unname(preditor_linear(pop, mundo$alpha_estado)) + delta),
           y_int      = rbinom(n(), 1, prob_int),
           prob_bench = plogis(unname(preditor_linear(pop, alpha_bench, PARAMETROS_BENCH)) + delta),
           y_bench    = rbinom(n(), 1, prob_bench))
  arquivo <- here::here("R/mundo_interacao.R")
  modifyList(mundo, list(pop = pop,
                         chave = c(mundo$chave, unname(tools::md5sum(arquivo)))))
}
