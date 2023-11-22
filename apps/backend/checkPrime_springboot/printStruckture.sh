#!/bin/bash

# Display the directory structure
echo "Directory Structure:"
tree

# Find and print contents of .java, pom.xml, and .properties files
echo "File Contents:"
find . -type f \( -name "*.java" -o -name "pom.xml" -o -name "*.properties" \) -exec echo -e "\n==> {} <==" \; -exec cat {} \;
