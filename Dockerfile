FROM rocker/r-ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssh2-1-dev \
    libpoppler-cpp-dev \
    git \
    libavfilter-dev \
    libharfbuzz-dev libfribidi-dev\
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev \
    texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra \
    # pyenv
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# poppler utils for pdf tools
ENV _R_SHLIB_STRIP_ true

ENV RUNS_IN_CONTAINER TRUE

RUN install.r remotes renv

COPY Rprofile.site /etc/R

RUN chown 1000:1000 -R /usr/local/lib/R

WORKDIR /home/app

RUN chown 1000:1000 -R /home/app

USER 1000:1000

RUN R -e "renv::init()"

COPY --chown=1000:1000 aa_playground/renv.lock .

RUN R -e "renv::restore()"

COPY --chown=1000:1000 aa_playground /home/app

RUN Rscript library.R

# RUN
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/app', host='0.0.0.0', port=3838)"]