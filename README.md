<h3 align="center">LLM Playground Front-End</h3>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 
  [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)]() 
  [![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000)]() 

</div>

---

<p align="center"> In this project some basic front-ends are provivided that enable the webinterface based interaction with an LLM (APIs). Further, some pre-requisites are implemented on the interface design that allow for creating an abstraction layer against an account for an LLM such that multiple user can use the same account but without access to the account itself.
    <br> 
</p>

## 📝 Table of Contents
* [About](#about)
* [Showcases](#usage)
  * [Use case 1: Aleph Alpha Playground Dupe](#aaplayground)
  * [Use case 2: Summarization](#summarization)
  * [Use case 3: Question and answering](#qna)
  * [Use case 4: Document processing](#dp)
* [Getting Started](#getting_started)
* [Deployment or usage](#deployment0)
  * [Deployment using a docker image](#deployment1)
  * [Deployment building a docker image](#deployment2)
  * [Deployment using R Studio](#deployment3)
* [Configuration](#configuration)
  * [Configuration of front-end color scheme input files](#configcolor)
  * [Configuration of port (coming soon)](#configport)
  * [Configuration of sites (coming soon)](#configsites)
* [TODO](#todo)
  * [Issues](#issues)
  * [Features](#features)
  * [Non-functionals](#nfrs)
* [Licensing Overview](#licensingoverview)
* [Authors](#authors)
* [Acknowledgments](#acknowledgement)
* [Notes](#notes)

## 🧐 About <a name = "about"></a>
So far if you have an Aleph Alpha account for example and would like to share it in your organization with many people you would have to share the account credentials with everyone that would give too many rights to everyone. The playground however is only accessible through those extensive credentials. Therefore, this projects provides a front-end to create an abstraction and further provides some basic wrappers for LLM use cases.

## 🎈 Showcases <a name="usage"></a>
The front-end allows you to use the plain playground just like in the respective account to configure and try out prompt engineering. Further, there is also a functionality that allows you uploading a PDF file for which the selected page will be summarized. Finally, there is also a basic chat functionality to chat with the world knowledge of the llm.

https://github.com/LilianDK/llm-playground/assets/13328959/95576f84-5bc5-49b1-b9ef-175ede4287ce

## Use case 1: Aleph Alpha Playground Dupe <a name="aaplayground"></a>
The first use case is the dupe version of the [Aleph Alpha Playround](https://app.aleph-alpha.com/). So far if you have an Aleph Alpha account for example and would like to share it in your organization with many people you would have to share the account credentials with everyone that would give too many rights to everyone. The playground however is only accessible through those extensive credentials. Therefore, this projects provides a front-end to create an abstraction. 

Configuration of the chat prompt:

*This chat prompt is a very simple one and intended to be used to chat with the world knowledge of the foundation model.*
```
### Instruction: You are a chatbot and you answer questions.
### Input:{{chatmessage}}
### Response:
```

## Use case 2: Summarization <a name="summarization"></a>
The second use case show cases a simple summary of input text. Only the selected page is summarized. 

You can find the summarization and chat prompt in the "prompts" folder.

Configuration of the summarization prompt:

*This summarization is a very simple one and is intended for rather short text input summarizations (e.g. 1 A4 page). It is not suited for long text input summarizations.* <br />
```
### Instruction: Summarize the input.
### Input:{{document}}
### Response:
```

## Use case 3: Question and Answering <a name="qna"></a>
The third use case show cases question and answering (with natural language generation) in which a given input document can be queried. The output is the display of the most suitable n text chunks and a machine generated answer in natural language.

Configuration of the embedding function:

```
### Instruction: Answer the given question by the provided document. 
### Input: {{string}}
### Response: {{query}} Der Sachverhalt ist wir folgt:
```

## Use case 4: Document processing <a name="dp"></a>
The forth use case show cases document processing in which a given input document can be queried for specific entities. 

```
### Instruction: Please extract relevant information from OCR-read document ("{{namedentity1}}","{{namedentity2}}","{{namedentity3}}").
If several values are present format them as a list.
If value cannot be extracted use "values":"NotAvail".
### Input: {{document}}
### Output: 
```

## Configuration <a name="configuration"></a>
## Configuration of front-end color scheme input files <a name="configcolor"></a>
For changing the color scheme on the front-end two files need to be touched that are located in the "www" folder.

style.R in lines 3 and 4 to change the sidebar background color and text color:
```
# Color configuration beside CSS elements; mix colors here = https://cssgradient.io/
config_button = "color: #fff; background-color: #06498c; border-color: #06498c"
config_primary = "#06498c"
config_sidebar_text_color = "#fff"
```

style.css in line 135 to change the background color of the main interaction field:
```
body {
background: linear-gradient(90deg, rgba(6,73,140,1) 28%, rgba(21,146,227,1) 63%, rgba(0,224,255,1) 100%);
}
```

## 🏁 Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites
What things you need to run the software:
- [Install Docker in your environment](https://docs.docker.com/engine/install/) or [Rancher](https://www.rancher.com/)
- Aleph Alpha Account or Token (see image description below)
![alt text](https://github.com/LilianDK/llm-playground/blob/main/README_PICS/AA_Acount.png)

## 🚀 Deployment or usage of the application <a name = "deployment0"></a>
## Deployment using a Docker Image <a name = "deployment1"></a>

In the following we describe how you can deploy this application with a Docker image.

| Pros     | Cons    | 
| -------- | ------- |
| Time efficient set-up | No visual configuration possible |
| No messing around with the console | No other configuration of inputs possible |

**Step 0: Open your console**

**Step 1: Download the Docker image (=application)**
```
docker pull schiggy89/llm-playground:latest
```

**Step 2: Start the downloaded Docker image (=application)** 
```
docker run -p 3838:3838 --rm schiggy89/llm-playground:latest
```
This step might take a while until it startet.


**Step 3: Start a browser and enter "localhost:3838" to open the application** 

**Step 4: Enter your token on the left. You do not need a USER ID (because this is for other enterprise purposes).** 

## Deployment building a Docker Image <a name = "deployment2"></a>

In the following we describe how you can deploy this application by building your own a Docker image and with some configurations of the inputs.

| Pros     | Cons    | 
| -------- | ------- |
| Visual configuration possible  | No Time efficient set-up |
| Other configuration of inputs possible | Messing around with the console |

**Step 0: Open your console and cd to the filepath where you want to save the application**

**Step 1: Download the repository (=application)**
```
git clone https://github.com/LilianDK/llm-playground.git
```

**Step 2: Configurate what ever you need to and build the docker image**

For norma docker image builds:
```
docker build -t YOURTAG/PROJECTNAME:latest --push .
```
For multiarch build, that is for diverse operating systems, you need to run following instruction if it is your first time:
```
docker buildx create --name multiarch --driver docker-container --use
```
Then for all builds afterwards and only:
```
docker buildx build --no-cache --platform=linux/amd64,linux/arm64 -t YOURTAG/PROJECTNAME:latest --push .
```
(approx. more than 5 minutes)
```
docker pull YOURTAG/PROJECTNAME:latest
docker run -p 3838:3838 --rm YOURTAG/PROJECTNAME:latest
```

**Step 3: Start the downloaded Docker image (=application)** 
```
docker run -p 3838:3838 --rm schiggy89/llm-playground:latest
```
This step might take a while until it startet.


**Step 3: Start a browser and enter "localhost:3838" to open the application** 
```
docker run -p 3838:3838 --rm schiggy89/llm-playground:latest
```

Optional if you want to share you image like in the first deployment option:
```
docker push YOURTAG/PROJECTNAME
```

**Step 4: Enter your token on the left. You do not need a USER ID (because this is for other enterprise purposes).** 

## Deployment using R Studio <a name = "deployment3"></a>
In the following we describe how you can "deploy" this application through R Studio.

| Pros     | Cons    | 
| -------- | ------- |
| Visual configuration possible  | No Time efficient set-up |
| Other configuration of inputs possible | Messing around with the console |

**Step 0: Open your console and cd to the filepath where you want to save the application**

**Step 1: Download the repository (=application)**
```
git clone https://github.com/LilianDK/llm-playground.git
```

**Step 2: Open the aa_playground.Rproj**

**Step 3: Run app.R**

**Step 4: Enter your token on the left. You do not need a USER ID (because this is for other enterprise purposes).** 
  
## ⛏️ TO DO <a name = "todo"></a>
## Issues <a name = "issues"></a>
- Download prompt report multi-file
  
## Features <a name = "features"></a>
- Database for token tracking
- https://github.com/momper14/alephAlphaClient
- Audio recording
- Hate blocker
- Improve the summarization prompt (rejected to be integrated in new application for large text corpus summarization)
- Included other LLM API, maybe cohere
- Adding chatbot functionality
- https://github.com/daattali/shinyscreenshot/
- Test framework for document processing
  
## Non-functionals <a name = "nfrs"></a>
- ShinyProxy
- Tests
- Prompt Catalogue
- Websocket (for the audio transcription display on the front-end)

## ⛏️ Licensing Overview <a name = "licensingoverview"></a>

| Name    | Version | Licence |
| -------- | ------- | ------- |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [R](https://www.r-project.org/)     | 4.3.1 | GPL-2/GPL-3 |
| <img src="https://avatars.githubusercontent.com/u/274806?s=48&v=4" width="25"> [shinyproxy](https://github.com/openanalytics/shinyproxy)     | 3.0.2 | Apache-2.0 (scheduled for integration) |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [Aleph Alpha Client](https://github.com/momper14/alephAlphaClientl)     | None | None (scheduled for integration) |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [audio](https://search.r-project.org/CRAN/refmans/audio/html/record.html)  | 0.1.11 | MIT (scheduled for integration) |
| <img src="https://github.com/bnosac/audio.whisper/blob/master/tools/logo-audio-whisper-x100.png" width="25"> [OpenAI Whisper](https://github.com/bnosac/audio.whisper)     | 0.2.1-1 | MIT |
| <img src="https://rstudio.github.io/renv/logo.svg" width="25"> [renv](https://rstudio.github.io/renv/articles/renv.html)     | 1.0.2 | MIT |
| <img src="https://glue.tidyverse.org/logo.png" width="25"> [Glue](https://glue.tidyverse.org/)     | 1.6.2 | MIT |
| <img src="https://stringr.tidyverse.org/logo.png" width="25"> [Stringr](https://stringr.tidyverse.org/reference/str_detect.html)     | 1.5.0 | MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [gridlayout](https://rstudio.github.io/gridlayout/)     | 0.2.1| MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [DT](https://cran.r-project.org/web/packages/DT/index.html)     | 0.29 | GPL-3 |
| <img src="https://docs.ropensci.org/pdftools/logo.png" width="25"> [pdftools](https://docs.ropensci.org/pdftools/)     | 3.3.3 | MIT |
| <img src="https://rpy2.github.io/images/rpy2_logo2013.png" width="25"> [rpy2](https://pypi.org/project/rpy2/) | 3.5.14 | GPLv2+ |
| <img src="https://rstudio.github.io/thematic/reference/figures/logo.png" width="25"> [thematic](https://rstudio.github.io/thematic/index.html)     | 0.1.3 | MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [Rmarkdown](https://rmarkdown.rstudio.com/github_document_format.html)     | 3.3.3 | GPL-3 |
| <img src="https://pypi.org/static/images/logo-small.2a411bc6.svg" width="25"> [markdown](https://pypi.org/project/Markdown/)     | 3.4.4 | BSD License |
| <img src="https://raw.githubusercontent.com/rstudio/shiny/main/man/figures/logo.png" width="25"> [Shiny](https://github.com/rstudio/shiny/tree/main)     | 2.24 | GPL-3 |
| <img src="https://avatars.githubusercontent.com/u/23062899?s=48&v=4" width="25"> [ShinyWidgets](https://dreamrs.github.io/shinyWidgets/) | 0.8.0 | GPL-3 |
| <img src="https://camo.githubusercontent.com/51da0973891f15de1404fe9e17951136a420dafec4f9bbfa883e6283623c9317/68747470733a2f2f626f6f747377617463682e636f6d2f5f6173736574732f696d672f6c6f676f2d6461726b2e737667" width="25"> [Bootswatch](https://github.com/thomaspark/bootswatch) | 5.3.1 | MIT |
| <img src="https://raw.githubusercontent.com/rstudio/shiny/main/man/figures/logo.png" width="25"> [shinycssloaders](https://cran.r-project.org/web/packages/shinycssloaders/index.html)     | 1.0.0 | MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [bslib](https://rstudio.github.io/bslib/) | 0.5.1 | MIT |
| <img src="https://openair-lib.org/logo.png" width="25"> [TheOpenAIR](https://openair-lib.org/) | 0.1.0 | MIT |
| <img src="https://rstudio.github.io/reticulate/reference/figures/reticulated_python.png" width="25"> [Reticulate](https://rstudio.github.io/reticulate/) | 1.31 | Apache-2.0 |
| <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/1869px-Python-logo-notext.svg.png" width="25"> [Python](https://www.python.org/) | 3.11 | PSF-2 |
| <img src="https://avatars.githubusercontent.com/u/61506608?s=48&v=4" width="25"> [Aleph Alpha Client](https://github.com/Aleph-Alpha/aleph-alpha-client) | 3.4.1 | MIT |
| <img src="https://avatars.githubusercontent.com/u/54850923?s=48&v=4" width="25"> [Cohere Client](https://github.com/cohere-ai/cohere-python) | None | MIT  (scheduled for integration) |
| <img src="https://pypi.org/static/images/logo-small.2a411bc6.svg" width="25"> [Jinja2](https://pypi.org/project/Jinja2/) | 3.1.2 | BSD License (BSD-3-Clause) |
| <img src="https://numpy.org/doc/stable/_static/numpylogo.svg" width="25"> [NumPy](https://numpy.org/doc/stable/index.html) | 1.25 | NumPy licence |
| <img src="https://avatars.githubusercontent.com/u/5429470?s=200&v=4" width="25"> [Docker](https://github.com/docker) | 23.0.3 | Apache-2.0 |
| <img src="https://raw.githubusercontent.com/docker/compose/main/logo.png" width="25"> [Docker Compose](https://github.com/docker/compose) | 2.21.0 | Apache-2.0 |

| Name    | Version | Licence |
| -------- | ------- | ------- |
| <img src="https://rstudio.github.io/reactlog/reference/figures/logo.svg" width="25"> [reactlog](https://rstudio.github.io/reactlog/)     | 1.1.1 | GPL-3 |


## ✍️ Authors <a name = "authors"></a>
- [@LilianDK](https://github.com/LilianDK/llm-playground) - Idea & Initial work
- [@mfmezger](https://github.com/mfmezger) - Supporting with the nasty Python and Docker stuff
- [@momper14](https://github.com/momper14) - Supporting with the Docker compilation stuff and writing of the Aleph Alpha Client in R

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
- Bootswatch inspired me to make it at least a little beautiful

## 🎉 Notes <a name = "notes"></a>
- renv::snapshot(type = all)
