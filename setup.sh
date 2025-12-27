#!/bin/bash

# 🏥 Doctolo - Script de Configuration Rapide
# Ce script configure automatiquement l'environnement de développement

echo "🏥 Bienvenue dans Doctolo Setup!"
echo "================================"
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Vérifier Flutter
echo -e "${BLUE}📱 Vérification de Flutter...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé!${NC}"
    echo "Installez Flutter depuis: https://flutter.dev/docs/get-started/install"
    exit 1
else
    echo -e "${GREEN}✅ Flutter trouvé: $(flutter --version | head -n 1)${NC}"
fi

# Vérifier la version Flutter
echo ""
echo -e "${BLUE}🔍 Vérification de la version Flutter...${NC}"
flutter doctor

# Installer les dépendances
echo ""
echo -e "${BLUE}📦 Installation des dépendances...${NC}"
flutter pub get

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Dépendances installées avec succès!${NC}"
else
    echo -e "${RED}❌ Erreur lors de l'installation des dépendances${NC}"
    exit 1
fi

# Générer les fichiers Hive
echo ""
echo -e "${BLUE}🔨 Génération des adapters Hive...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Fichiers générés avec succès!${NC}"
else
    echo -e "${YELLOW}⚠️  Erreur lors de la génération (cela peut arriver si Firebase n'est pas configuré)${NC}"
fi

# Vérifier la configuration Firebase
echo ""
echo -e "${BLUE}🔥 Vérification Firebase...${NC}"

if [ ! -f "android/app/google-services.json" ]; then
    echo -e "${YELLOW}⚠️  google-services.json n'est pas trouvé (Android)${NC}"
    echo "   Téléchargez-le depuis Firebase Console et placez-le dans android/app/"
else
    echo -e "${GREEN}✅ google-services.json trouvé (Android)${NC}"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${YELLOW}⚠️  GoogleService-Info.plist n'est pas trouvé (iOS)${NC}"
    echo "   Téléchargez-le depuis Firebase Console et placez-le dans ios/Runner/"
else
    echo -e "${GREEN}✅ GoogleService-Info.plist trouvé (iOS)${NC}"
fi

# Créer le dossier assets s'il n'existe pas
echo ""
echo -e "${BLUE}📁 Création des dossiers assets...${NC}"
mkdir -p assets/images assets/icons assets/animations assets/fonts
echo -e "${GREEN}✅ Dossiers assets créés${NC}"

# Nettoyer le projet
echo ""
echo -e "${BLUE}🧹 Nettoyage du projet...${NC}"
flutter clean
flutter pub get

# Résumé
echo ""
echo "================================"
echo -e "${GREEN}✨ Configuration terminée!${NC}"
echo ""
echo "📋 Prochaines étapes:"
echo "   1. Configurez Firebase (voir QUICKSTART.md)"
echo "   2. Ajoutez vos API Keys dans lib/core/constants/app_constants.dart"
echo "   3. Lancez l'app avec: flutter run"
echo ""
echo "📚 Documentation:"
echo "   - README.md          → Vue d'ensemble du projet"
echo "   - QUICKSTART.md      → Guide de démarrage rapide"
echo "   - TECHNICAL_DOCS.md  → Documentation technique"
echo ""
echo -e "${BLUE}🚀 Pour lancer l'app: flutter run${NC}"
echo ""
