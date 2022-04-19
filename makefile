compile:
	Rscript -e "if (!require('littler', quietly = TRUE)) install.packages('littler')"; r -i "make.R" 
