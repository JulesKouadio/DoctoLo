# Test Configuration Firebase

## Vérifications à faire dans Firebase Console

### 1. Aller sur https://console.firebase.google.com/project/doctolo

### 2. Vérifier Authentication
- Cliquez sur "Authentication" dans le menu
- Cliquez sur "Sign-in method"
- **VÉRIFIEZ:** Email/Password doit être **ACTIVÉ** (toggle vert)

### 3. Si Email/Password est DÉSACTIVÉ:
1. Cliquez sur "Email/Password"
2. Activez le toggle "Enable"
3. Cliquez sur "Save"

### 4. Créer un utilisateur test manuellement
1. Dans "Authentication" → onglet "Users"
2. Cliquez sur "Add user"
3. Email: test@test.com
4. Password: Test123456
5. Cliquez sur "Add user"

Si vous pouvez créer un utilisateur manuellement, mais pas via l'app, c'est un problème de configuration API.

### 5. Vérifier les API Keys (dans Project Settings)
1. Cliquez sur l'icône ⚙️ à côté de "Project Overview"
2. Allez dans "Project settings"
3. Onglet "General"
4. Vérifiez que les API Keys correspondent à celles dans `firebase_options.dart`:

**iOS API Key devrait être:** AIzaSyC1EGklP_S77eiFYfpDhbieoxNN-di60iQ

### 6. Vérifier que l'API Identity Toolkit est activée
1. Allez sur https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=doctolo
2. Cliquez sur "ENABLE" si ce n'est pas déjà fait

### 7. Vérifier le Bundle ID iOS
Dans "Project Settings" → "Your apps" → iOS app:
- Bundle ID doit être: `com.juleskouadio.doctolo`
- Téléchargez à nouveau le `GoogleService-Info.plist` si nécessaire

## Test rapide dans la console

Dans l'onglet "Authentication" → "Users", essayez de:
1. Cliquer sur "Add user"
2. Entrer un email et mot de passe
3. Si ça fonctionne = Firebase est bien configuré
4. Si ça échoue = problème de configuration projet Firebase

## Commandes de test

Dans le terminal Flutter, tapez `r` pour hot reload après avoir:
- Activé Email/Password auth
- Vérifié l'API Identity Toolkit
