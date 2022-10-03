# run with: Rscript make.R
make_cv <- function(file = "CV_JohannesGruber.Rnw", clean = TRUE) {
  
  x <- spelling::spell_check_files(
    path = file,
    ignore = readLines("DICTIONARY"),
    lang = "en-GB"
  )

  if (nrow(x) > 0) {
    #Add words to dictionary
    message(
      "The following spelling errors were found."
    )
    
    print(x)
    if (interactive()) {
      message(
        "Ignore and add to WORDLIST?"
      )
      choice <- menu(c("yes", "no"))
    } else {
      choice <- 0
    }
    
    if (choice == 1L) {
      dict <- sort(c(readLines("DICTIONARY"), x$word))
      writeLines(dict, "DICTIONARY")
    } else {
      stop("Spelling errors found.")
    }
  }
  
  if (clean) {
    unlink(c("pdf_version", "png_version"), recursive = TRUE)
  }

  dir.create("pdf_version")
  knitr::knit(file)
  
  check <- try(tinytex::latexmk(
    paste0(tools::file_path_sans_ext(file), ".tex"),
    engine = "xelatex",
    emulation = FALSE,
    clean = TRUE,
    install_packages = FALSE
  ))
  missing <- character(1L)
  
  while (class(check) == "try-error" && length(missing) > 0) {
    check <- try(tinytex::latexmk(
      paste0(tools::file_path_sans_ext(file), ".tex"),
      engine = "xelatex",
      emulation = FALSE,
      clean = FALSE,
      install_packages = FALSE
    ))
    missing <- tinytex::parse_packages(paste0(tools::file_path_sans_ext(file), ".log"))
    tinytex::tlmgr_install(
      missing
    )
  }
  
  file.remove(list.files(".", ".aux$|.bbl$"))
  file.rename("CV_JohannesGruber.pdf",
              "pdf_version/CV_JohannesGruber.pdf")
  rmarkdown::render("README.Rmd")
}
make_cv()

