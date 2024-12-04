#!/bin/bash

# Validate input arguments
if [ "$#" -ne 1 ]; then
  echo "Error: Requires exactly one parameter (GitHub Username)."
  echo "Usage: $0 <gitHub_username>"
  echo "Example: $0 johndoe"
  exit 1
fi

# GitHub username
GITHUB_USERNAME="$1"

# Type of origin URL (ssh or https)
NEW_ORIGIN_TYPE="ssh" # Set to "https" if you want HTTPS URLs

# List of repositories to clone (hardcoded in the script)
REPOS=(
  "https://github.com/Public-Repositories/book.git"
  "https://github.com/Public-Repositories/spaCy.git"
  "git@github.com:Public-Repositories/environs.git"
  "git@github.com:Public-Repositories/environsd.git"
)

# Base directory for cloning repositories
BASE_DIR=../
# Ensure base directory exists
mkdir -p "$BASE_DIR"

# Function to process each repository
process_repo() {
  local REPO_URL="$1"
  local REPO_NAME
  local NEW_ORIGIN_URL

  # Validate the repository URL
  if [[ ! "$1" =~ ^(https://github\.com/.+\.git|git@github\.com:.+\.git)$ ]]; then
    echo "Skipping invalid repository URL: $1"
    return
  fi

  # Extract the repository name
  REPO_NAME=$(basename "$1" .git)

# Check if the directory already exists
  if [ -d "$BASE_DIR/$REPO_NAME" ]; then
    echo "Warning: Directory already exists for $REPO_NAME. Skipping..."
    echo
    echo "---------------------------------------------------"
    echo
    return
  fi

  # Clone the repository
  echo "Cloning repository: $1 into $BASE_DIR/$REPO_NAME"
  git clone "$1" "$BASE_DIR/$REPO_NAME"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to clone repository: $1"
    return
  fi

  # Navigate to the cloned repository
  cd "$BASE_DIR/$REPO_NAME" || { echo "Error: Failed to enter directory $BASE_DIR/$REPO_NAME"; return; }

  # Determine the new origin URL
  if [ "$NEW_ORIGIN_TYPE" == "https" ]; then
    NEW_ORIGIN_URL=$(echo "$1" | sed "s|https://github.com/|https://$GITHUB_USERNAME@github.com/|")
  else
    NEW_ORIGIN_URL=$(echo "$1" | sed "s|https://github.com/|git@github.com:|")
  fi

  # Set the new origin URL
  echo "Setting origin URL: $NEW_ORIGIN_URL"
  git remote set-url origin "$NEW_ORIGIN_URL" || { echo "Error: Failed to set new origin URL"; return; }

  # Verify and add a new branch
  git remote -v
  git checkout -b "$GITHUB_USERNAME"
  echo "Successfully cloned, updated origin, and created branch for $REPO_NAME."
   # Add spacing after processing
  echo
  echo "---------------------------------------------------"
  echo
}

# Process each repository
for REPO_URL in "${REPOS[@]}"; do
  process_repo "$REPO_URL"
done

echo "All repositories processed successfully."
exit 0