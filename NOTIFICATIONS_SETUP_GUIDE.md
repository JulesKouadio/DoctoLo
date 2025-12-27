# Guide de Configuration des Notifications Push

## 🚨 Problème Résolu : "APNS token not available yet"

Ce guide explique comment configurer correctement les notifications push iOS et résoudre le problème du token APNS.

## ✅ Corrections Effectuées

### 1. **firebase_service.dart** - Amélioration de la gestion APNS
```dart
✅ Retry automatique avec délai exponentiel (2s, 4s, 6s)
✅ Gestion des tokens provisoires
✅ Écoute des rafraîchissements de token
✅ Sauvegarde automatique du FCM token dans Firestore
✅ Messages de log clairs avec emojis
```

**Fonctionnalités ajoutées:**
- `_setupFCMToken()` - Configuration complète du token
- `_getAPNSTokenWithRetry()` - Retry intelligent avec 3 tentatives
- `_saveFCMToken()` - Sauvegarde dans Firestore
- Écoute de `onTokenRefresh` pour les mises à jour

### 2. **AppDelegate.swift** - Configuration native iOS
```swift
✅ Import de FirebaseCore et FirebaseMessaging
✅ Configuration Firebase au démarrage
✅ Enregistrement pour les notifications distantes
✅ Delegate pour UNUserNotificationCenter
✅ Delegate pour Messaging (FCM)
✅ Gestion du token APNS
✅ Gestion des erreurs d'enregistrement
```

**Méthodes ajoutées:**
- `didRegisterForRemoteNotificationsWithDeviceToken` - Reçoit le token APNS
- `didFailToRegisterForRemoteNotificationsWithError` - Gestion des erreurs
- Extension `MessagingDelegate` - Reçoit le token FCM

### 3. **Info.plist** - Permissions iOS
```xml
✅ FirebaseAppDelegateProxyEnabled = false (contrôle manuel)
✅ UIBackgroundModes avec remote-notification
✅ Support des notifications en arrière-plan
```

## 📋 Configuration Requise dans Xcode

### Étape 1 : Capabilities
1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Sélectionner le projet **Runner**
3. Aller dans l'onglet **Signing & Capabilities**
4. Cliquer sur **+ Capability**
5. Ajouter **Push Notifications**
6. Ajouter **Background Modes** et cocher:
   - ✅ Remote notifications
   - ✅ Background fetch (optionnel)

### Étape 2 : Apple Developer Portal
1. Aller sur [developer.apple.com](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles**
3. Sélectionner votre **App ID** (com.example.doctolo)
4. Éditer et activer **Push Notifications**
5. Créer les certificats :
   - **Development SSL Certificate** (pour dev)
   - **Production SSL Certificate** (pour release)
6. Télécharger les certificats `.p12`

### Étape 3 : Firebase Console
1. Aller sur [console.firebase.google.com](https://console.firebase.google.com)
2. Sélectionner votre projet **doctolo**
3. **Project Settings** > **Cloud Messaging**
4. Sous **Apple app configuration**
5. Uploader votre **APNs Authentication Key** (.p8) ou **APNs Certificate** (.p12)
   - **Key ID**
   - **Team ID** (de votre Apple Developer Account)

### Étape 4 : Provisioning Profile
1. Créer un nouveau **Provisioning Profile** avec Push Notifications
2. Télécharger et installer dans Xcode
3. Sélectionner ce profil dans **Signing & Capabilities**

## 🔧 Commandes de Installation

```bash
# 1. Nettoyer les pods
cd ios
rm -rf Pods Podfile.lock
cd ..

# 2. Récupérer les dépendances Flutter
flutter pub get

# 3. Installer les pods iOS
cd ios
pod install --repo-update
cd ..

# 4. Nettoyer et rebuild
flutter clean
flutter pub get

# 5. Lancer l'app
flutter run
```

## 📱 Test des Notifications

### Test 1 : Vérifier les Logs
Après le lancement de l'app, vous devriez voir :
```
✅ User granted notification permissions
⏳ APNS token not available, retrying in 2s (attempt 1/3)...
✅ APNS Token obtained: 1234567890abcdef1234...
✅ FCM Token obtained: fGHJ...klmn
✅ FCM Token saved to Firestore
📱 APNS Token registered
🔔 FCM Token: fGHJ...klmn
```

### Test 2 : Vérifier Firestore
Dans Firebase Console > Firestore > users > {userId}:
```json
{
  "fcmToken": "fGHJ...klmn",
  "fcmTokenUpdatedAt": "2025-12-26T10:30:00Z"
}
```

### Test 3 : Envoyer une Notification Test
Dans Firebase Console > Cloud Messaging > Envoyer un message test:
1. Titre: "Test Notification"
2. Message: "Hello from Doctolo"
3. Copier votre FCM Token depuis les logs
4. Cliquer "Test"

## 🐛 Résolution de Problèmes

### Problème 1 : "APNS token not available" persiste
**Cause:** L'appareil n'arrive pas à s'enregistrer auprès d'Apple

**Solutions:**
1. Vérifier que Push Notifications est activé dans Capabilities
2. Vérifier le provisioning profile
3. Tester sur un vrai appareil iOS (pas le simulateur)
4. Vérifier la connexion internet
5. Vérifier que l'App ID a Push Notifications activé

```bash
# Vérifier la configuration
cd ios
xcodebuild -showBuildSettings -workspace Runner.xcworkspace -scheme Runner | grep PROVISIONING_PROFILE
```

### Problème 2 : "FCM Token is nil"
**Cause:** Firebase n'arrive pas à générer le token

**Solutions:**
1. Vérifier que `GoogleService-Info.plist` est présent
2. Vérifier que Firebase est bien initialisé
3. Relancer l'app après avoir accepté les permissions
4. Attendre quelques secondes après l'ouverture de l'app

### Problème 3 : "No Firebase App '[DEFAULT]' has been created"
**Cause:** Firebase n'est pas initialisé avant d'accéder aux services

**Solution:**
```dart
// Dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### Problème 4 : Les notifications n'arrivent pas
**Causes possibles:**
1. Token non sauvegardé dans Firestore
2. Certificat APNs incorrect dans Firebase
3. App en foreground (notifications silencieuses)
4. Permissions refusées

**Solutions:**
1. Vérifier les logs pour le token
2. Re-uploader le certificat APNs dans Firebase Console
3. Tester avec l'app en background
4. Demander à nouveau les permissions:
```dart
await FirebaseMessaging.instance.requestPermission();
```

### Problème 5 : Simulateur iOS ne reçoit pas de notifications
**Cause:** Les simulateurs iOS ne supportent pas les vraies notifications push

**Solution:**
- Tester sur un **appareil physique** iOS
- Les simulateurs peuvent seulement tester les notifications locales

## 📊 Monitoring des Tokens

### Requête Firestore pour voir tous les tokens
```javascript
// Dans Firebase Console > Firestore
db.collection('users').where('fcmToken', '!=', null).get()
```

### Compter les utilisateurs avec tokens
```javascript
db.collection('users')
  .where('fcmToken', '!=', null)
  .get()
  .then(snapshot => console.log(`${snapshot.size} users with tokens`))
```

### Nettoyer les anciens tokens
```javascript
// Supprimer les tokens de plus de 60 jours
const sixtyDaysAgo = new Date();
sixtyDaysAgo.setDate(sixtyDaysAgo.getDate() - 60);

db.collection('users')
  .where('fcmTokenUpdatedAt', '<', sixtyDaysAgo)
  .get()
  .then(snapshot => {
    snapshot.forEach(doc => {
      doc.ref.update({ fcmToken: null });
    });
  });
```

## 🔐 Sécurité

### Firestore Rules pour les tokens
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Seul l'utilisateur peut mettre à jour son token
      allow update: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['fcmToken', 'fcmTokenUpdatedAt']);
    }
  }
}
```

## 🚀 Notifications Cloud Functions

### Exemple : Envoyer une notification lors d'un nouveau message
```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.sendMessageNotification = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    
    // Récupérer le token du destinataire
    const receiverDoc = await admin.firestore()
      .collection('users')
      .doc(message.receiverId)
      .get();
    
    const fcmToken = receiverDoc.data()?.fcmToken;
    if (!fcmToken) {
      console.log('No FCM token for receiver');
      return;
    }
    
    // Récupérer le nom de l'expéditeur
    const senderDoc = await admin.firestore()
      .collection('users')
      .doc(message.senderId)
      .get();
    
    const senderName = `${senderDoc.data()?.firstName || ''} ${senderDoc.data()?.lastName || ''}`.trim();
    
    // Envoyer la notification
    const payload = {
      notification: {
        title: senderName || 'Nouveau message',
        body: message.type === 'text' 
          ? message.content 
          : message.type === 'image' 
            ? '📷 Image' 
            : '📄 Document',
        sound: 'default',
        badge: '1'
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        conversationId: message.conversationId,
        senderId: message.senderId,
        type: 'message'
      },
      token: fcmToken
    };
    
    try {
      await admin.messaging().send(payload);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });
```

### Déployer la fonction
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser Functions
firebase init functions

# Déployer
firebase deploy --only functions
```

## 📖 Ressources

- [Firebase Cloud Messaging - iOS Setup](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Flutter firebase_messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [Apple Push Notifications](https://developer.apple.com/documentation/usernotifications)
- [Firebase Console](https://console.firebase.google.com)

## ✅ Checklist Complète

- [ ] Push Notifications activé dans Xcode Capabilities
- [ ] Background Modes > Remote notifications activé
- [ ] App ID a Push Notifications activé sur Apple Developer
- [ ] Certificat APNs uploadé dans Firebase Console
- [ ] GoogleService-Info.plist présent dans le projet
- [ ] AppDelegate.swift configuré avec Firebase
- [ ] Info.plist avec FirebaseAppDelegateProxyEnabled = false
- [ ] Info.plist avec UIBackgroundModes
- [ ] firebase_service.dart avec retry logic
- [ ] Tester sur un appareil physique iOS
- [ ] Vérifier les logs pour les tokens
- [ ] Vérifier que le token est sauvegardé dans Firestore

---

**Version:** 1.0  
**Date:** 26 Décembre 2025  
**Status:** ✅ Résolu
