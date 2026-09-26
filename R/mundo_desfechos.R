# =============================================================================
# mundo_desfechos.R
# Extensao do mundo sintetico para o capitulo 8: desfechos nao binarios,
# todos com a mesma estrutura demografica de PARAMETROS (preditor linear eta).
#   - y_ord:   concordancia em 5 pontos (1 a 5), com "nao sei" (NA em y_ord,
#              TRUE em ns_ord), mais frequente entre quem tem menos escolaridade
#   - y_10:    escala de 1 a 10 (beta-binomial)
#   - y_rs:    valor em R$ lido numa regua discreta, com censura em 500 e 100.000
#   - item_1..item_6: itens binarios gerados por um traco latente (IRT 2PL)
# Uso: source(here::here("R/mundo.R")); source(here::here("R/mundo_desfechos.R"))
# =============================================================================

# Limiares do logit cumulativo (P(y <= k) = logit^-1(limiar_k - eta))
LIMIARES_ORD <- c(-1.2, -0.2, 0.9, 2.2)
# "Nao sei": logit da probabilidade, por escolaridade
NS_ORD <- c("Ensino Fundamental" = -2.0, "Ensino Médio" = -2.8, "Ensino Superior" = -3.3)
# Escala de 1 a 10: media (y - 1) / 9 = logit^-1(eta / 1.5), precisao phi
PHI_10 <- 8
# Valor em R$: log(valor) = MU_RS + 0.6 * eta + erro normal com desvio SIGMA_RS
MU_RS <- log(4000); SIGMA_RS <- 0.8
# Regua do questionario, sem passo fixo
GRADE_RS <- c(seq(500, 5000, 500), seq(6000, 10000, 1000),
              seq(15000, 50000, 5000), seq(60000, 100000, 10000))
# Itens do IRT: discriminacao a_k e dificuldade b_k; o traco latente de cada
# pessoa e normal com media eta - 0.6 e desvio 1
ITENS_A <- c(1.5, 1.2, 1.0, 0.8, 1.8, 0.6)
ITENS_B <- c(-1.0, -0.5, 0.0, 0.5, -1.5, 1.0)

# valor continuo -> valor lido na regua (o ponto mais proximo em escala log)
ler_regua <- function(x) {
  idx <- findInterval(log(x), (log(GRADE_RS[-1]) + log(GRADE_RS[-length(GRADE_RS)])) / 2) + 1
  GRADE_RS[idx]
}

carregar_mundo_desfechos <- function(mundo = carregar_mundo()) {
  pop <- mundo$pop
  eta <- unname(preditor_linear(pop, mundo$alpha_estado))
  n <- nrow(pop)
  set.seed(PARAMETROS$semente + 30)

  # ordinal com nao sei
  acum <- plogis(outer(-eta, LIMIARES_ORD, "+"))           # P(y <= k), k = 1..4
  u <- runif(n)
  y_ord <- 1 + rowSums(u > acum)
  ns_ord <- runif(n) < plogis(unname(NS_ORD[as.character(pop$escolaridade_3cat)]))

  # escala de 1 a 10
  mu10 <- plogis(eta / 1.5)
  p10 <- rbeta(n, mu10 * PHI_10, (1 - mu10) * PHI_10)
  y_10 <- 1 + rbinom(n, 9, p10)

  # valor em R$, lido na regua, com censura nos extremos
  valor <- exp(MU_RS + 0.6 * eta + rnorm(n, 0, SIGMA_RS))
  y_rs <- ler_regua(pmin(pmax(valor, 500), 100000))
  cens_rs <- case_when(valor < 500 ~ "left", valor > 100000 ~ "right", TRUE ~ "none")

  # itens do IRT
  theta <- eta - 0.6 + rnorm(n)
  itens <- sapply(seq_along(ITENS_A), \(k) rbinom(n, 1, plogis(ITENS_A[k] * (theta - ITENS_B[k]))))
  colnames(itens) <- paste0("item_", seq_along(ITENS_A))

  pop <- bind_cols(pop, tibble(eta, y_ord = if_else(ns_ord, NA_real_, y_ord), ns_ord,
                               y_10, valor_rs = valor, y_rs, cens_rs, theta),
                   as_tibble(itens))
  arquivo <- here::here("R/mundo_desfechos.R")
  modifyList(mundo, list(pop = pop, chave = c(mundo$chave, unname(tools::md5sum(arquivo)))))
}
