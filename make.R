# run with: Rscript make.R
make_cv <- function(clean = TRUE) {

  x <- spelling::spell_check_files(
    path = "CV_JohannesGruber.Rnw",
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
  knitr::knit("CV_JohannesGruber.Rnw")
  tinytex::latexmk("CV_JohannesGruber.tex", engine = "xelatex", emulation = FALSE, clean = TRUE)
  file.remove(list.files(".", ".aux$|.bbl$"))
  file.rename("CV_JohannesGruber.pdf",
              "pdf_version/CV_JohannesGruber.pdf")
  rmarkdown::render("README.Rmd")
}
make_cv()

copy_to_homepage <- function(md_loc = "../my-homepage/content/home/cv.md",
                             pdf_loc = "../my-homepage/content/cv/CV_JohannesGruber.pdf") {
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

if (dir.exists("../my-homepage/")) {
  copy_to_homepage()
}
