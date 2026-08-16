#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "================================================="
echo "🚀 Starting GujjuScholar Backend Deployment 🚀"
echo "================================================="

# 1. Pull latest changes
echo "📥 Pulling latest changes from origin/main..."
git pull origin main

# 2. Navigate to Laravel backend directory
# (Assuming the script is run from the root of the repository)
if [ -d "gujjuadmin" ]; then
    echo "📁 Navigating to backend directory (gujjuadmin)..."
    cd gujjuadmin
else
    echo "⚠️ gujjuadmin directory not found, assuming we are already inside it."
fi

# 3. Install composer dependencies
echo "📦 Installing/Updating Composer dependencies..."
composer install --no-interaction --prefer-dist --optimize-autoloader

# 4. Run database migrations
echo "🗄️ Running database migrations..."
php artisan migrate --force

# 5. Clear and cache Laravel settings
echo "🧹 Clearing and caching Laravel caches..."
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 6. Restart supervisor queues
echo "🔄 Restarting queue workers via Supervisor..."
# Using '|| true' to prevent the script from failing if supervisorctl isn't set up yet
sudo supervisorctl restart all || true

echo "================================================="
echo "✅ Deployment completed successfully! ✅"
echo "================================================="
