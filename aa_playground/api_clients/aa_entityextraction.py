import os

from jinja2 import Template
from aleph_alpha_client import Client, CompletionRequest, Prompt

def entityextraction(token, document, namedentity1, namedentity2, namedentity3):
  with open(os.path.join("prompts/entityextraction.j2")) as f:
      prompt = Template(f.read())
            
  prompt_text = prompt.render(document=document, namedentity1=namedentity1, namedentity2=namedentity2, namedentity3=namedentity3)
  
  print(prompt_text)
  client = Client(token)
  request = CompletionRequest(
      prompt=Prompt.from_text(prompt_text),
      maximum_tokens = 124,
      best_of = 2,
      temperature = 0,
      top_k = 0,
      top_p = 0,
      presence_penalty = 0,
      frequency_penalty = 0.1,
      repetition_penalties_include_prompt = 0,
      repetition_penalties_include_completion = True,
  )
  response = client.complete(request, model = "luminous-base-control")
  print(response)
  return response.completions[0].completion
