#!/data/data/com.termux/files/usr/bin/bash
# Prepara o projeto Vibe para compilar o APK no GitHub Actions.
# Rode dentro da pasta onde está o index.html (~/vibe-app/frontend).

if [ ! -f index.html ]; then
  echo "Erro: index.html não encontrado nesta pasta."
  exit 1
fi

mkdir -p .github/workflows

cat > package.json << 'EOF'
{
  "name": "vibe",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@capacitor/android": "^6.1.2",
    "@capacitor/cli": "^6.1.2",
    "@capacitor/core": "^6.1.2"
  }
}
EOF

cat > capacitor.config.json << 'EOF'
{
  "appId": "com.vibe.app",
  "appName": "Vibe",
  "webDir": "www"
}
EOF

cat > .github/workflows/apk.yml << 'EOF'
name: Compilar APK
on:
  push:
    branches: [main]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
      - run: npm install
      - run: mkdir -p www && cp index.html www/
      - run: npx cap add android
      - run: npx cap sync android
      - run: cd android && chmod +x gradlew && ./gradlew assembleDebug
      - uses: actions/upload-artifact@v4
        with:
          name: vibe-apk
          path: android/app/build/outputs/apk/debug/app-debug.apk
EOF

printf 'node_modules\nandroid\nwww\n' > .gitignore

echo "Pronto. Ficheiros criados: package.json, capacitor.config.json, .github/workflows/apk.yml"
