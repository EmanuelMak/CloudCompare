#!/bin/bash

# Function to print the directory structure
print_tree() {
    echo "Directory Structure:"
    tree "$1"
    echo ""
}

# Function to print the contents of YAML files
print_yaml_contents() {
    echo "YAML File Contents:"
    find "$1" -type f \( -name "*.yml" -o -name "*.yaml" \) -print0 | while IFS= read -r -d $'\0' file; do
        echo "==> $file <=="
        cat "$file"
        echo ""
    done
}

# Main directory to inspect (current directory by default, can be replaced with a specific path)
main_directory="."

print_tree "$main_directory"
print_yaml_contents "$main_directory"