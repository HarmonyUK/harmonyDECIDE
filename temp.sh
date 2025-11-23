# Navigate to your repo
cd ~/harmony_decide

# Create backup FIRST
echo "Creating backup..."
git clone --mirror . /tmp/harmony_decide_backup.git
echo "✅ Backup created at /tmp/harmony_decide_backup.git"
echo ""

# Use the correct syntax: --path (singular) instead of --paths
# Remove sensitive files from history

echo "Removing config/application.yml..."
~/.local/bin/git-filter-repo --force --invert-paths --path config/application.yml

echo "Removing config/database.yml..."
~/.local/bin/git-filter-repo --force --invert-paths --path config/database.yml

echo "Removing config/secrets.yml..."
~/.local/bin/git-filter-repo --force --invert-paths --path config/secrets.yml

echo "Removing config/application.yml...."
~/.local/bin/git-filter-repo --force --invert-paths --path config/application.yml.

echo "Removing docker-compose-etherpad.yml.old..."
~/.local/bin/git-filter-repo --force --invert-paths --path docker-compose-etherpad.yml.old

echo "Removing docker-compose.yml.decidim..."
~/.local/bin/git-filter-repo --force --invert-paths --path docker-compose.yml.decidim

echo "Removing decidim_discord/Gemfile..."
~/.local/bin/git-filter-repo --force --invert-paths --path decidim_discord/Gemfile

echo ""
echo "✅ All files removed from history!"
echo ""

# Verify files are gone
echo "Verifying config/application.yml is gone from history..."
git log --all --oneline -- config/application.yml 2>&1 | head -3

echo ""
echo "Current git status:"
git status

echo ""
echo "=================================================="
echo "⚠️  READY FOR FORCE PUSH"
echo "=================================================="
echo ""
echo "Run these commands to push the cleaned history:"
echo ""
echo "  git push origin --force --all"
echo "  git push origin --force --tags"
echo ""
echo "WARNING: This will rewrite history for all collaborators!"
echo "Make sure everyone knows before you do this."
