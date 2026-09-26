# =============================================================================
# mrp.R
# Pos-estratificacao por draw da posterior, em blocos de celulas para caber
# na memoria.
# =============================================================================

suppressMessages(library(dplyr))

# Devolve uma matriz draws x estimandos (ou um array draws x estimandos x
# categorias, para modelos categoricos e ordinais). `grupos` e um vetor de
# nomes de variaveis do frame: alem do estimando nacional ("Total"), calcula
# um estimando para cada nivel de cada variavel. `braco` (opcional): nome de
# uma variavel experimental; as predicoes sao feitas para cada nivel dela e
# a media e tirada com pesos iguais (populacao sob as duas ordens).
pos_estratificar <- function(fit, frame, grupos = character(0), ndraws = 1000,
                             bloco = 2000, braco = NULL, niveis_braco = NULL,
                             seed = 2023) {
  set.seed(seed)
  ids <- sample(seq_len(brms::ndraws(fit)), min(ndraws, brms::ndraws(fit)))

  # matriz de pertencimento: celulas x estimandos, com os pesos N
  rotulos <- "Total"
  M <- matrix(frame$N, ncol = 1)
  for (g in grupos) {
    niveis <- if (is.factor(frame[[g]])) levels(frame[[g]]) else sort(unique(frame[[g]]))
    for (nv in niveis) {
      M <- cbind(M, frame$N * (as.character(frame[[g]]) == nv))
      rotulos <- c(rotulos, paste0(g, ": ", nv))
    }
  }
  colnames(M) <- rotulos
  totais <- colSums(M)

  prever <- function(dados) {
    if (is.null(braco)) return(brms::posterior_epred(fit, newdata = dados,
                                                     draw_ids = ids,
                                                     allow_new_levels = TRUE))
    preds <- lapply(niveis_braco, function(b) {
      dados[[braco]] <- factor(b, levels = niveis_braco)
      brms::posterior_epred(fit, newdata = dados, draw_ids = ids, allow_new_levels = TRUE)
    })
    Reduce(`+`, preds) / length(preds)
  }

  acumulado <- NULL
  for (inicio in seq(1, nrow(frame), by = bloco)) {
    linhas <- inicio:min(inicio + bloco - 1, nrow(frame))
    ep <- prever(frame[linhas, ])
    parte <- if (length(dim(ep)) == 2) {
      ep %*% M[linhas, , drop = FALSE]
    } else {
      # categorico/ordinal: draws x celulas x categorias
      out <- sapply(seq_len(dim(ep)[3]), function(k) ep[, , k] %*% M[linhas, , drop = FALSE],
                    simplify = "array")
      dimnames(out)[[3]] <- dimnames(ep)[[3]]
      out
    }
    acumulado <- if (is.null(acumulado)) parte else acumulado + parte
  }
  if (length(dim(acumulado)) == 2) {
    res <- sweep(acumulado, 2, totais, "/")
  } else {
    res <- sweep(acumulado, 2, totais, "/")
    dimnames(res)[[2]] <- rotulos
  }
  res
}

# Resumo por estimando: mediana e intervalos de 90% e 95%
resumir_draws <- function(draws) {
  tibble::tibble(
    estimando = colnames(draws),
    mediana   = apply(draws, 2, stats::median),
    q05 = apply(draws, 2, stats::quantile, 0.05),
    q95 = apply(draws, 2, stats::quantile, 0.95),
    q025 = apply(draws, 2, stats::quantile, 0.025),
    q975 = apply(draws, 2, stats::quantile, 0.975)
  )
}
