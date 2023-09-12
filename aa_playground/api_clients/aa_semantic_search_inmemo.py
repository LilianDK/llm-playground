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
