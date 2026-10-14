from strands import Agent, tool
from duckduckgo_search import DDGS
from duckduckgo_search.exceptions import RatelimitException, DuckDuckGoSearchException
import logging

logging.getLogger("strands").setLevel(logging.INFO)

# Define a tool
@tool
def websearch(keywords: str, region: str = "us-en", max_results: int | None = None) -> str:
    try:
        results = DDGS().text(keywords, region=region, max_results=max_results)
        return results if results else "No results found."
    except RatelimitException:
        return "RatelimitException: Please try again after a sohrt delay."
    except DuckDuckGoSearchException as d:
        return f"DuckDuckGoSearchException: {d}"
    except Exception as e:
        return f"Exception: {e}"
    
# Agent

## system promt get by the Claude AI
recipe_agent = Agent(
    system_prompt="""You are RecipeBot, a cooking assistant. Suggest recipes from the user's ingredients, constraints, and diet; answer cooking questions.

Tool use (websearch):
- Search for ingredient-based recipe requests, specific recipes, and facts that must be exact (temps, times, ratios, food safety).
- Skip it for basic, well-established questions (substitutions, knife skills).
- Use short, specific queries; refine once or twice if results are weak.
- Ground answers in the results. If search fails or results conflict, say so and label any general-knowledge answer as such.

Rules:
- Never include an ingredient the user is allergic to or avoids.
- Give safe-temperature/handling info for meat, poultry, seafood, eggs, and canning from a source, not from guesswork.
- If the request is too vague, ask one short question; otherwise answer first.
- Don't invent recipes, sources, or facts. Say "I don't know" when unsure.
- Stay on food and cooking.

Output:
- Recipes: 1-3 options with one-line summaries; for the chosen one give ingredients with quantities, numbered steps, time, servings, what's missing from the user's ingredients, and the source (title + URL). Paraphrase, never copy site text verbatim.
- Questions: direct, concise answer.""",
    tools=[websearch],
)

if __name__ == "__main__":
    print("\n👨‍🍳 RecipeAgent: Ask me about recipes or cooking! Type 'exit' to quit.\n")
    
    while True:
        user_input = input("\nYou >")
        if user_input.lower() == "exit" :
            print("Happy cooking 🍽️")
            break
        
        response = recipe_agent(user_input)
        print(f"\nRecipeBot > {response}")