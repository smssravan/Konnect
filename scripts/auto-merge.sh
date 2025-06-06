#!/bin/bash
set -e

# Configuration
REPO_URL="git@github.com:<your-username>/<your-repo>.git"
INTERMEDIATE_BRANCH="intermediate_branch"

# Step 1: Clean up and clone
rm -rf repo-clone
git clone "$REPO_URL" repo-clone
cd repo-clone

# Step 2: Set Git identity
git config user.name "Auto Merge Bot"
git config user.email "bot@example.com"

# Step 3: Checkout master and pull latest
git checkout master
git pull origin master

# Step 4: Create intermediate_branch from master
git checkout -b "$INTERMEDIATE_BRANCH"

# Step 5: Find all feature branches (excluding master/main/intermediate)
branches=$(git branch -r | grep -vE "origin/(master|main|${INTERMEDIATE_BRANCH})" | sed 's|origin/||' | uniq)

# Step 6: Merge all feature branches into intermediate_branch
for branch in $branches; do
  echo "Merging branch: $branch"
  git fetch origin "$branch:$branch"
  git merge --no-edit --no-ff "$branch" || {
    echo "❌ Merge conflict in $branch — skipping."
    git merge --abort
  }
done

# Step 7: Push intermediate_branch
git push origin "$INTERMEDIATE_BRANCH"

# Step 8: Merge intermediate_branch into master
git checkout master
git merge --no-edit --no-ff "$INTERMEDIATE_BRANCH"

# Step 9: Push updated master to GitHub
git push origin master

echo "✅ All branches merged into $INTERMEDIATE_BRANCH and then to master"

