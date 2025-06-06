#!/bin/bash

REPO_URL="https://github.com/smssravan/Konnect.git"
CLONE_DIR="repo-clone"

# Clean up any old clone
rm -rf "$CLONE_DIR"

echo "🔄 Cloning repository..."
git clone "$REPO_URL" "$CLONE_DIR" || exit 1
cd "$CLONE_DIR" || exit 1

# Checkout master and pull latest
git checkout master
git pull origin master

# Create or reset intermediate branch
git checkout -B intermediate

# Get all remote branches except master/main/intermediate
BRANCHES=$(git branch -r | grep -v 'origin/master' | grep -v 'origin/main' | grep -v 'origin/intermediate' | grep 'origin/' | sed 's/origin\///')

echo "🔀 Merging branches into intermediate:"
for branch in $BRANCHES; do
  echo "➡️ Merging: $branch"
  git fetch origin "$branch"
  git merge origin/"$branch" --no-edit || {
    echo "❌ Merge conflict with $branch — resolve manually."
    exit 1
  }
done

# Push intermediate branch
git push origin intermediate

# Merge intermediate into master
git checkout master
git merge intermediate --no-edit

# Push master to GitHub
git push origin master

echo "✅ All changes merged and pushed to GitHub."

