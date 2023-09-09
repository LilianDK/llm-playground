<h3 align="center">LLM Playground Front-End</h3>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 
  [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)]() 

</div>

---

<p align="center"> In this project some basic front-ends are provivided that enable the webinterface based interaction with an LLM (APIs). Further, some pre-requisites are implemented on the interface design that allow for creating an abstraction layer against an account for an LLM such that multiple user can use the same account but without access to the account itself.
    <br> 
</p>

## 📝 Table of Contents
* [About](#about)
* [Getting Started](#getting_started)
* [Deployment](#deployment)
* [Usage](#usage)
  * [Configuration of prompt input files](#configprompt)
  * [Configuration of front-end color scheme input files](#configcolor)
* [TODO](#todo)
* [Licensing Overview](#licensingoverview)
* [Authors](#authors)
* [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>
So far if you have an Aleph Alpha account for example and would like to share it in your organization with many people you would have to share the account credentials with everyone that would give too many rights to everyone. The playground however is only accessible through those extensive credentials. Therefore, this projects provides a front-end to create an abstraction and further provides some basic wrappers for LLM use cases.

## 🏁 Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites
What things you need to run the software:
- [Docker](https://www.docker.com/) 

![alt text](https://github.com/LilianDK/llm-playground/blob/main/README_PICS/AA_Acount.png)

With reticulate there might be some tidious issues and at the end of the day we figured it is best to set use_python() in library.R. Please configure yours under "USERNAME" (or more):
```
# Required if local development environment has to be set due to reticulate having issues to find the right path
local_development = FALSE

packages <- c("shiny","bslib","reticulate","TheOpenAIR","glue",
              "DT","pdftools","knitr","rmarkdown","thematic","remotes")

installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
#remotes::install_github("dreamRs/shinyWidgets")

library(shiny)
library(shinyWidgets)
library(bslib)
library(thematic)
library(reticulate)
library(TheOpenAIR)
library(glue)
library(DT)
library(pdftools)
library(rmarkdown)

if (local_development) {
  
  # Put the path to your python environment here
  use_python("/Users/USERNAME/.pyenv/versions/3.11.4/bin/python")
}

py_install("aleph-alpha-client")
py_install("Jinja2")
```

## 🎈 Usage <a name="usage"></a>
The front-end allows you to use the plain playground just like in the respective account to configure and try out prompt engineering. Further, there is also a functionality that allows you uploading a PDF file for which the selected page will be summarized. Finally, there is also a basic chat functionality to chat with the world knowledge of the llm.

https://github.com/LilianDK/llm-playground/assets/13328959/95576f84-5bc5-49b1-b9ef-175ede4287ce

## Configuration of prompt input files <a name="configprompt"></a>
You can find the summarization and chat prompt in the "prompts" folder.

Configuration of the summarization prompt:

**token**: Identification and authorization to access Aleph Alpha API. <br />
**document**: Input document that shall be summarized. <br />
*This summarization is a very simple one and is intended for rather short text input summarizations (e.g. 1 A4 page). It is not suited for long text input summarizations.* <br />
```
import os

from jinja2 import Template
from aleph_alpha_client import Client, CompletionRequest, Prompt

def summary(token, document):
  with open(os.path.join("prompts/summarization.j2")) as f:
      prompt = Template(f.read())
            
  prompt_text = prompt.render(document=document)
  
  print(prompt_text)
  client = Client(token)
  request = CompletionRequest(
      prompt=Prompt.from_text(prompt_text),
      maximum_tokens = 260,
      best_of = 2,
      temperature = 0,
      top_k = 0,
      top_p = 0,
      presence_penalty = 0,
      frequency_penalty = 0,
  )
  response = client.complete(request, model = "luminous-extended-control")
  print(response)
  return response.completions[0].completion
```

Configuration of the chat prompt:

**token**: Identification and authorization to access Aleph Alpha API. <br />
**request**: Input question in natural language. <br />
*This chat prompt is a very simple one and intended to be used to chat with the world knowledge of the foundation model.*
```
import os

from jinja2 import Template
from aleph_alpha_client import Client, CompletionRequest, Prompt

def chat(token, request):
  with open(os.path.join("prompts/chat.j2")) as f:
      prompt = Template(f.read())
            
  prompt_text = prompt.render(chatmessage=request)
  
  print(prompt_text)
  client = Client(token)
  request = CompletionRequest(
      prompt=Prompt.from_text(prompt_text),
      maximum_tokens = 124,
      temperature = 0,
  )
  response = client.complete(request, model = "luminous-extended-control")
  print(response)
  return response.completions[0].completion
```

Configuration of the embedding function:

**token**: Identification and authorization to access Aleph Alpha API. <br />
**text_chunks**: Input document has been split into text chunks (e.g. per page or per paragraph etc.). <br />
**query**: Input question in natural language. <br />
**n**: Top n text_chunks output that are most similar according to cosine similarity. <br />
*This embedding function is configured for one way information retrieval and not for chatting, which would be bi-directional.*
```
import os
import numpy as np
import rpy2.robjects as robjects

from aleph_alpha_client import Client

from typing import Sequence
from aleph_alpha_client import Prompt, SemanticEmbeddingRequest, SemanticRepresentation
import math

# helper function to embed text using the symmetric or asymmetric model
def embed(client, text: str, representation: SemanticRepresentation):
    request = SemanticEmbeddingRequest(prompt=Prompt.from_text(text), representation=representation)
    result = client.semantic_embed(request, model="luminous-base")
    return result.embedding

# helper function to calculate the cosine similarity between two vectors
def cosine_similarity(v1: Sequence[float], v2: Sequence[float]) -> float:
    "compute cosine similarity of v1 to v2: (v1 dot v2)/{||v1||*||v2||)"
    sumxx, sumxy, sumyy = 0, 0, 0
    for i in range(len(v1)):
        x = v1[i]; y = v2[i]
        sumxx += x*x
        sumyy += y*y
        sumxy += x*y
    return sumxy/math.sqrt(sumxx*sumyy)

# helper function to print the similarity between the query and text embeddings
def print_result(texts, query, query_embedding, text_embeddings):
    for i, text in enumerate(texts):
        print(f"Similarity between '{query}' and '{text[:25]}...': {cosine_similarity(query_embedding, text_embeddings[i])}")

def semanticsearch(token, text_chunks, query, n):
    client = Client(token)

    asymmetric_query = embed(client, query, SemanticRepresentation.Query)
    asymmetric_embeddings = [embed(client, text, SemanticRepresentation.Document) for text in text_chunks]

    # Search for the most similar split in large_text to the query and output its index
    results = [cosine_similarity(asymmetric_query, embedding) for embedding in asymmetric_embeddings]
    
    results = np.array(results)
    
    sorted_results = np.argsort(results)
    
    top_n = sorted_results[-n:]
    
    top_n = top_n[::-1]
    
    top_index = np.argmax([cosine_similarity(asymmetric_query, embedding) for embedding in asymmetric_embeddings])
    
    
    print(f"The most similar split to the query is at index {top_index}:\n {text_chunks[top_index]}")
    print(type(top_n))

    return top_n
```

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

## 🚀 Deployment <a name = "deployment"></a>
Will be added soon when docker container is done. Meanwhile:
- Have the pre-requisites installed
- Get the reticulate working
- Run "app.R"

## ⛏️ TO DO <a name = "todo"></a>
- Improve the summarization prompt (so far just a bad prompt is embedded)
- Included other LLM API, maybe cohere
- Adding chatbot functionality
- ShinyProxy
- Prompt Catalogue
- Calculations everywhere
- Database for token tracking
- https://github.com/momper14/alephAlphaClient

## ⛏️ Licensing Overview <a name = "licensingoverview"></a>

| Name    | Version | Licence |
| -------- | ------- | ------- |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [R](https://www.r-project.org/)     | 4.3.1 | GPL-2/GPL-3 |
| <img src="https://rstudio.github.io/renv/logo.svg" width="25"> [renv](https://rstudio.github.io/renv/articles/renv.html)     | 1.0.2 | MIT |
| <img src="https://glue.tidyverse.org/logo.png" width="25"> [Glue](https://glue.tidyverse.org/)     | 1.6.2 | MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [DT](https://cran.r-project.org/web/packages/DT/index.html)     | 0.29 | GPL-3 |
| <img src="https://docs.ropensci.org/pdftools/logo.png" width="25"> [pdftools](https://docs.ropensci.org/pdftools/)     | 3.3.3 | MIT |
| <img src="https://rpy2.github.io/images/rpy2_logo2013.png" width="25"> [rpy2](https://pypi.org/project/rpy2/) | 3.5.14 | GPLv2+ |
| <img src="https://rstudio.github.io/thematic/reference/figures/logo.png" width="25"> [thematic](https://rstudio.github.io/thematic/index.html)     | 0.1.3 | MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [Rmarkdown](https://rmarkdown.rstudio.com/github_document_format.html)     | 3.3.3 | GPL-3 |
| <img src="https://raw.githubusercontent.com/rstudio/shiny/main/man/figures/logo.png" width="25"> [Shiny](https://github.com/rstudio/shiny/tree/main)     | 2.24 | GPL-3 |
| <img src="https://avatars.githubusercontent.com/u/23062899?s=48&v=4" width="25"> [ShinyWidgets](https://dreamrs.github.io/shinyWidgets/) | 0.8.0 | GPL-3 |
| <img src="https://camo.githubusercontent.com/51da0973891f15de1404fe9e17951136a420dafec4f9bbfa883e6283623c9317/68747470733a2f2f626f6f747377617463682e636f6d2f5f6173736574732f696d672f6c6f676f2d6461726b2e737667" width="25"> [Bootswatch](https://github.com/thomaspark/bootswatch) | N/A | MIT |
| <img src="https://www.r-project.org/Rlogo.png" width="25"> [bslib](https://rstudio.github.io/bslib/) | 0.5.1 | MIT |
| <img src="https://openair-lib.org/logo.png" width="25"> [TheOpenAIR](https://openair-lib.org/) | 0.1.0 | MIT |
| <img src="https://rstudio.github.io/reticulate/reference/figures/reticulated_python.png" width="25"> [Reticulate](https://rstudio.github.io/reticulate/) | 1.31 | Apache-2.0 |
| <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/1869px-Python-logo-notext.svg.png" width="25"> [Python](https://www.python.org/) | 3.11 | PSF-2 |
| <img src="https://avatars.githubusercontent.com/u/61506608?s=48&v=4" width="25"> [Aleph Alpha Client](https://github.com/Aleph-Alpha/aleph-alpha-client) | 3.4.1 | MIT |
| <img src="https://pypi.org/static/images/logo-small.2a411bc6.svg" width="25"> [Jinja2](https://pypi.org/project/Jinja2/) | 3.1.2 | BSD License (BSD-3-Clause) |
| <img src="https://numpy.org/doc/stable/_static/numpylogo.svg" width="25"> [NumPy](https://numpy.org/doc/stable/index.html) | 1.25 | NumPy licence |
| <img src="https://avatars.githubusercontent.com/u/5429470?s=200&v=4" width="25"> [Docker](https://github.com/docker) | 23.0.3 | Apache-2.0 |
| <img src="https://raw.githubusercontent.com/docker/compose/main/logo.png" width="25"> [Docker Compose](https://github.com/docker/compose) | 2.21.0 | Apache-2.0 |


## ✍️ Authors <a name = "authors"></a>
- [@LilianDK](https://github.com/LilianDK/llm-playground) - Idea & Initial work
- [@mfmezger](https://github.com/mfmezger) - Supporting with the nasty Python stuff

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
- Bootswatch inspired me to make it at least a little beautiful
