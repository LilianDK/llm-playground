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
