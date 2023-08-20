<h3 align="center">LLM Playground Front-End</h3>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> In this project some basic front-ends are provivided that enable the webinterface based interaction with an LLM (APIs). Further, some pre-requisites are implemented on the interface design that allow for creating an abstraction layer against an account for an LLM such that multiple user can use the same account but without access to the account itself.
    <br> 
</p>

## 📝 Table of Contents
- [About](#about)
- [Getting Started](#getting_started)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [TODO](../TODO.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>
So far if you have an Aleph Alpha account for example and would like to share it in your organization with many people you would have to share the account credentials with everyone that would give too many rights to everyone. The playground however is only accessible through those extensive credentials. Therefore, this projects provides a front-end to create an abstraction and further provides some basic wrappers for LLM use cases.

## 🏁 Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites
What things you need to install the software and how to install them.
- [R](https://www.r-project.org/) - Web application
- [Python](https://www.python.org/) - API connector
- [Aleph Alpha](https://app.aleph-alpha.com/) - Account to get the token and budget (=loaded credits) on the accout

![alt text](https://github.com/LilianDK/llm-playground/blob/main/README_PICS/AA_Acount.png)

## 🎈 Usage <a name="usage"></a>
The front-end allows you to use the plain playground just like in the respective account to configure and try out prompt engineering. Further, there is also a functionality that allows you uploading a PDF file for which the selected page will be summarized. Finally, there is also a basic chat functionality to chat with the world knowledge of the llm.

https://github.com/LilianDK/llm-playground/assets/13328959/95576f84-5bc5-49b1-b9ef-175ede4287ce

You can find the summarization and chat prompt in the "prompts" folder.

Configuration of the summarization prompt:
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

Configuration of the summarization prompt:
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

## 🚀 Deployment <a name = "deployment"></a>
Will be added soon when docker container is done.

## ⛏️ Built Using <a name = "built_using"></a>
- [R Shiny](https://www.rstudio.com/products/shiny/) - Web application
- [Aleph Alpha](https://www.aleph-alpha.com/) - Foundation models
- [Jinja](https://jinja.palletsprojects.com/en/3.1.x/) - Prompts
- [Bootswatch](https://bootswatch.com/) - Cosmetics
- [Python](https://www.python.org/) - API connector

## ⛏️ TO DO <a name = "built_using"></a>
- Fix the summarization functionality (wrong page is retrieved)
- Improve the summarization prompt (so far just a bad prompt is embedded)
- Adding docker container
- Included other LLM API, maybe cohere
- Adding chatbot functionality
  
## ✍️ Authors <a name = "authors"></a>
- [@LilianDK](https://github.com/LilianDK/llm-playground) - Idea & Initial work
- [@mfmezger](https://github.com/mfmezger) - Supporting with the nasty Python stuff

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
- Bootswatch inspired me to make it at least a little beautiful
