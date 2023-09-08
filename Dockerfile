FROM rocker/r-ubuntu:20.04

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
    && rm -rf /var/lib/apt/lists/*

# poppler utils for pdf tools
COPY Rprofile.site /etc/R
ENV _R_SHLIB_STRIP_=true

RUN install.r remotes renv

RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app

COPY ./renv.lock .
RUN Rscript -e "options(renv.consent = TRUE);renv::restore(lockfile = '/home/app/renv.lock', repos = c(CRAN='https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"
RUN rm -f renv.lock

COPY aa_playground app

# RUN apt-get update -y \
#     && apt-get upgrade -y \
#     && apt-get -y install build-essential \
#         zlib1g-dev \
#         libncurses5-dev \
#         libgdbm-dev \ 
#         libnss3-dev \
#         libssl-dev \
#         libreadline-dev \
#         libffi-dev \
#         libsqlite3-dev \
#         libbz2-dev \
#         wget \
#     && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get purge -y imagemagick imagemagick-6-common 

# RUN cd /usr/src \
#     && wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz \
#     && tar -xzf Python-3.11.0.tgz \
#     && cd Python-3.11.0 \
#     && ./configure --enable-optimizations \
#     && make altinstall

# RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3.11 1

RUN wget https://cdn.rstudio.com/python/ubuntu-2004/pkgs/python-3.11.3_1_amd64.deb

RUN apt-get update && apt-get install -y gdebi-core libpython3-dev
RUN gdebi python-3.11.3_1_amd64.deb
# RUN chown app:app -R /home/app
# USER app
# RUN python -m venv newenv
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/app/app')"]
#CMD ["tail", "-f", "/dev/null"]