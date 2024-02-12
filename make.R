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

update_downloads <- function(file = "CV_JohannesGruber.bib",
                             packages = c("askgpt",
                                          "atrrr",
                                          "rwhatsapp", 
                                          "LexisNexisTools",
                                          "cookiemonster",
                                          "rollama",
                                          "spacyr",
                                          "quanteda.textmodels")) {
  
  if (file.exists(".last_updated")) 
    if (readLines(".last_updated") >= Sys.Date())
      return(TRUE)    
  
  lines <- readLines(file)
  entry_start <- grep("@.+?\\{", lines)
  ends <- c(entry_start[2:length(entry_start)] - 1, length(lines))
  entries <- lapply(seq_along(entry_start), function(i) lines[entry_start[i]:ends[i]])
  
  for (i in seq_along(packages)) {
    if (interactive()) 
      message(packages[i])
    ds <- cranlogs::cran_downloads(packages[i], from = "2018-04-09", to = Sys.Date())$count |> 
      sum() |> 
      scales::comma()
    
    entry <- entries[[grep(packages[i], entries)]]
    entries[[grep(packages[i], entries)]] <- gsub("\\{Cranlogs download count: [0-9,]+\\}",
                                                  paste0("{Cranlogs download count: ", ds, "}"),
                                                  entry)
  }
  writeLines(as.character(Sys.Date()), ".last_updated")
  writeLines(unlist(entries), file)
  return(TRUE)    
}
update_downloads()
make_cv()

