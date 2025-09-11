#!/bin/bash

# Set your repo URL and main branch name
REPO_URL="https://github.com/smssravan/Konnect"  # Replace with your actual repo
MAIN_BRANCH="main"
CLONE_DIR="repo-clone"

# Ask for tag names (space-separated)
read -p "🔖 Enter the tag names to merge into $MAIN_BRANCH (space-separated): " -a TAGS

# Clean up any old clone
rm -rf "$CLONE_DIR"

echo "🚀 Cloning repository..."
git clone "$REPO_URL" "$CLONE_DIR" || exit 1
cd "$CLONE_DIR" || exit 1

# Checkout main and pull latest
git checkout $MAIN_BRANCH
git pull origin $MAIN_BRANCH

# Loop through each tag and merge
for TAG in "${TAGS[@]}"; do
  echo "🔄 Processing tag: $TAG"

  # Check if tag exists
  if ! git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "⚠️ Tag '$TAG' does not exist. Skipping."
    continue
  fi

  # Create a temporary branch from the tag
  git checkout -b "temp-tag-$TAG" "$TAG"

  # Checkout main again
  git checkout $MAIN_BRANCH

  # Merge the tag-based temp branch into main
  git merge "temp-tag-$TAG" --no-edit || {
    echo "❌ Merge conflict with tag $TAG — resolve manually."
    exit 1
  }

  # Delete temporary branch
  git branch -D "temp-tag-$TAG"
done

# Push updated main branch to remote
git push origin $MAIN_BRANCH

echo "✅ All specified tags merged into '$MAIN_BRANCH' and pushed to GitHub."

