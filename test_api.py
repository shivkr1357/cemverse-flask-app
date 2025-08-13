import requests
import json

def test_api():
    """Test the PDF to PPT conversion API"""
    
    # API endpoint
    url = "http://localhost:5000/convert"
    
    # Test PDF URL (you can replace this with any PDF URL)
    pdf_url = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
    
    # Request data
    data = {
        "pdf_url": pdf_url
    }
    
    try:
        print("Testing PDF to PPT conversion API...")
        print(f"PDF URL: {pdf_url}")
        
        # Make the request
        response = requests.post(url, json=data, timeout=60)
        
        if response.status_code == 200:
            # Save the PowerPoint file
            with open("test_presentation.pptx", "wb") as f:
                f.write(response.content)
            print("✅ Success! PowerPoint file saved as 'test_presentation.pptx'")
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")

if __name__ == "__main__":
    test_api() 