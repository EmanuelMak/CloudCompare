#!/bin/bash

# Function to print the directory structure, excluding .terraform directories
print_tree() {
    echo "Directory Structure:"
    tree -I 'node_modules' "$1"
    echo ""
}

# Function to print the contents of YAML, Makefiles, and .tf files, excluding .terraform directories and specific terraform files
print_file_contents() {
    echo "File Contents (YAML, Makefiles, .tf):"
    find "$1" -type f \( -name "*.ts" -o -name "*.sh" -o -name "*.js" -o -name "Makefile" -o -name "Dockerfile" -o -name "*.json" \) -not -path '*/node_modules/*' -not -name 'terraform.tfvars' -not -name 'package-lock.json' -print0 | while IFS= read -r -d $'\0' file; do
        echo "==> $file <=="
        cat "$file"
        echo ""
    done
}

# Main directory to inspect (current directory by default, can be replaced with a specific path)
main_directory="."

print_tree "$main_directory"
print_file_contents "$main_directory"
