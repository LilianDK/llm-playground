## Maximum Tokens

The maximum number of tokens to be generated. Completion will terminate after the maximum number of tokens is reached.Increase this value to generate longer texts. A text is split into tokens. Usually there are more tokens than words.The sum of input tokens and maximum_tokens may not exceed 2048.

## Best of

best_of number of completions are created on server side. The completion with the highest log probability per token is returned. If the parameter n is larger 1 more than 1(n) completions will be returned.

## Temperature

A higher sampling temperature encourages the model to produce less probable outputs (be more creative). Values are expected in a range from 0.0 to 1.0. Try high values (e.g., 0.9) for a more creative response and the default 0.0 for a well defined and repeatable answer. It is advised to use either temperature, top_k, or top_p, but not all three at the same time. If a combination of temperature, top_k or top_p is used, rescaling of logits with temperature will be performed first. Then top_k is applied. Top_p follows last.

## Top K

Introduces random sampling for generated tokens by randomly selecting the next token from the k most likely options. A value larger than 1 encourages the model to be more creative. Set to 0 if repeatable output is to be produced. It is recommended to use either temperature, top_k or top_p and not all at the same time. If a combination of temperature, top_k or top_p is used rescaling of logits with temperature will be performed first. Then top_k is applied. Top_p follows last.

## Top P

Introduces random sampling for generated tokens by randomly selecting the next token from the smallest possible set of tokens whose cumulative probability exceeds the probability top_p. Set to 0.0 if repeatable output is to be produced.

## Frequency Penalty

The frequency penalty reduces the likelihood of generating tokens that are already present in the text. Frequency penalty is dependent on the number of occurences of a token. An operation of like the following is applied: logits[t] - logits[t] - count[t]*penalty where logits[t] is the logits for any given token and count[t] is the number of times that token appears in context_tokens.

## Presence Penalty

The frequency penalty reduces the likelihood of generating tokens that are already present in the text. Presence penalty is independent on the number of occurences of a token. Increase the value to produce text that is not repeating the input. An operation of like the following is applied: logits[t] - logits[t] - 1*penalty where logits[t] is the logits for any given token. Note that the formula is independent of the number of times that a token appears in context_tokens.
