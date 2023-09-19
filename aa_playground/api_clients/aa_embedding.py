print("Loading aa_semantic_search_inmemo.py-------------------------------------")
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

def embedding(token, text_chunks):
    client = Client(token)

    asymmetric_embeddings = [embed(client, text, SemanticRepresentation.Document) for text in text_chunks]

    return asymmetric_embeddings
