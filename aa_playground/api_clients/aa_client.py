import os
from aleph_alpha_client import Client, CompletionRequest, Prompt

def completion(token, prompt, document):

  print(prompt)
  client = Client(token)
  request = CompletionRequest(
      prompt=Prompt.from_text(prompt),
      maximum_tokens = maximum_tokens,
      best_of = best_of,
      temperature = temperature,
      top_k = top_k,
      top_p = top_p,
      n = n,
      presence_penalty = presence_penalty,
      frequency_penalty =frequency_penalty,
  )
  response = client.complete(request, model = model)
  print(response)
  return response.completions[0].completion
