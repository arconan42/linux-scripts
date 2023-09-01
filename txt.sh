#!/bin/bash

# Define the filename and path to the Downloads folder
filename="new_file.txt"
download_folder="$HOME/Downloads"

# Create the full path to the file
filepath="$download_folder/$filename"

# Check if the file already exists
if [ -e "$filepath" ]; then
  echo "The file '$filename' already exists in the Downloads folder."
else
  # Create the text file in the Downloads folder
  touch "$filepath"
  echo "File '$filename' created in the Downloads folder."
fi
