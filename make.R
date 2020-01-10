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
  rmarkdown::render("README.Rmd")
}
make_cv()

# make_cv(update_wordlist = TRUE)
copy_to_homepage <- function(md_loc = "../my-homepage/content/home/cv.md",
                             pdf_loc = "../my-homepage/static/cv/CV_JohannesGruber.pdf") {
  file.copy("./pdf_version/CV_JohannesGruber.pdf",
            pdf_loc,
            overwrite = TRUE)
  lines <- readLines(md_loc)
  
  lines <- gsub("last update: .*)", paste0("last update: ", 
                                          format(Sys.Date(), "%d %B %Y"),
                                          ")"),
                lines)
  writeLines(lines, md_loc)
}
copy_to_homepage()
