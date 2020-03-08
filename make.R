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
    message(
      "Ignore and add to WORDLIST?"
    )
    choice <- menu(c("yes", "no"))
    
    if (choice == 1L) {
      dict <- sort(c(dict, x$word))
      writeLines(dict, "WORDLIST")
    } else {
      stop("Spelling errors found.")
    }
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
message(
  "Copy new file to Homepage?"
)
choice <- menu(c("yes", "no"))
if (choice == 1L) {
  copy_to_homepage()
}
