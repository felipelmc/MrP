# =============================================================================
# mundo_religiao.R
# Extensao do mundo sintetico para o capitulo 7: cada pessoa recebe uma
# religiao, sorteada com as probabilidades do Censo 2022 (microdados publicos
# da amostra, IBGE) dentro da sua celula de UF x sexo x faixa etaria x
# escolaridade x cor/raca. A religiao afeta a atitude e a participacao no
# painel, mas nao esta no frame base: e a selecao "fora do frame".
# Uso: source(here::here("R/mundo.R")); source(here::here("R/mundo_religiao.R"))
# =============================================================================

RELIGIOES <- c("Católica", "Evangélica", "Sem religião", "Outras")

# Efeitos ficticios na escala logit sobre a atitude (desfecho y_rel)
EFEITOS_RELIGIAO <- c("Católica" = 0, "Evangélica" = -0.6, "Sem religião" = 0.4, "Outras" = 0.2)

# Multiplicadores ficticios das odds de participar do painel
SELECAO_RELIGIAO <- c("Católica" = 1, "Evangélica" = 0.6, "Sem religião" = 1.5, "Outras" = 1.2)

carregar_mundo_religiao <- function(mundo = carregar_mundo()) {
  arquivo_censo <- here::here("dados/censo2022_religiao.rds")
  censo <- readRDS(arquivo_censo) |>
    mutate(across(c(estado, sexo, faixa_etaria, escolaridade_3cat, cor_raca), as.character))
  pop <- mundo$pop

  # probabilidades por celula completa e, na falta dela, por UF x sexo x faixa
  largura <- function(d, vars) {
    d |>
      group_by(across(all_of(c(vars, "religiao_4cat")))) |>
      summarise(N = sum(N), .groups = "drop_last") |>
      mutate(p = N / sum(N)) |>
      ungroup() |>
      select(-N) |>
      tidyr::pivot_wider(names_from = religiao_4cat, values_from = p, values_fill = 0)
  }
  p_celula <- largura(censo, VARS_FRAME)
  p_reserva <- largura(censo, c("estado", "sexo", "faixa_etaria"))

  chaves <- pop |> mutate(across(all_of(VARS_FRAME), as.character)) |> select(all_of(VARS_FRAME))
  probs <- left_join(chaves, p_celula, by = VARS_FRAME)
  faltam <- is.na(probs[[RELIGIOES[1]]])
  probs[faltam, RELIGIOES] <- left_join(chaves[faltam, ], p_reserva,
                                        by = c("estado", "sexo", "faixa_etaria"))[, RELIGIOES]
  P <- as.matrix(probs[, RELIGIOES])
  P <- P / rowSums(P)

  set.seed(PARAMETROS$semente + 20)
  u <- runif(nrow(P))
  religiao <- RELIGIOES[1 + rowSums(u > t(apply(P, 1, cumsum)))]

  pop <- pop |>
    mutate(religiao_4cat = factor(religiao, levels = RELIGIOES),
           prob_rel      = plogis(unname(preditor_linear(pop, mundo$alpha_estado)) +
                                    unname(EFEITOS_RELIGIAO[religiao])),
           y_rel         = rbinom(n(), 1, prob_rel),
           odds_sel_rel  = odds_sel * unname(SELECAO_RELIGIAO[religiao]))
  arquivo <- here::here("R/mundo_religiao.R")
  modifyList(mundo, list(
    pop = pop,
    celulas_sem_censo = mean(faltam),
    chave = c(mundo$chave, unname(tools::md5sum(c(arquivo, arquivo_censo))))
  ))
}

# Amostra opt-in em que a participacao tambem depende da religiao
amostrar_optin_rel <- function(pop, n = 2000) {
  pop[sample.int(nrow(pop), n, prob = pop$odds_sel_rel), ]
}
