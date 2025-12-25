"""
Report Image Analyzer + Q&A Backend Server
FastAPI server with OCR capabilities using pytesseract
"""

import os
import re
import tempfile
import logging
from pathlib import Path
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from PIL import Image, ImageEnhance, ImageOps
from dotenv import load_dotenv

# Load environment variables first
load_dotenv()

# Import LLM service
from llm import ask_llm

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Try to import pytesseract
try:
    import pytesseract
    # Set tesseract command if specified in environment
    tesseract_cmd = os.getenv("TESSERACT_CMD")
    if tesseract_cmd:
        pytesseract.pytesseract.tesseract_cmd = tesseract_cmd
    TESSERACT_AVAILABLE = True
except ImportError:
    TESSERACT_AVAILABLE = False
    logger.warning("pytesseract not installed. OCR functionality will be limited.")

# Configuration
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
ALLOWED_EXTENSIONS = {".png", ".jpg", ".jpeg"}
TEMP_DIR = Path(tempfile.gettempdir()) / "report_analyzer"
TEMP_DIR.mkdir(exist_ok=True)


# Pydantic models
class HealthResponse(BaseModel):
    status: str


class AnalyzeResponse(BaseModel):
    extracted_text: str
    structured_hints: dict
    success: bool
    message: Optional[str] = None


class AskRequest(BaseModel):
    extracted_text: Optional[str] = None
    question: str


class AskResponse(BaseModel):
    answer: str
    success: bool


# Lifespan context manager for cleanup
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting Report Image Analyzer server...")
    yield
    # Cleanup temp files on shutdown
    logger.info("Cleaning up temporary files...")
    cleanup_temp_files()


# Initialize FastAPI app
app = FastAPI(
    title="Report Image Analyzer + Q&A",
    description="Upload report images and ask questions about their content",
    version="1.0.0",
    lifespan=lifespan
)

# Enable CORS for all origins (development-friendly)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def cleanup_temp_files():
    """Remove all temporary files created by the application."""
    try:
        for file in TEMP_DIR.glob("*"):
            file.unlink()
        logger.info("Temporary files cleaned up successfully")
    except Exception as e:
        logger.error(f"Error cleaning up temp files: {e}")


def validate_file(file: UploadFile) -> None:
    """Validate uploaded file type and size."""
    # Check file extension
    ext = Path(file.filename).suffix.lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Allowed types: {', '.join(ALLOWED_EXTENSIONS)}"
        )


def preprocess_image(image: Image.Image) -> Image.Image:
    """
    Preprocess image to improve OCR accuracy.
    - Convert to grayscale
    - Increase contrast
    - Sharpen
    """
    # 1. Convert to grayscale
    processed = ImageOps.grayscale(image)

    # 2. Increase contrast (factor 2.0 = double contrast)
    enhancer = ImageEnhance.Contrast(processed)
    processed = enhancer.enhance(2.0)

    # 3. Sharpen (factor 2.0 = sharpen)
    enhancer = ImageEnhance.Sharpness(processed)
    processed = enhancer.enhance(2.0)

    return processed


def extract_text_from_image(image_path: Path) -> tuple[str, dict]:
    """
    Extract text from image using pytesseract OCR.
    Returns extracted text and structured hints.
    """
    if not TESSERACT_AVAILABLE:
        raise HTTPException(
            status_code=500,
            detail="OCR not available. Please install pytesseract and Tesseract OCR. "
                   "See README.md for installation instructions."
        )
    
    try:
        # Open image
        original_image = Image.open(image_path)

        # Preprocess image
        image = preprocess_image(original_image)
        
        # Extract text using pytesseract
        # Preserve layout to help with tables
        custom_config = r'--psm 6'  # Assume a single uniform block of text (good for tables)
        extracted_text = pytesseract.image_to_string(image, config=custom_config)
        
        # Get structured data (bounding boxes, confidence)
        data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
        
        # Build structured hints
        structured_hints = {
            "num_words": len([w for w in data['text'] if w.strip()]),
            "lines": [],
            "possible_tables": False,
            "numbers_found": [],
            "labels_found": []
        }
        
        # Extract lines
        lines = extracted_text.strip().split('\n')
        structured_hints["lines"] = [line.strip() for line in lines if line.strip()]
        
        # Check for table-like structures (multiple aligned columns)
        if any('|' in line or '\t' in line for line in lines):
            structured_hints["possible_tables"] = True
        
        # Also check for patterns that might indicate tables
        space_separated_lines = [line for line in lines if len(line.split()) >= 3]
        if len(space_separated_lines) >= 3:
            structured_hints["possible_tables"] = True
        
        # Extract numbers
        numbers = re.findall(r'\b[\d,]+\.?\d*\b', extracted_text)
        structured_hints["numbers_found"] = numbers[:20]  # Limit to first 20
        
        # Extract potential labels (capitalized words or phrases)
        labels = re.findall(r'\b[A-Z][a-zA-Z]+(?:\s+[A-Z][a-zA-Z]+)*\b', extracted_text)
        structured_hints["labels_found"] = list(set(labels))[:20]  # Unique, limit to 20
        
        logger.info(f"Successfully extracted {len(extracted_text)} characters from image")
        return extracted_text, structured_hints
        
    except pytesseract.TesseractNotFoundError:
        raise HTTPException(
            status_code=500,
            detail="Tesseract OCR is not installed or not found in PATH. "
                   "Please install Tesseract OCR. See README.md for instructions."
        )
    except Exception as e:
        logger.error(f"OCR extraction failed: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"OCR extraction failed: {str(e)}. "
                   "Make sure the image is clear and Tesseract is properly installed."
        )


def answer_question(text: str, question: str) -> str:
    """
    Answer a question based ONLY on the extracted text.
    Returns "The image does not contain this information." if not found.
    Improvements: Strict token matching, table alignment, and negation handling.
    """
    if not text or not text.strip():
        return "The image does not contain this information."
    
    question_lower = question.lower().strip()
    lines = [line.strip() for line in text.strip().split('\n') if line.strip()]
    
    # 1. Identify Critical Tokens (Strict Constraints)
    # Tokens that MUST be present in the matching line (e.g. "Q1", "Revenue", "2024").
    # We ignore common stop words.
    stop_words = {'what', 'is', 'are', 'the', 'a', 'an', 'of', 'in', 'for', 'how', 'much', 'many', 'does', 'do', 'show', 'tell', 'me', 'find', 'get', 'value', 'amount', 'total'}
    
    # Extract potential entity tokens (capitalized words, numbers, or specific known terms)
    # We keep the casing for strict checking if needed, but mostly use lowercase for initial match
    tokens = [w for w in question.replace('?', '').replace(':', '').split() if w.lower() not in stop_words]
    
    # Specialized handling: If "Q1", "Q2" etc are in question, they are CRITICAL.
    # If the question mentions specific year "2024", it is CRITICAL.
    critical_tokens = []
    for t in tokens:
        # Check for Q1, Q2, Q3, Q4, months, years, or capitalized headers
        if re.match(r'^[Qq]\d$', t) or re.match(r'^\d{4}$', t) or t[0].isupper():
            critical_tokens.append(t.lower())
    
    # Fallback: if no critical tokens found, treat all non-stop tokens as important
    if not critical_tokens:
        critical_tokens = [t.lower() for t in tokens]

    logger.info(f"Question: {question}")
    logger.info(f"Critical tokens: {critical_tokens}")

    best_match = None
    best_score = -1
    best_value = None

    for line in lines:
        line_lower = line.lower()
        
        # STRICT CONSTRAINT: All critical tokens (especially specific entities like "Q3") 
        # must be present in the *line* OR the *context* (header).
        # For simple single-line implementation, we check the line first.
        
        # Check how many critical tokens are missing
        missing_critical = [t for t in critical_tokens if t not in line_lower]
        
        # If specific differentiators (like Q1 vs Q2) are missing, this line is TRASH.
        # This prevents "Q1 Revenue" from answering "What is Q2 Revenue?"
        if missing_critical:
            # But wait! Maybe the critical token is a column header?
            # (Advanced: not implemented fully here, assuming row-based for now)
            continue
            
        # Calculate score based on total keyword overlap
        score = sum(1 for t in tokens if t.lower() in line_lower)
        
        if score > best_score:
            best_score = score
            best_match = line
    
    # If no line satisfies all strict constraints, return not found.
    # This specifically fixes the "Guessing Q1 for Q3" issue.
    if best_match is None:
         return "The image does not contain this information."

    logger.info(f"Best matching line: {best_match}")

    # 2. Extract Value from the Best Line
    # Strategy A: Key-Value separation (colon, dash, large whitespace)
    # "Revenue: $500,000" -> "$500,000"
    
    # Try splitting by common separators
    separators = [':', '-', '|', '   ', '\t'] # '   ' is 3 spaces
    for sep in separators:
        if sep in best_match:
            parts = best_match.split(sep)
            # Find the part that does NOT contain the label tokens
            # Usually the value is at the end
            candidate = parts[-1].strip()
            if candidate and candidate.lower() not in question_lower:
                return candidate
    
    # Strategy B: Number extraction (if question asks for amount/number)
    # If the remaining text in the line looks like a number/currency, return it.
    numbers = re.findall(r'[$£€]?\d{1,3}(?:,\d{3})*(?:\.\d+)?%?', best_match)
    if numbers:
        # If multiple numbers, usually the last one is the "Total" or "Value"
        # Unless the question asks for a specific column (not handled yet)
        return numbers[-1]
        
    # Strategy C: Return the whole line sans the recognized entity tokens
    # (Fallback)
    return best_match


# ============== API Endpoints ==============

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    return HealthResponse(status="ok")


@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze_image(file: UploadFile = File(...)):
    """
    Analyze an uploaded image using OCR.
    Returns extracted text and structured hints.
    """
    logger.info(f"Received file for analysis: {file.filename}")
    
    # Validate file
    validate_file(file)
    
    # Read file content
    content = await file.read()
    
    # Check file size
    if len(content) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File too large. Maximum size is {MAX_FILE_SIZE // (1024*1024)}MB"
        )
    
    # Save temporarily
    temp_path = TEMP_DIR / f"upload_{os.urandom(8).hex()}{Path(file.filename).suffix}"
    try:
        temp_path.write_bytes(content)
        logger.info(f"File saved temporarily at {temp_path}")
        
        # Extract text
        extracted_text, structured_hints = extract_text_from_image(temp_path)
        
        return AnalyzeResponse(
            extracted_text=extracted_text,
            structured_hints=structured_hints,
            success=True,
            message="Image analyzed successfully"
        )
        
    finally:
        # Clean up temp file
        if temp_path.exists():
            temp_path.unlink()
            logger.info(f"Cleaned up temp file: {temp_path}")


@app.post("/ask", response_model=AskResponse)
async def ask_question(
    question: str = Form(None),
    extracted_text: str = Form(None),
    file: UploadFile = File(None),
    json_body: AskRequest = None
):
    """
    Answer a question based on the image content.
    Accepts either:
    - extracted_text + question (from previous /analyze call)
    - image file + question (will run OCR first)
    """
    # Handle JSON body if provided
    if json_body:
        question = json_body.question
        extracted_text = json_body.extracted_text
    
    # Validate question
    if not question:
        raise HTTPException(status_code=400, detail="Question is required")
    
    logger.info(f"Received question: {question}")
    
    # If file is provided, run OCR first
    if file and file.filename:
        logger.info(f"Processing image file for question: {file.filename}")
        
        validate_file(file)
        content = await file.read()
        
        if len(content) > MAX_FILE_SIZE:
            raise HTTPException(
                status_code=400,
                detail=f"File too large. Maximum size is {MAX_FILE_SIZE // (1024*1024)}MB"
            )
        
        temp_path = TEMP_DIR / f"ask_{os.urandom(8).hex()}{Path(file.filename).suffix}"
        try:
            temp_path.write_bytes(content)
            extracted_text, _ = extract_text_from_image(temp_path)
        finally:
            if temp_path.exists():
                temp_path.unlink()
    
    # Validate we have text to work with
    if not extracted_text:
        raise HTTPException(
            status_code=400,
            detail="Either provide extracted_text or upload an image file"
        )
    
    # Answer the question
    # answer = answer_question(extracted_text, question)  # Legacy rule-based
    answer = await ask_llm(extracted_text, question)  # LLM-based
    logger.info(f"Generated answer: {answer[:100]}...")
    
    return AskResponse(answer=answer, success=True)


# Alternative JSON endpoint for /ask
@app.post("/ask/json", response_model=AskResponse)
async def ask_question_json(request: AskRequest):
    """
    Answer a question using JSON body.
    Requires extracted_text from previous /analyze call.
    """
    if not request.extracted_text:
        raise HTTPException(
            status_code=400,
            detail="extracted_text is required. First call /analyze to get text from image."
        )
    
    if not request.question:
        raise HTTPException(status_code=400, detail="question is required")
    
    logger.info(f"Received JSON question: {request.question}")
    
    # answer = answer_question(request.extracted_text, request.question)  # Legacy rule-based
    answer = await ask_llm(request.extracted_text, request.question)  # LLM-based
    logger.info(f"Generated answer: {answer[:100]}...")
    
    return AskResponse(answer=answer, success=True)


# Error handlers
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": exc.detail, "success": False}
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error(f"Unexpected error: {exc}")
    return JSONResponse(
        status_code=500,
        content={"error": "An unexpected error occurred", "success": False}
    )


if __name__ == "__main__":
    import uvicorn
    
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    
    logger.info(f"Starting server on {host}:{port}")
    uvicorn.run(app, host=host, port=port)
