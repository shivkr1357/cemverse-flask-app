# PDF to PPT Conversion API

A simple Flask API that converts PDF files to PowerPoint presentations.

## Features

- Convert PDF files to PowerPoint (.pptx) format
- Support for both file uploads and URL-based conversion
- Extract text content from PDF pages
- Create structured PowerPoint presentations with bullet points
- RESTful API interface
- Web-based upload form

## Installation

1. Make sure Python 3.11+ is installed
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

## Usage

### Start the API Server

```bash
python app.py
```

The API will start on `http://localhost:5000`

### Web Interface

Visit `http://localhost:5000/upload` to use the web-based upload form.

### API Endpoints

#### 1. Health Check
```
GET /health
```

#### 2. Convert PDF File to PPT (Recommended)
```
POST /convert
Content-Type: multipart/form-data
```

**Request Body:**
- `pdf_file`: PDF file to upload (max 16MB)

**Response:** PowerPoint file (.pptx)

#### 3. Convert PDF from URL (Legacy)
```
POST /convert-url
Content-Type: application/json
```

**Request Body:**
```json
{
    "pdf_url": "https://example.com/sample.pdf"
}
```

**Response:** PowerPoint file (.pptx)

#### 4. Web Upload Form
```
GET /upload
```

**Response:** HTML form for file upload

### Example Usage

#### Using curl for file upload:
```bash
curl -X POST http://localhost:5000/convert \
  -F "pdf_file=@/path/to/your/file.pdf" \
  --output presentation.pptx
```

#### Using curl for URL conversion:
```bash
curl -X POST http://localhost:5000/convert-url \
  -H "Content-Type: application/json" \
  -d '{"pdf_url": "https://example.com/sample.pdf"}' \
  --output presentation.pptx
```

#### Using Python for file upload:
```python
import requests

url = "http://localhost:5000/convert"
files = {"pdf_file": open("document.pdf", "rb")}

response = requests.post(url, files=files)
with open("presentation.pptx", "wb") as f:
    f.write(response.content)
```

#### Using Python for URL conversion:
```python
import requests

url = "http://localhost:5000/convert-url"
data = {"pdf_url": "https://example.com/sample.pdf"}

response = requests.post(url, json=data)
with open("presentation.pptx", "wb") as f:
    f.write(response.content)
```

#### Test the API:
```bash
python test_api.py
```

## How it Works

1. **File Upload**: Upload a PDF file directly to the API
2. **URL Download**: Download PDF from the provided URL
3. **Extract Text**: Extracts text content from each page of the PDF
4. **Create PowerPoint**: Generates a PowerPoint presentation with:
   - Title slide
   - Content slides (one per PDF page)
   - Bullet points from the extracted text

## Requirements

- Python 3.11+
- Flask
- requests
- python-pptx
- PyPDF2
- Pillow

## File Requirements

- **Format**: PDF only
- **Maximum Size**: 16MB
- **Content**: Text-based PDFs work best

## Notes

- The API works best with text-based PDFs
- Images and complex formatting may not be preserved
- Large PDFs may take longer to process
- Maximum timeout is 30 seconds for PDF download
- File upload is the recommended method for better reliability 