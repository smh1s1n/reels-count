#!/usr/bin/env bash

# ==============================================================================
# ReelsGuard - 1-Click Local Firebase App Distribution Deploy Script
# ==============================================================================
# Usage:
#   ./scripts/deploy_firebase.sh "Release notes message" "testers_group_or_emails"
#
# Examples:
#   ./scripts/deploy_firebase.sh "Initial beta testing build"
#   ./scripts/deploy_firebase.sh "Fixed mindful dialog button bug" "beta-testers"
#   ./scripts/deploy_firebase.sh "Sprint 3 update" "tester1@gmail.com,tester2@gmail.com"
# ==============================================================================

set -euo pipefail

# Configuration
APP_ID="1:1039029012352:android:46965fd309e781c6522365"
PROJECT_ID="reelsguard-shield-2026"
DEFAULT_RELEASE_NOTES="ReelsGuard Beta - Automated build from $(date '+%Y-%m-%d %H:%M:%S')"
RELEASE_NOTES="${1:-$DEFAULT_RELEASE_NOTES}"
TESTERS="${2:-}"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}===================================================================${NC}"
echo -e "${CYAN}     🛡️  ReelsGuard - Firebase App Distribution Automation       ${NC}"
echo -e "${CYAN}===================================================================${NC}"
echo -e "${YELLOW}• Project ID:${NC}     $PROJECT_ID"
echo -e "${YELLOW}• App ID:${NC}         $APP_ID"
echo -e "${YELLOW}• Release Notes:${NC}  $RELEASE_NOTES"
if [ -n "$TESTERS" ]; then
  echo -e "${YELLOW}• Testers/Groups:${NC} $TESTERS"
fi
echo ""

# 1. Verify Prerequisites
echo -e "${CYAN}[1/5] Checking environment tools...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: 'flutter' command not found in PATH.${NC}"
    exit 1
fi

if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Error: 'firebase' CLI not found in PATH. Install via: npm install -g firebase-tools${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Flutter and Firebase CLI are ready.${NC}"

# 2. Run Static Analysis & Tests
echo -e "\n${CYAN}[2/5] Running static analysis & automated tests...${NC}"
flutter analyze
flutter test
echo -e "${GREEN}✓ All analyzer checks and unit/widget tests passed cleanly.${NC}"

# 3. Build Multi-Architecture Release APK
echo -e "\n${CYAN}[3/5] Building release APK (multi-ABI for all physical Android phones)...${NC}"
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}Error: Release APK not found at $APK_PATH${NC}"
    exit 1
fi
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo -e "${GREEN}✓ Release APK built successfully: $APK_PATH ($APK_SIZE)${NC}"

# 4. Upload to Firebase App Distribution
echo -e "\n${CYAN}[4/5] Uploading binary to Firebase App Distribution...${NC}"

DISTRIBUTE_CMD=(firebase appdistribution:distribute "$APK_PATH" --app "$APP_ID" --release-notes "$RELEASE_NOTES")

if [ -n "$TESTERS" ]; then
    if [[ "$TESTERS" == *"@"* ]]; then
        DISTRIBUTE_CMD+=(--testers "$TESTERS")
    else
        DISTRIBUTE_CMD+=(--groups "$TESTERS")
    fi
fi

"${DISTRIBUTE_CMD[@]}"

# 5. Summary & Links
echo -e "\n${CYAN}[5/5] Deployment Complete! 🎉${NC}"
echo -e "${GREEN}===================================================================${NC}"
echo -e "${GREEN}✓ New APK is live on Firebase App Distribution!${NC}"
echo -e "${YELLOW}• Manage in Firebase Console:${NC}"
echo -e "  https://console.firebase.google.com/project/${PROJECT_ID}/appdistribution/app/android:com.antidoomscroll.reels.reels_count/releases"
echo -e "${YELLOW}• Tester App Portal:${NC}"
echo -e "  https://appdistribution.firebase.google.com/testerapps/${APP_ID}"
echo -e "${GREEN}===================================================================${NC}"
