"""
LLM Service Module using Google Gemini API.
Handles intelligent Q&A based on extracted text.
"""
import os
import logging
import google.generativeai as genai
from typing import Optional

logger = logging.getLogger(__name__)

def configure_genai():
    """Configure the Gemini API with the environment variable."""
    api_key = os.getenv("GOOGLE_API_KEY")
    if api_key:
        genai.configure(api_key=api_key)
        return True
    return False


def get_model():
    """Get the configured Gemini model."""
    if not configure_genai():
        return None

    # Use Gemini 1.5 Flash for speed and efficiency, or Pro for reasoning
    # Using 'gemini-1.5-flash' as it is fast and capable for this task
    # Note: 'gemini-1.5-flash' should be the standard.
    # If using an older library version or specific region, fallback to 'gemini-pro' might be needed.
    # However, 'gemini-1.5-flash' is the most up-to-date standard.
    return genai.GenerativeModel('gemini-1.5-flash')


def ask_llm(context_text: str, question: str) -> str:
    """
    Ask a question to the LLM based *only* on the provided context text.
    """
    if not context_text or not context_text.strip():
        return "The image does not contain sufficient text information."

    if not configure_genai():
        logger.info("Running in MOCK MODE (No API Key)")
        return "[MOCK ANSWER] This is a placeholder answer because GOOGLE_API_KEY is not set. " \
               "The system would normally use Gemini to answer: " + question

    try:
        model = get_model()

        # System instructions to enforce strict boundaries
        prompt = f"""
You are a helpful assistant that answers questions based STRICTLY on the provided text extracted from an image (OCR).
Your goal is to be accurate and concise.

CONTEXT (OCR TEXT):
\"\"\"
{context_text}
\"\"\"

QUESTION:
{question}

INSTRUCTIONS:
1. Answer the question using ONLY the information in the CONTEXT above.
2. Do NOT use outside knowledge or guess.
3. If the answer is not in the text, say "The image does not contain this information."
4. If the text contains tables, interpret the rows and columns correctly to answer questions about specific cells, totals, or comparisons.
5. If the user asks for a specific value (e.g., "Revenue for 2024"), extract the exact number/text.
6. Provide direct answers. No fluff.

ANSWER:
"""
        response = model.generate_content(prompt)
        return response.text.strip()

    except Exception as e:
        logger.error(f"LLM generation failed: {e}")
        return "Sorry, I encountered an error while processing your request with the AI model."
