import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Firestore settings
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Request notification permissions
    await _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permissions');
        // Ne pas bloquer l'initialisation - essayer en arrière-plan
        _setupFCMToken();
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional notification permissions');
        _setupFCMToken();
      } else {
        print('❌ User declined notification permissions');
      }

      // Écouter les changements de token
      messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _saveFCMToken(newToken);
      });
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
    }
  }

  Future<void> _setupFCMToken() async {
    try {
      // Sur iOS, essayer d'obtenir le token APNS avec retry
      String? apnsToken = await _getAPNSTokenWithRetry(maxRetries: 5);

      if (apnsToken != null) {
        print('✅ APNS Token obtained: ${apnsToken.substring(0, 20)}...');

        // Maintenant qu'on a le token APNS, on peut obtenir le FCM token
        try {
          String? fcmToken = await messaging.getToken();
          if (fcmToken != null) {
            print('✅ FCM Token obtained: ${fcmToken.substring(0, 20)}...');
            await _saveFCMToken(fcmToken);
          } else {
            print('❌ Failed to get FCM Token');
          }
        } catch (e) {
          print('❌ Error getting FCM token: $e');
        }
      } else {
        print('⚠️ APNS Token not available after retries');
        print('💡 Token will be retrieved when APNS becomes available');
      }
    } catch (e) {
      print('❌ Error setting up FCM token: $e');
      print('💡 This is normal on iOS simulator or first launch');
    }
  }

  Future<String?> _getAPNSTokenWithRetry({int maxRetries = 5}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          return apnsToken;
        }

        // Attendre avant de réessayer (délai exponentiel avec max 5s)
        if (i < maxRetries - 1) {
          final delaySeconds = (i + 1) * 2;
          final delay = Duration(seconds: delaySeconds > 5 ? 5 : delaySeconds);
          print(
            '⏳ APNS token not available, retrying in ${delay.inSeconds}s (attempt ${i + 1}/$maxRetries)...',
          );
          await Future.delayed(delay);
        }
      } catch (e) {
        print('❌ Error getting APNS token (attempt ${i + 1}/$maxRetries): $e');
        if (i < maxRetries - 1) {
          final delaySeconds = (i + 1) * 2;
          await Future.delayed(
            Duration(seconds: delaySeconds > 5 ? 5 : delaySeconds),
          );
        }
      }
    }
    return null;
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final user = currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM Token saved to Firestore');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // Auth Methods
  Future<UserCredential> signInWithEmail(String email, String password) async {
    print('🔐 FirebaseService.signInWithEmail called');
    print('   Email: $email');
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    print('🔐 FirebaseService.signUpWithEmail called');
    print('   Email: $email');
    print('   Password length: ${password.length}');
    print('   Firebase App initialized: ${Firebase.apps.isNotEmpty}');
    print(
      '   Firebase App name: ${Firebase.apps.isNotEmpty ? Firebase.apps.first.name : "none"}',
    );
    print('   Auth instance: ${auth.app.name}');

    try {
      print('   Calling auth.createUserWithEmailAndPassword...');
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('   ✅ Account created successfully!');
      return result;
    } catch (e) {
      print('   ❌ Error in signUpWithEmail: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  // Firestore Methods
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) async {
    Query query = firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return await query.get();
  }

  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    print('📝 FirebaseService.setDocument called');
    print('   Collection: $collection');
    print('   Document ID: $docId');
    print('   Data keys: ${data.keys.toList()}');
    print('   Merge: $merge');

    try {
      print('   Calling firestore.collection.doc.set...');
      await firestore
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
      print('   ✅ Document saved successfully');
    } catch (e) {
      print('   ❌ Error saving document: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> streamCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    Query query = firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  // Storage Methods
  Future<String> uploadFile(String path, dynamic file) async {
    final ref = storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    final ref = storage.ref().child(path);
    await ref.delete();
  }
}
