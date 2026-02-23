#!/bin/bash
# NoNotch 빌드 스크립트
# 사용법: ./build.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
APP_NAME="NoNotch"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
INFO_PLIST="${PROJECT_DIR}/Sources/NoNotch/Resources/Info.plist"

# 버전 자동 증가 처리 (1.0.x)
if [ -f "${INFO_PLIST}" ]; then
    CURRENT_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFO_PLIST}")
    if [[ $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        MAJOR="${BASH_REMATCH[1]}"
        MINOR="${BASH_REMATCH[2]}"
        PATCH="${BASH_REMATCH[3]}"
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"
        
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${NEW_VERSION}" "${INFO_PLIST}"
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${NEW_VERSION}" "${INFO_PLIST}"
        echo "🔄 버전 업데이트: ${CURRENT_VERSION} -> ${NEW_VERSION}"
    fi
fi

echo "🔨 NoNotch 빌드 시작..."

# 빌드 디렉토리 생성
mkdir -p "${BUILD_DIR}"

# .app 번들 구조 생성
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Swift 소스 파일 컴파일
echo "📦 소스 파일 컴파일 중..."
swiftc \
    -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" \
    -framework AppKit \
    -framework WebKit \
    -framework ServiceManagement \
    -target arm64-apple-macosx12.0 \
    "${PROJECT_DIR}/Sources/NoNotch/NotchOverlayManager.swift" \
    "${PROJECT_DIR}/Sources/NoNotch/LaunchAtLoginManager.swift" \
    "${PROJECT_DIR}/Sources/NoNotch/Localization.swift" \
    "${PROJECT_DIR}/Sources/NoNotch/AppDelegate.swift" \
    "${PROJECT_DIR}/Sources/NoNotch/main.swift"

# Resources 복사 (Info.plist 포함)
cp -r "${PROJECT_DIR}/Sources/NoNotch/Resources/"* "${APP_BUNDLE}/Contents/Resources/"

# Info.plist를 올바른 위치로 이동
mv "${APP_BUNDLE}/Contents/Resources/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"

echo "✅ 빌드 완료: ${APP_BUNDLE}"
echo ""
echo "실행하려면:"
echo "  open ${APP_BUNDLE}"
echo ""
echo "Applications 폴더에 설치하려면:"
echo "  cp -r ${APP_BUNDLE} /Applications/"
