// Firebase Configuration File
// Ce fichier doit être créé après avoir configuré votre projet Firebase

class FirebaseConfig {
  // Pour obtenir ces valeurs:
  // 1. Allez sur https://console.firebase.google.com
  // 2. Créez un nouveau projet ou sélectionnez un projet existant
  // 3. Ajoutez une application (Android, iOS, Web)
  // 4. Téléchargez les fichiers de configuration

  // Android: google-services.json
  // - Placez-le dans: android/app/google-services.json

  // iOS: GoogleService-Info.plist
  // - Placez-le dans: ios/Runner/GoogleService-Info.plist

  // Web: Utilisez les valeurs ci-dessous
  static const firebaseOptions = {
    'apiKey': 'YOUR_API_KEY',
    'authDomain': 'your-project.firebaseapp.com',
    'projectId': 'your-project-id',
    'storageBucket': 'your-project.appspot.com',
    'messagingSenderId': 'YOUR_SENDER_ID',
    'appId': 'YOUR_APP_ID',
    'measurementId': 'YOUR_MEASUREMENT_ID',
  };

  // Firestore Collections - Structure de base
  static const collections = {
    'users': 'users',
    'doctors': 'doctors',
    'patients': 'patients',
    'appointments': 'appointments',
    'medical_records': 'medical_records',
    'prescriptions': 'prescriptions',
    'messages': 'messages',
    'conversations': 'conversations',
    'pharmacies': 'pharmacies',
    'reviews': 'reviews',
    'payments': 'payments',
    'notifications': 'notifications',
  };

  // Règles de sécurité Firestore recommandées
  static const securityRules = '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Doctors collection
    match /doctors/{doctorId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     get(/databases/\$(database)/documents/users/\$(request.auth.uid)).data.role == 'doctor';
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      allow read: if request.auth != null && 
                    (resource.data.patientId == request.auth.uid || 
                     resource.data.doctorId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                      (resource.data.patientId == request.auth.uid || 
                       resource.data.doctorId == request.auth.uid);
      allow delete: if request.auth != null && 
                      resource.data.patientId == request.auth.uid;
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
''';

  // Règles de sécurité Storage recommandées
  static const storageRules = '''
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile images
    match /profile_images/{userId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.auth.uid == userId &&
                     request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                     request.resource.contentType.matches('image/.*');
    }
    
    // Medical documents
    match /medical_documents/{userId}/{filename} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && 
                     request.auth.uid == userId &&
                     request.resource.size < 10 * 1024 * 1024; // Max 10MB
    }
    
    // Prescriptions
    match /prescriptions/{userId}/{filename} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null;
    }
    
    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
''';
}

// Instructions d'activation des services Firebase:
//
// 1. Authentication:
//    - Allez dans Authentication > Sign-in method
//    - Activez "Email/Password"
//    - (Optionnel) Activez Google, Facebook, Apple Sign-In
//
// 2. Firestore Database:
//    - Créez une base de données Firestore
//    - Choisissez la région Europe (eur3 ou europe-west1) pour RGPD
//    - Mode: Production avec les règles ci-dessus
//
// 3. Storage:
//    - Activez Firebase Storage
//    - Appliquez les règles de sécurité ci-dessus
//
// 4. Cloud Messaging:
//    - Activez Firebase Cloud Messaging pour les notifications push
//
// 5. Cloud Functions (Optionnel):
//    - Pour les fonctionnalités avancées (rappels automatiques, etc.)
