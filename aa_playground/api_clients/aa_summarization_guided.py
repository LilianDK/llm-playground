print("Loading aa_summarization_guided.py----------------------------------------------")
import os

from jinja2 import Template
from aleph_alpha_client import Client, CompletionRequest, Prompt

def summaryguided(token, document, question, maximum_tokens):
  with open(os.path.join("prompts/summarization_guided.j2")) as f:
      prompt = Template(f.read())
            
  prompt_text = prompt.render(question=question, document=document)
  
  print(prompt_text)
  client = Client(token)
  request = CompletionRequest(
      prompt=Prompt.from_text(prompt_text),
      maximum_tokens = maximum_tokens,
      temperature = 0,
      top_k = 0,
      top_p = 0,
      presence_penalty = 0,
      frequency_penalty = 0.5,
      repetition_penalties_include_prompt = False,
      repetition_penalties_include_completion = True,
  )
  response = client.complete(request, model = "luminous-supreme-control")
  print(response)
  return response.completions[0].completion
