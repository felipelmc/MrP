# =============================================================================
# mundo.R
# Mundo sintetico usado nos exemplos do livro.
#
# - dados/populacao.rds: 200 mil pessoas com a composicao da PNADC 2022 (16+),
#   reamostradas com probabilidade proporcional ao peso V1032
# - dados/selecao.rds: modelo de selecao que imita a composicao de um painel
#   online brasileiro de 2023 (regressao logistica painel x PNADC)
# - PARAMETROS: efeitos ficticios sobre a atitude y, definidos aqui
#
# Uso: source(here::here("R/mundo.R")); mundo <- carregar_mundo()
# =============================================================================

suppressMessages(library(dplyr))

NIVEIS <- list(
  sexo              = c("Masculino", "Feminino"),
  faixa_etaria      = c("16_24", "25_34", "35_44", "45_54", "55_64", "65_+"),
  escolaridade_3cat = c("Ensino Fundamental", "Ensino Médio", "Ensino Superior"),
  cor_raca          = c("Branca", "Parda", "Preta", "Outras")
)

VARS_FRAME <- c("estado", "sexo", "faixa_etaria", "escolaridade_3cat", "cor_raca")

# -----------------------------------------------------------------------------
# Parametros do desfecho (escala logit). Sao ficticios, com magnitudes
# plausiveis: a atitude e mais frequente entre pessoas mais escolarizadas e
# mais jovens, justamente os grupos que o painel sobre-representa.
# -----------------------------------------------------------------------------
PARAMETROS <- list(
  intercepto   = 0.2,
  escolaridade = c("Ensino Fundamental" = 0, "Ensino Médio" = 0.5, "Ensino Superior" = 0.9),
  cor_raca     = c("Branca" = 0, "Parda" = 0.1, "Preta" = 0.35, "Outras" = 0),
  sexo         = c("Masculino" = 0, "Feminino" = 0.3),
  faixa_etaria = c("16_24" = 0, "25_34" = -0.1, "35_44" = -0.2,
                   "45_54" = -0.3, "55_64" = -0.45, "65_+" = -0.6),
  sigma_estado = 0.3,   # desvio-padrao dos efeitos de UF
  semente      = 2026
)

# Efeitos de UF: sorteados de uma normal e reescalados para terem media zero e
# desvio-padrao exatamente igual a sigma_estado
efeitos_estado <- function(ufs, par = PARAMETROS) {
  set.seed(par$semente)
  a <- rnorm(length(ufs))
  setNames((a - mean(a)) / sd(a) * par$sigma_estado, ufs)
}

preditor_linear <- function(pop, alpha, par = PARAMETROS) {
  par$intercepto +
    par$escolaridade[as.character(pop$escolaridade_3cat)] +
    par$cor_raca[as.character(pop$cor_raca)] +
    par$sexo[as.character(pop$sexo)] +
    par$faixa_etaria[as.character(pop$faixa_etaria)] +
    alpha[pop$estado]
}

# Odds relativas de inclusao no painel (a constante nao importa para amostrar)
odds_selecao <- function(pop, selecao) {
  X <- model.matrix(as.formula(selecao$formula),
                    mutate(pop, estado = factor(estado, selecao$niveis$estado)))
  exp(drop(X %*% selecao$coeficientes[colnames(X)]))
}

carregar_mundo <- function(par = PARAMETROS) {
  arquivos <- here::here(c("dados/populacao.rds", "dados/selecao.rds", "R/mundo.R"))
  pop      <- readRDS(arquivos[1])
  selecao  <- readRDS(arquivos[2])
  alpha    <- efeitos_estado(selecao$niveis$estado, par)
  set.seed(par$semente + 1)
  pop <- pop |>
    mutate(prob     = plogis(unname(preditor_linear(pop, alpha, par))),
           y        = rbinom(n(), 1, prob),
           odds_sel = odds_selecao(pop, selecao))
  list(pop = pop, alpha_estado = alpha, par = par, verdade = mean(pop$y),
       chave = unname(tools::md5sum(arquivos)))
}

# -----------------------------------------------------------------------------
# Amostras e frame
# -----------------------------------------------------------------------------

# Amostra opt-in: probabilidade de inclusao proporcional as odds do painel
amostrar_optin <- function(pop, n = 2000) {
  pop[sample.int(nrow(pop), n, prob = pop$odds_sel), ]
}

# Amostra aleatoria simples, para comparacao
amostrar_aas <- function(pop, n = 2000) {
  pop[sample.int(nrow(pop), n), ]
}

# Frame de pos-estratificacao: numero de pessoas por celula
frame_populacao <- function(pop, vars = VARS_FRAME) {
  pop |> count(across(all_of(vars)), name = "N")
}

# -----------------------------------------------------------------------------
# Computacoes demoradas
# -----------------------------------------------------------------------------

# Guarda o resultado em _cache-sim/<nome>.rds e so recalcula quando a chave
# muda. A chave deve incluir tudo de que o resultado depende.
com_cache <- function(nome, chave, expr) {
  arquivo <- here::here("_cache-sim", paste0(nome, ".rds"))
  if (file.exists(arquivo)) {
    x <- readRDS(arquivo)
    if (identical(x$chave, chave)) return(x$valor)
  }
  valor <- expr
  dir.create(dirname(arquivo), showWarnings = FALSE)
  saveRDS(list(chave = chave, valor = valor), arquivo)
  valor
}

# Replicas de Monte Carlo em paralelo, cada uma com sua semente
monte_carlo <- function(R, fun, cores = 8, seed = 1) {
  res <- parallel::mclapply(seq_len(R), function(r) {
    set.seed(seed * 1e5 + r)
    fun(r)
  }, mc.cores = cores)
  bind_rows(res)
}
