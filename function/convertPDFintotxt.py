import fitz  

def pdf_to_txt(pdf_path, txt_path):
    # Open pdf file
    doc = fitz.open(pdf_path)

    with open(txt_path, "w", encoding="utf-8") as txt_file:
        # Walk through each page of the PDF
        for page in doc:
            text = page.get_text("text")  # Extract text
            if text.strip():  # Make sure the text is not empty
                txt_file.write(text + "\n\n")  # Writes text and adds a newline

    print(f"Conversion complete, saved to {txt_path}")

# example usage
pdf_to_txt("D:\your\file\path", "D:\your\file\path\output.txt")
