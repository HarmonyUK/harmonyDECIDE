#!/bin/bash

# Create all decidim_discord directories

mkdir -p decidim_discord/app/assets/config
mkdir -p decidim_discord/app/assets/stylesheets/decidim_discord
mkdir -p decidim_discord/app/commands/decidim_discord
mkdir -p decidim_discord/app/controllers/decidim_discord/admin
mkdir -p decidim_discord/app/forms/decidim_discord
mkdir -p decidim_discord/app/helpers
mkdir -p decidim_discord/app/jobs/decidim_discord
mkdir -p decidim_discord/app/mailers/decidim_discord
mkdir -p decidim_discord/app/models/decidim_discord
mkdir -p decidim_discord/app/permissions/decidim_discord/admin
mkdir -p decidim_discord/app/services/decidim_discord
mkdir -p decidim_discord/app/views/decidim_discord/admin/discord_webhooks
mkdir -p decidim_discord/app/views/decidim_discord/admin/webhook_logs
mkdir -p decidim_discord/app/views/decidim_discord/layouts/decidim_discord
mkdir -p decidim_discord/bin
mkdir -p decidim_discord/config/locales
mkdir -p decidim_discord/db/migrate
mkdir -p decidim_discord/lib/decidim_discord
mkdir -p decidim_discord/lib/tasks

echo "✅ All directories created!"
