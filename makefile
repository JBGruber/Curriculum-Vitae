compile:
	Rscript -e "if (require("littler")) {install.packages("littler")}"; r -i "make.R" 
