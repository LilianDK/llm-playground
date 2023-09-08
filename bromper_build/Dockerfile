# Base image
FROM --platform=linux/amd64 r-base-tidyverse

## create directories
RUN mkdir -p /aa_playground

## copy files
COPY aa_playground .

## run the script
CMD Rscript ./app.R