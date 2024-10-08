# Load necessary libraries
library(dplyr)      
library(tibble)    
library(readtext)
library(stringr)    
library(purrr) 

# Function to list all file paths from the specified folder
# Args:
#   folder_path: Directory path to the folder where the files are located
# Returns:
#   A tibble with a column 'file_path' containing paths of files in the folder
make_listing <- function(folder_path) {
  pattern <- file.path(folder_path, "*") # Look for all files
  listing <- Sys.glob(pattern) %>%
    as_tibble() %>%
    rename(file_path = value)  # Rename the column to 'file_path'
  return(listing)
}

# Function to detect the type from a file
# Args:
#   file_path: Path to the file
# Returns:
#   A character string representing the file's type ('ohdl', 'mcadl', 'not dl', or 'other type')
get_file_type <- function(file_path) {
  
  # Check if the file is a .doc or .docx
  if (grepl(".doc$", file_path) || grepl(".docx$", file_path)) {
    
    # Read the file content
    content <- readtext(file_path) %>%
      select(text) %>%
      first()  # Extract the text content
    
    # Check for 'OHDL' type based on file title and first subheading
    if (grepl('Oral Hearing Decision Letter', content) &&
        grepl('[\r\n]+ *.{0,10}Introduction|INTRODUCTION', content)) {
      file_type <- 'ohdl'
      
      # Check for 'MCADL' type based on specific decision outcomes
    } else if (grepl('DECISION: Immediate release', content) || 
               grepl('DECISION: Recommend open conditions (ratified by the Chairman of the Parole Board)', content) || 
               grepl('DECISION: No recommendation for open', content) || 
               grepl('DECISION: No direction for release', content) || 
               grepl('DECISION: Release at a future date', content) || 
               grepl('DECISION: Recommend open conditions', content) || 
               grepl('DECISION: No recommendation for open conditions', content)) {
      file_type <- 'mcadl'
      
      # If none of the conditions match, classify as 'not dl'
    } else {
      file_type <- 'not dl'
    }
    
  } else {
    file_type <- 'other type'  # If the file isn't .doc or .docx, classify as 'other type' (pdf)
  }
  
  return(file_type)  # Return the file's type
}

# Safe version of the get_file_type function that handles errors gracefully
# Args:
#   file_path: Path to the file
# Returns:
#   The result of get_file_type or "error" if an error occurs when reading the file's content
get_file_type_safe <- function(file_path) {
  tryCatch({
    get_file_type(file_path)  # Try running file_type function
  }, error = function(e) {
    return("error")  # If an error occurs, return "error"
  })
}

# Function to add the file type to the listing tibble
# Args:
#   listing: A tibble of file paths
# Returns:
#   The listing tibble with an added 'file_type' column indicating the file's type
add_file_type <- function(listing) {
  listing %>%
    mutate(file_type = Vectorize(get_file_type_safe)(file_path))  # Apply file_type_safe to each file_path
}

# Function to copy relevant files based on their type (OHDL or MCADL)
# Args:
#   folder_path: Directory path to the folder where the files are located
#   out_path_OHDL: Directory path to store 'OHDL' files
#   out_path_MCADL: Directory path to store 'MCADL' files
run_file_classification <- function(folder_path, folder_path_mcadl, folder_path_ohdl) {
  
  # Create listing of files and discern their type
  listing <- make_listing(folder_path) %>%
    add_file_type()
  
  # Filter for MCADL and OHDL files
  relevant_mcadl <- listing %>%
    filter(file_type == 'mcadl')
  
  relevant_ohdl <- listing %>%
    filter(file_type == 'ohdl')
  
  # Copy relevant MCADL files to the output directory
  invisible(file.copy(relevant_mcadl$file_path, folder_path_mcadl))
  
  # Copy relevant OHDL files to the output directory
  invisible(file.copy(relevant_ohdl$file_path, folder_path_ohdl))
  
  return(listing)
}

# Copy relevant letters to the appropriate directories
run_file_classification(
  'data/original_data/', 
  'data/primary_data/letters/original_dls/mcadl/',
  'data/primary_data/letters/original_dls/ohdl/'
)



