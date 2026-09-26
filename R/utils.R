# =============================================================================
# utils.R
# Formatacao de numeros no texto: virgula decimal e ponto de milhar.
# =============================================================================

# Numero com d casas decimais e sinal de menos tipografico (como no gt);
# evita "-0,0"
num <- function(x, d = 1) {
  x <- ifelse(abs(x) < 0.5 * 10^-d, 0, x)
  sub("^-", "\u2212", formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ","))
}

# Inteiro com ponto de milhar
inteiro <- function(x) formatC(round(x), format = "d", big.mark = ".")

# Proporcao como porcentagem
pct <- function(x, d = 1) {
  scales::percent(x, accuracy = 10^-d, big.mark = ".", decimal.mark = ",",
                  style_negative = "minus")
}

# Rotulos de eixo no mesmo padrao
rotulo_pct <- scales::label_percent(big.mark = ".", decimal.mark = ",", style_negative = "minus")
rotulo_num <- scales::label_number(big.mark = ".", decimal.mark = ",", style_negative = "minus")
