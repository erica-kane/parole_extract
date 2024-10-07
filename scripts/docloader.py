import re
import random
import textract
from pathlib import Path
from spacy.tokens import DocBin

# Define the DocLoader class
class DocLoader:
    def __init__(self, nlp, letters_path, cache_path):
        self.letters_path = Path(letters_path)
        self.cache_path = Path(cache_path)
        self.nlp = nlp

    # Method to return all document paths (ending in .doc or .docx)
    def all_letter_paths_pseudon(self):
        return self.letters_path.glob("*.doc*")

    def all_letter_paths_extract(self):
        return self.letters_path.glob("*.txt*")

    # Method to return a random sample of paths from the document folder
    def sample_paths(self, sample_n):
        path_list = list(self.all_letter_paths())
        return random.sample(path_list, sample_n)
    
    # Method to load a document, using a cached .spacy file if available, or processing from raw text
    def load_pseudon(self, letter_path):
        # Path to cache (where preprocessed .spacy files are stored)
        doc_bin_path = (self.cache_path / letter_path.name).with_suffix(".spacy")
        if doc_bin_path.exists():
            # Load from cache if available
            doc_bin = DocBin().from_disk(doc_bin_path)
            docs = list(doc_bin.get_docs(self.nlp.vocab))
            return docs[0]
        else:
            # If not cached, extract and process text
            text = textract.process(letter_path).decode("utf-8")
            no_tab = re.sub('\t', '', text)
            no_apos = re.sub('’', '\'', no_tab)
            
            # Use the NLP model to process the document
            doc = self.nlp(no_apos)

            # Save processed document to cache for faster loading next time
            doc_bin = DocBin(docs=[doc])
            doc_bin.to_disk(doc_bin_path)

            return doc

    def load_extract(self, letter_path):
        # Path to cache (where preprocessed .spacy files are stored)
        doc_bin_path = (self.cache_path / letter_path.name).with_suffix(".spacy")
        if doc_bin_path.exists():
            # Load from cache if available
            doc_bin = DocBin().from_disk(doc_bin_path)
            docs = list(doc_bin.get_docs(self.nlp.vocab))
            return docs[0]
        else:
            # If not cached, extract and process text
            letter_text = open((self.letters_path / letter_path.name), 'r', encoding = 'utf-8', errors='ignore')
            letter_content = letter_text.read()

            # Use the NLP model to process the document
            doc = self.nlp(letter_content)
            letter_text.close()

            # Save processed document to cache for faster loading next time
            doc_bin = DocBin(docs=[doc])
            doc_bin.to_disk(doc_bin_path)

            return doc

    # Method to load a document using its letter ID
    def open_letter(self, letter_id):
        return self.load(self.letters_path / letter_id)