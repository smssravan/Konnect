#!/bin/bash
set -e

# CONFIGURATION
REPO_URL="https://github.com/smssravan/Konnect.git"
CLONE_DIR="repo-clone"
INTERMEDIATE_BRANCH="intermediate"
GIT_NAME="Auto Merge Bot"
GIT_EMAIL="bot@example.com"

# CLEANUP AND CLONE
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR"

# SET USER
git config user.name "$GIT_NAME"
git config user.email "$GIT_EMAIL"

# START FROM MASTER
git checkout master
git pull origin master

# CREATE INTERMEDIATE FROM MASTER
git checkout -b "$INTERMEDIATE_BRANCH"

# LIST REMOTE BRANCHES EXCLUDING master/main/intermediate
branches=$(git branch -r | grep -vE "origin/(master|main|$INTERMEDIATE_BRANCH)" | sed 's|origin/||' | uniq)

echo "Merging these branches into $INTERMEDIATE_BRANCH:"
echo "$branches"
echo "--------------------------------------------"

# MERGE EACH BRANCH INTO INTERMEDIATE
for branch in $branches; do
  echo "▶️ Merging: $branch"
  git fetch origin "$branch:$branch"
  git merge --no-edit "$branch" || {
    echo "❌ Merge conflict in $branch – skipping"
    git merge --abort
  }
done

# PUSH INTERMEDIATE
git push origin "$INTERMEDIATE_BRANCH"

# MERGE INTERMEDIATE INTO MASTER
git checkout master
git merge --no-edit "$INTERMEDIATE_BRANCH"
git push origin master

echo "✅ All branches merged into '$INTERMEDIATE_BRANCH' and pushed to 'master'"

