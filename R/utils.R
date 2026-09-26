# =============================================================================
# utils.R
# Formatacao de numeros no texto: virgula decimal e ponto de milhar.
# =============================================================================

# Numero com d casas decimais; evita "-0,0"
num <- function(x, d = 1) {
  x <- ifelse(abs(x) < 0.5 * 10^-d, 0, x)
  formatC(x, format = "f", digits = d, big.mark = ".", decimal.mark = ",")
}

# Inteiro com ponto de milhar
inteiro <- function(x) formatC(round(x), format = "d", big.mark = ".")

# Proporcao como porcentagem
pct <- function(x, d = 1) {
  scales::percent(x, accuracy = 10^-d, big.mark = ".", decimal.mark = ",")
}

# Rotulos de eixo no mesmo padrao
rotulo_pct <- scales::label_percent(big.mark = ".", decimal.mark = ",")
rotulo_num <- scales::label_number(big.mark = ".", decimal.mark = ",")
