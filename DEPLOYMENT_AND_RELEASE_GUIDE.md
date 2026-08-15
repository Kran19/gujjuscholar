# GujjuScholar: End-to-End Deployment & Google Play Store Release Guide

This document provides clear, step-by-step instructions for deploying backend changes to the live VPS server and releasing new Flutter app updates (`.aab`) to the Google Play Store.

---

## 1. Live VPS Backend & Website Deployment

Your live backend is hosted at `/var/www/edustream` on Ubuntu VPS (`187.127.131.178`).

### Step-by-Step Server Update:

In your open SSH terminal (`root@187.127.131.178`), run the following commands:

```bash
# 1. Navigate to the project root
cd /var/www/edustream

# 2. Pull the latest committed changes
git pull origin main

# 3. Clear Laravel caches to reflect updated Blade views and API logic
php artisan optimize:clear
php artisan view:clear
php artisan route:clear
php artisan config:clear

# 4. Restart queue worker (if running via supervisor)
sudo supervisorctl restart all
```

*Note: As soon as `php artisan view:clear` runs, `https://gujjuscholar.in/` will immediately show the updated logo and the removed Admin Portal button without any downtime.*

---

## 2. Generating the Android App Bundle (`.aab`) for Google Play Store

### Prerequisites Configuration Checked:
- **Application ID:** Set to `com.emperorsmartsolutions.gujjuscholar` in `android/app/build.gradle.kts`.
- **App Label:** Set to `GujjuScholar` in `AndroidManifest.xml`.
- **Version:** Bumped to `1.0.1+2` in `pubspec.yaml` (Version Code `2`).

### Step-by-Step Build Command:

Open your local terminal and run:

```bash
# 1. Navigate to the Flutter app directory
cd "c:\Users\PC\Desktop\Karan Sir\gujjuscholar\gujjustudent"

# 2. Clean previous build artifacts and fetch dependencies
flutter clean
flutter pub get

# 3. Build the release App Bundle (.aab)
flutter build appbundle --release
```

### Output File Location:
Once the command finishes, your `.aab` file will be generated at:
```
c:\Users\PC\Desktop\Karan Sir\gujjuscholar\gujjustudent\build\app\outputs\bundle\release\app-release.aab
```

---

## 3. Uploading `.aab` to Google Play Console

1. **Log in to Google Play Console:**
   - Go to [play.google.com/console](https://play.google.com/console)
   - Select your app: **GujjuScholar** (`com.emperorsmartsolutions.gujjuscholar`).

2. **Create New Release:**
   - In the left sidebar under **Release**, click **Production** (or **Open Testing** / **Internal Testing** if testing first).
   - Click the blue **Create new release** button (top right).

3. **Upload `.aab`:**
   - Drag and drop `app-release.aab` into the **App bundles** upload box.
   - Wait for Google Play to finish analyzing the bundle.

4. **Add Release Notes:**
   Paste the following release notes:
   ```text
   <en-US>
   - Fixed explore course banner display.
   - Enhanced email OTP authentication and verification flow.
   - Improved performance and overall stability.
   </en-US>
   ```

5. **Review and Publish:**
   - Click **Save** (bottom right).
   - Click **Review release**.
   - Click **Start rollout to Production**.

---

## 4. How Future Developers Can Bump App Version & Update

Whenever new features or bug fixes are ready for Play Store update:

1. **Open `pubspec.yaml`** and find the `version:` line:
   ```yaml
   # Format: major.minor.patch+versionCode
   version: 1.0.2+3
   ```
   - **`1.0.2`** is the version name visible to students on Play Store.
   - **`+3`** is the internal build/version code (Must be an integer strictly greater than the previous release, e.g. 1 -> 2 -> 3).

2. **Re-run the build command:**
   ```bash
   flutter build appbundle --release
   ```

3. **Upload the new `.aab` to Google Play Console following Section 3.**
