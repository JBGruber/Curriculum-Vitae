# run with: Rscript make.R
x <- spelling::spell_check_files(
  path = "CV_JohannesGruber.Rnw",
  ignore = readLines("DICTIONARY"),
  lang = "en-GB"
)

# Add words to dictionary
# x <- spelling::spell_check_files(
#   path = "CV_JohannesGruber.Rnw",
#   lang = "en-GB"
# )
# writeLines(x$word, "DICTIONARY")

if (nrow(x) > 0) {
  stop("Not all misspellings resolved.")
}

knitr::knit("CV_JohannesGruber.Rnw")
tinytex::xelatex("CV_JohannesGruber.tex")
