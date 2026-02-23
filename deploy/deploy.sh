#!/bin/bash
# NoNotch Homebrew(Cask) 배포 스크립트
# 사용법: ./deploy.sh <version>
# 예시: ./deploy.sh 1.0.0

set -e

if [ -z "$1" ]; then
  echo "❌ 버전을 지정해주세요. (예: ./deploy.sh 1.0.0)"
  exit 1
fi

VERSION=$1
APP_NAME="NoNotch"
ARCHIVE_NAME="${APP_NAME}-${VERSION}.zip"

# 환경 설정 (레파지토리 주소)
APP_REPO="box-kr/no_notch"             # 실제 앱 릴리스가 올라갈 레파지토리
TAP_REPO="box-kr/homebrew-nonotch"     # Homebrew Tap 레파지토리

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY_DIR="${PROJECT_DIR}/deploy"
BUILD_DIR="${PROJECT_DIR}/build"
TAP_DIR="${DEPLOY_DIR}/homebrew-nonotch"

echo "🚀 NoNotch v${VERSION} Homebrew 배포 준비 시작..."

# 1. 앱 빌드
echo "🔨 앱을 새로 빌드합니다..."
cd "${PROJECT_DIR}"
chmod +x build.sh
./build.sh

# 2. 앱 압축 (Cask는 .dmg나 .zip과 같은 압축 파일을 사용합니다)
echo "📦 앱을 압축합니다: ${ARCHIVE_NAME}"
cd "${BUILD_DIR}"
rm -f "${ARCHIVE_NAME}"
zip -qry "${ARCHIVE_NAME}" "${APP_NAME}.app"

# 3. 해시 계산
SHA256=$(shasum -a 256 "${ARCHIVE_NAME}" | awk '{print $1}')
echo "✅ SHA256 해시값: ${SHA256}"

# 4. GitHub Release 업로드 (gh CLI 필요)
echo "🌐 GitHub Release에 업로드합니다..."
if ! command -v gh &> /dev/null; then
    echo "⚠️ GitHub CLI(gh)가 설치되지 않았습니다. 릴리스 자동 업로드를 건너뜁니다."
    echo "직접 ${APP_REPO}의 Releases에 ${ARCHIVE_NAME} 파일을 업로드해주세요."
else
    # 릴리스가 이미 있는지 확인하고 없으면 생성 후 업로드, 있으면 덮어쓰기
    gh release view "v${VERSION}" --repo "${APP_REPO}" &> /dev/null && \
        gh release upload "v${VERSION}" "${ARCHIVE_NAME}" --repo "${APP_REPO}" --clobber || \
        gh release create "v${VERSION}" "${ARCHIVE_NAME}" --repo "${APP_REPO}" --title "v${VERSION}" --notes "Release v${VERSION}"
fi

# 5. Homebrew Tap 업데이트
echo "📥 Homebrew Tap(${TAP_REPO}) 저장소를 설정합니다..."
cd "${DEPLOY_DIR}"
if [ -d "${TAP_DIR}" ]; then
  cd "${TAP_DIR}"
  git pull origin main || git pull origin master || true
else
  git clone "https://github.com/${TAP_REPO}.git"
  cd "homebrew-nonotch"
fi

echo "📝 Cask 파일을 생성/업데이트합니다..."
mkdir -p Casks

cat <<EOF > Casks/nonotch.rb
cask "nonotch" do
  version "${VERSION}"
  sha256 "${SHA256}"

  url "https://github.com/${APP_REPO}/releases/download/v#{version}/${APP_NAME}-#{version}.zip"
  name "${APP_NAME}"
  desc "macOS Menu Bar Utility for hiding the notch"
  homepage "https://github.com/${APP_REPO}"

  app "${APP_NAME}.app"

  zap trash: [
    "~/Library/Preferences/com.box-kr.NoNotch.plist",
  ]
end
EOF

# 6. Tap 변경사항 커밋 및 푸시
echo "📤 Homebrew Tap 레파지토리에 푸시합니다..."
git add Casks/nonotch.rb
git commit -m "Update NoNotch to v${VERSION}" || echo "변경 사항이 없습니다."
git push origin HEAD || echo "❌ 푸시 실패. 권한을 확인해 주세요."

echo "🎉 배포 완료! 다음 명령어로 설치 및 업데이트할 수 있습니다:"
echo "--------------------------------------------------------"
echo "brew tap ${TAP_REPO}"
echo "brew install --cask nonotch"
echo "--------------------------------------------------------"
