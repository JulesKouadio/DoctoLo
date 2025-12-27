#!/bin/bash

# Script pour réinstaller les pods iOS et corriger les problèmes de notifications

echo "🧹 Nettoyage des pods iOS..."
cd ios
rm -rf Pods Podfile.lock
cd ..

echo "📦 Récupération des dépendances Flutter..."
flutter pub get

echo "🔧 Installation des pods iOS..."
cd ios
pod install --repo-update
cd ..

echo "✨ Nettoyage Flutter..."
flutter clean
flutter pub get

echo ""
echo "✅ Installation terminée!"
echo ""
echo "Prochaines étapes:"
echo "1. Ouvrir ios/Runner.xcworkspace dans Xcode"
echo "2. Vérifier Signing & Capabilities > Push Notifications"
echo "3. Vérifier Background Modes > Remote notifications"
echo "4. Lancer: flutter run"
echo ""
echo "📖 Voir NOTIFICATIONS_SETUP_GUIDE.md pour plus de détails"
