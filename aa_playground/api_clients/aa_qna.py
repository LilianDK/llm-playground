print("Loading aa_qna.py--------------------------------------------------------")
import os

from jinja2 import Template
from aleph_alpha_client import Client, CompletionRequest, Prompt, ExplanationRequest

def qna(token, string, query):
  with open(os.path.join("prompts/qna.j2")) as f:
      prompt = Template(f.read())
            
  prompt_text = prompt.render(string=string, query=query)
  
  print(prompt_text)
  client = Client(token)
  request = CompletionRequest(
      prompt=Prompt.from_text(prompt_text),
      maximum_tokens = 64,
      best_of = 2,
      temperature = 0,
      top_k = 0,
      top_p = 0,
      presence_penalty = 0,
      frequency_penalty = 0.1,
      repetition_penalties_include_prompt = True,
      repetition_penalties_include_completion = True,
  )
  response = client.complete(request, model = "luminous-extended-control")
  print(response)
  
  answer = response.completions[0].completion
  
  # explanation task
  exp_req = ExplanationRequest(Prompt.from_text(prompt_text), answer , control_factor=0.1, prompt_granularity="word", normalize=True)
  response_explain = client.explain(exp_req, model="luminous-extended-control")

  explanations = response_explain[1][0].items[0][0]

  # if all of the scores are belo 0.9 raise an error
  if all(item.score < 0.9 for item in explanations):
      raise ValueError("All scores are below 0.9.")

  # pick the top explanation based on score
  top_explanation = max(explanations, key=lambda x: x.score)
  
  # get the start and end of the explanation
  start = top_explanation.start
  
  end = top_explanation.start + top_explanation.length
  
  # get the explanation from the prompt
  explanation = prompt_text[start:end]
  
  # get the score
  score = np.round(top_explanation.score, decimals=3)
  
  output = [explanation, score, string, answer]
  
  return output

  
