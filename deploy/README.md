# Homebrew 배포 가이드 (NoNotch)

이 폴더는 `NoNotch` 앱을 Homebrew를 통해 GitHub 레파지토리(`https://github.com/box-kr/homebrew-nonotch`)에 배포하기 위한 스크립트와 구성을 포함하고 있습니다.
`NoNotch`는 macOS GUI 애플리케이션이므로, 바이너리(.app 번들)를 직접 압축하여 **Cask** 형식으로 배포하는 방식으로 구성되었습니다.

## 📌 필수 준비물
1. **GitHub CLI (`gh`)**: 릴리스를 생성하고 바이너리 앱을 업로드하기 위해 필요합니다.
   ```bash
   brew install gh
   gh auth login # GitHub 계정 로그인
   ```
2. **레파지토리 쓰기 권한**: 
   - 앱 릴리스 레파지토리: `box-kr/no_notch`
   - Homebrew Tap 레파지토리: `box-kr/homebrew-nonotch`

## 🚀 배포 방법

배포 스크립트를 사용하여 앱 빌드부터 Tap 푸시까지 한 번에 진행할 수 있습니다.

```bash
cd deploy
./deploy.sh <VERSION>
# 예시: ./deploy.sh 1.0.0
```

## ⚙️ 스크립트의 작동 원리

`deploy.sh` 스크립트는 다음 작업들을 순차적으로 실행합니다:
1. `../build.sh`를 실행하여 새로운 `NoNotch.app`을 빌드합니다.
2. 빌드된 애플리케이션을 `NoNotch-<버전>.zip` 형식으로 압축합니다.
3. 무결성을 위한 `SHA256` 해시를 추출합니다.
4. `gh` 커맨드를 사용해 `box-kr/no_notch` (앱 레파지토리)에 릴리스를 생성하고 zip 파일을 업로드합니다.
5. 로컬에 `box-kr/homebrew-nonotch` (Tap 레파지토리)를 클론(또는 풀) 받습니다.
6. `Casks/nonotch.rb` Cask 배포 파일을 생성 또는 업데이트합니다 (업로드된 zip URL과 해시 포함).
7. 수정한 Tap 레파지토리를 커밋 후, GitHub에 푸시합니다.

## 📦 사용자 설치 방법

성공적으로 배포가 완료되면, 일반 사용자들은 로컬 macOS 터미널에서 다음 명령어로 손쉽게 앱을 설치할 수 있게 됩니다:

```bash
# 커스텀 탭 레파지토리 등록
brew tap box-kr/homebrew-nonotch

# 애플리케이션 설치
brew install --cask nonotch
```

업데이트된 경우 사용자는 다음과 같이 업그레이드할 수 있습니다:
```bash
brew upgrade nonotch
```
