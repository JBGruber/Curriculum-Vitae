# run with: Rscript make.R
make_cv <- function(update_wordlist = FALSE, clean = TRUE) {

  x <- spelling::spell_check_files(
    path = "CV_JohannesGruber.Rnw",
    ignore = readLines("DICTIONARY"),
    lang = "en-GB"
  )

  #Add words to dictionary
  if (update_wordlist) {
    x <- spelling::spell_check_files(
      path = "CV_JohannesGruber.Rnw",
      lang = "en-GB"
    )
    writeLines(x$word, "DICTIONARY")
  }

  if (nrow(x) > 0) {
    print(x)
    stop("Not all misspellings resolved.")
  }
  if (clean) {
    unlink(c("pdf_version", "png_version"), recursive = TRUE)
  }

  dir.create("pdf_version")
  knitr::knit("CV_JohannesGruber.Rnw")
  tinytex::xelatex("CV_JohannesGruber.tex")
  file.rename("CV_JohannesGruber.pdf",
              "pdf_version/CV_JohannesGruber.pdf")
  knitr::knit("README.Rmd")
}
make_cv()

