# 📊 Report Image Analyzer + Q&A

A complete system that allows users to upload report summary images (tables, numbers, text) and ask questions about the content. The system uses OCR (Optical Character Recognition) to read the image and answers based **only** on what is visible in the image.

## 🏗️ Project Structure

```
PPO/
├── backend/
│   ├── server.py         # FastAPI server with OCR endpoints
│   ├── requirements.txt  # Python dependencies
│   └── .env.example      # Environment configuration template
├── frontend/
│   └── index.html        # Single-file web interface
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Python 3.8+** installed
2. **Tesseract OCR** installed (see installation below)

### Step 1: Install Tesseract OCR

Tesseract is required for OCR functionality.

#### macOS
```bash
brew install tesseract
```

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install tesseract-ocr
```

#### Windows
1. Download installer from: https://github.com/UB-Mannheim/tesseract/wiki
2. Run the installer
3. Add Tesseract to your PATH (usually `C:\Program Files\Tesseract-OCR`)

**Verify installation:**
```bash
tesseract --version
```

### Step 2: Start the Backend

```bash
# Navigate to backend directory
cd backend

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn server:app --reload --port 8000
```

The backend will be running at: `http://localhost:8000`

### Step 3: Open the Frontend

Simply open `frontend/index.html` in your web browser:

```bash
# macOS
open frontend/index.html

# Linux
xdg-open frontend/index.html

# Windows
start frontend/index.html
```

Or navigate to the file in your browser directly.

## 📡 API Documentation

### Health Check
```bash
GET /health
```

**Response:**
```json
{"status": "ok"}
```

---

### Analyze Image
```bash
POST /analyze
Content-Type: multipart/form-data
```

**Parameters:**
- `file`: Image file (PNG, JPG, JPEG, max 10MB)

**Response:**
```json
{
    "extracted_text": "Sales Report 2024\nTotal Revenue: $1,500,000\n...",
    "structured_hints": {
        "num_words": 45,
        "lines": ["Sales Report 2024", "Total Revenue: $1,500,000", ...],
        "possible_tables": true,
        "numbers_found": ["2024", "1,500,000", ...],
        "labels_found": ["Sales Report", "Total Revenue", ...]
    },
    "success": true,
    "message": "Image analyzed successfully"
}
```

---

### Ask Question
```bash
POST /ask/json
Content-Type: application/json
```

**Body:**
```json
{
    "extracted_text": "Sales Report 2024\nTotal Revenue: $1,500,000",
    "question": "What is the total revenue?"
}
```

**Response:**
```json
{
    "answer": "$1,500,000",
    "success": true
}
```

If the information is not found:
```json
{
    "answer": "The image does not contain this information.",
    "success": true
}
```

---

### Ask with Image Upload
```bash
POST /ask
Content-Type: multipart/form-data
```

**Parameters:**
- `file`: Image file (optional if `extracted_text` is provided)
- `question`: Question to ask
- `extracted_text`: Text from previous /analyze call (optional if `file` is provided)

## 🧪 Sample curl Commands

### Health Check
```bash
curl http://localhost:8000/health
```

### Analyze an Image
```bash
curl -X POST http://localhost:8000/analyze \
  -F "file=@/path/to/your/report.png"
```

### Ask a Question (with extracted text)
```bash
curl -X POST http://localhost:8000/ask/json \
  -H "Content-Type: application/json" \
  -d '{
    "extracted_text": "Sales Report\nQ1: $500,000\nQ2: $750,000",
    "question": "What is Q2 sales?"
  }'
```

### Ask a Question (with image upload)
```bash
curl -X POST http://localhost:8000/ask \
  -F "file=@/path/to/your/report.png" \
  -F "question=What is the total amount?"
```

## 💻 Example Frontend Fetch Code

```javascript
// Step 1: Analyze an image
const formData = new FormData();
formData.append('file', fileInput.files[0]);

const analyzeResponse = await fetch('http://localhost:8000/analyze', {
    method: 'POST',
    body: formData
});
const analyzeData = await analyzeResponse.json();
console.log('Extracted text:', analyzeData.extracted_text);

// Step 2: Ask a question
const askResponse = await fetch('http://localhost:8000/ask/json', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        extracted_text: analyzeData.extracted_text,
        question: 'What is the total revenue?'
    })
});
const askData = await askResponse.json();
console.log('Answer:', askData.answer);
```

## ⚠️ Answer Rules

The system follows strict rules when answering questions:

1. ✅ Uses **only** the extracted image text as the source of truth
2. ❌ **Never** guesses or makes up information
3. 📝 Returns `"The image does not contain this information."` if the answer is not found
4. 🎯 Keeps answers short and precise (numbers, labels if present)

## 🛠️ Troubleshooting

### "Tesseract not found" Error

**Solution:** Make sure Tesseract is properly installed and in your PATH.

```bash
# Check if Tesseract is accessible
which tesseract  # macOS/Linux
where tesseract  # Windows
```

If installed but not found, set the path in `.env`:
```env
TESSERACT_CMD=/usr/local/bin/tesseract
```

### "pytesseract not installed" Error

**Solution:** Install the Python package:
```bash
pip install pytesseract
```

### CORS Errors in Browser

**Solution:** Make sure the backend is running on `http://localhost:8000`. The server has CORS enabled for all origins.

### Poor OCR Results

**Tips for better OCR:**
- Use high-resolution images (300 DPI or higher)
- Ensure good lighting and contrast
- Avoid skewed or rotated images
- Use clean, printed text (handwriting may not work well)

### File Upload Errors

- **File too large**: Maximum file size is 10MB
- **Invalid file type**: Only PNG, JPG, JPEG are accepted

## 📦 Dependencies

### Backend
- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `python-multipart` - File uploads
- `pytesseract` - OCR Python wrapper
- `Pillow` - Image processing
- `python-dotenv` - Environment variables

### Frontend
- Pure HTML/CSS/JavaScript (no build required)

## 📄 License

MIT License - feel free to use and modify.
