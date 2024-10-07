# Turning text into data:<br><small>_Automatically extracting information from Parole Board decision letters._</small>


This repository contains the code developed for my PhD research, which focuses on extracting decision-relevant information from Parole Board final decision letters. These letters are unstructured Word documents written by Parole Board members after a panel has convened to decide on a prisoner's progression.

The decision letters result from two review processes: Member Case Assessments and Oral Hearings, each producing distinct document types that are utilised in this research.

The primary objective of this project is to process these unstructured data and generate a structured, tabular representation of the final decisions. The aim of this resulting data is to facilitate the analysis of the Parole Board decision-making process.

## Repository structure

### `data/`
- **primary_data**: Dummy examples of Parole Board decision letters in various formats.
- **supplementary_data**: Files that are used at different stages of the process to enhance the information extracted from the letters. 
- **linked_data**: Resulting files from the linkage process, which combine information from both the primary and supplementary data.
- **models**: The pre-trained models used throughout the processing stages. 
 
### `scripts/`

- **docloader.py**: Reads and caches text documents from a specified folder.
- **dl_classification.R**: Reads, classifies, and sorts files as decision letters.
- **pseudonymisation.ipynb**: Removes direct personal identifiers from decision letters.
- **segmentation.ipynb**: Reduces decision letters to relevant sections.
- **extraction.ipynb**: Extracts convicted crime entities from decision letters.
- **simplification.ipynb**: Classifies and reformats extracted crime entities.
- **linkage.ipynb**: Extracts unique identifiers from decision letters, joins them to extracted crime entities, and links to supplementary data.
- **preparation.ipynb**: Adds, reformats, and removes variables from linked data.

## Requirements

To run the scripts in this repository, you will need a series of R and Python libraries.  

📊 R libraries:  
- `dplyr`
- `purrr`
- `readtext`
- `stringr`
- `tibble`

🐍 Python libraries:
- `joblib`
- `numpy`
- `pandas`
- `pathlib`
- `random`
- `re`
- `sklearn`
- `spacy`
- `string`
- `textract`
  
The project also requires `antiword`, a tool for extracting text from Microsoft Word `.doc` files (a common file type of Parole Board decision letters).

## Usage

The scripts in this repository are intended to be executed sequentially, with each script building upon the outputs generated by the previous one. After each run, the output is saved in the relevant folder of the `data/` directory for inspection. This step-by-step process ensures transparency, which is crucial to the integrity of the project's methodology.

Each script's output is subsequently used as the input for the next stage of the pipeline, along with any required supplementary data or models.  

The pipeline follows this flow:

### ✉️ 1. Decision letter classification 

**Script**: `scripts/dl_classification.R`

**Input**: 
- `data/primary_data/letters/original_docs/`: Parole Board files (.doc, .docx, .pdf). 

**Output**: 
- `data/primary_data/letters/mcadl/original_dls/`: MCA decision letters (.doc, .docx).
- `data/primary_data/letters/ohdl/original_dls/`: OH decision letters (.doc, .docx).

### 🔒 2. Pseudonymisation 

**Script**: `scripts/pseudonymisation.ipynb`

**Input**: 
- `data/primary_data/letters/mcadl/original_dls/`: MCA decision letters (.doc, .docx).
- `data/primary_data/letters/ohdl/original_dls/`: OH decision letters (.doc, .docx).

**Output**: 
- `data/primary_data/letters/mcadl/pseudon_dls/`: pseudonymised MCA decision letters (.txt).
- `data/primary_data/letters/ohdl/pseudon_dls/`: pseudonymised OH decision letters (.txt).

### ✂️ 3. Segmentation

**Script**: `scripts/segmentation.ipynb`

**Input**: 
- `data/primary_data/letters/mcadl/pseudon_dls/`: pseudonymised MCA decision letters (.txt).
- `data/primary_data/letters/ohdl/pseudon_dls/`: pseudonymised OH decision letters (.txt).

**Output**: 
- `data/primary_data/letters/mcadl/segmented_dls/`: segmented pseudonymised MCA decision letters (.txt).
- `data/primary_data/letters/ohdl/segmented_dls/`: segmented pseudonymised OH decision letters (.txt).

### 🔍 4. Extraction 

**Script**: `scripts/extraction.ipynb`

**Input**: 
- `data/primary_data/letters/mcadl/segmented_dls/`: segmented pseudonymised MCA decision letters (.txt).
- `data/primary_data/letters/ohdl/segmented_dls/`: segmented pseudonymised OH decision letters (.txt).
- `data/models/ner/`: pre-trained convicted crime NER model.

**Output**: 
- `data/primary_data/extract/mcadl/extract_mcadl.xlsx/`: extracted convited crime entities from segmented pseudonymised MCA decision letters.
- `data/primary_data/extract/ohdl/extract_ohdl.xlsx/`: extracted convited crime entities from segmented pseudonymised OH decision letters.

### 🔁 5. Simplification 

**Script**: `scripts/simplification.ipynb`

**Input**: 
- `data/primary_data/extract/mcadl/extract_mcadl.xlsx/`: extracted convited crime entities from segmented pseudonymised MCA decision letters.
- `data/primary_data/extract/ohdl/extract_ohdl.xlsx/`: extracted convited crime entities from segmented pseudonymised OH decision letters.
- `data/models/offence_cat_model.pkl/`: pre-trained offence category classification model.
- `data/models/offence_type_model_mcadl.pkl/`: pre-trained mca offence type classification model.
- `data/models/offence_type_model_ohdl.pkl/`: pre-trained oh offence type classification model.

**Output**: 
- `data/primary_data/extract/mcadl/simplified_mcadl.xlsx/`: simplified MCA extracted convited crime entities.
- `data/primary_data/extract/ohdl/simplified_ohdl.xlsx/`: simplified OH extracted convited crime entities.

### 🔗 6. Linkage 

**Script**: `scripts/linkage.ipynb`

**Input**: 
- `data/primary_data/extract/mcadl/simplified_mcadl.xlsx/`: simplified MCA extracted convited crime entities.
- `data/primary_data/extract/ohdl/simplified_ohdl.xlsx/`: simplified OH extracted convited crime entities.
- `data/primary_data/letters/mcadl/segmented_dls/`: segmented pseudonymised MCA decision letters (.txt).
- `data/primary_data/letters/ohdl/segmented_dls/`: segmented pseudonymised OH decision letters (.txt).
- `data/supplementary_data/supp_data.xlsx/`: Parole Board administrative data.

**Output**: 
- `data/linked_data/mcadl/linked_mcadl.xlsx/`: MCA linked data.
- `data/linked_data/ohdl/linked_ohdl.xlsx/`: OH linked data. 

### 🛠️ 7. Preparation

**Script**: `scripts/preparation.ipynb`

**Input**: 
- `data/linked_data/mcadl/linked_mcadl.xlsx/`: MCA linked data.
- `data/linked_data/ohdl/linked_ohdl.xlsx/`: OH linked data. 
- `data/supplementary_data/severity_scores.xlsx/`: Offence category severity scores. 

**Output**: 
- `data/linked_data/mcadl/prepared_mcadl.xlsx/`: MCA prepared linked data.
- `data/linked_data/ohdl/prepared_ohdl.xlsx/`: OH prepared linked data. 

## Project

The scripts and data were created during a three-year PhD project. Due to the sensitive nature of the data, real data was stored in secure Virtual Research Environments, where the scripts were also developed. As a result, this repository contains only synthetic data, along with the original code and models used in the project.

The entire process is documented in a thesis, where specific sections correspond to each of the scripts:

Chapter 5.2: _Document caching_ - `docloader.py`  
Chapter 5.3: _Decision letter classification_ - `dl_classification.R`  
Chapter 5.4: _Pseudonymisation_ - `pseudonymisation.ipynb`  
Chapter 6.2: _Letter segmentation_ - `segmentation.ipynb`  
Chapter 6.3: _Extraction_ - `extraction.ipynb`  
Chapter 7.2-7.4: _Data simplification_ - `simplification.ipynb`  
Chapter 8.2: _Linkage_ - `linkage.ipynb`  
Chapter 8.3: _Sample preparation_ - `preparation.ipynb`  

For more detailed information on the development of each process and its performance during the testing stages, please refer to the [thesis document]().

## Citation

If you use the code from this repository in your work, please cite my PhD thesis:

**Kane, E.** (2025) _Turning text into data: Exploring the potential of natural language processing techniques in extracting information from Parole Board decision letters_. PhD Thesis. University of Leeds.

## Contact 

For questions, feel free to reach out via email: [erica.r.kane@gmail.com]().