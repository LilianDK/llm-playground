FROM rocker/r-ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \ 
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libpoppler-cpp-dev \
    git \ 
    && rm -rf /var/lib/apt/lists/*

# poppler utils for pdf tools
COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

RUN install.r remotes renv

RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app

COPY ./renv.lock .
RUN Rscript -e "options(renv.consent = TRUE);renv::restore(lockfile = '/home/app/renv.lock', repos = c(CRAN='https://packagemanager.rstudio.com/all/__linux__/jammy/latest'))"
RUN rm -f renv.lock

COPY aa_playground app

# RUN 
RUN chown app:app -R /home/app
USER app
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/app/app')"]