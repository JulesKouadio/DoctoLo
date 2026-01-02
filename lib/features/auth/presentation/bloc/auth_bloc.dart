import 'package:DoctoLo/core/services/firebase_service.dart';
import 'package:DoctoLo/core/services/hive_service.dart';
import 'package:DoctoLo/core/services/sync_service.dart';
import 'package:DoctoLo/core/services/settings_service.dart';
import 'package:DoctoLo/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    firstName,
    lastName,
    role,
    phoneNumber,
  ];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();
  final SyncService _syncService = SyncService();
  final SettingsService _settingsService = SettingsService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Vérifier s'il y a un utilisateur Firebase connecté
      final firebaseUser = _firebaseService.currentUser;

      if (firebaseUser != null) {
        // Recharger les infos Firebase pour avoir le statut emailVerified à jour
        await firebaseUser.reload();
        final updatedFirebaseUser = _firebaseService.currentUser;
        final isEmailVerified = updatedFirebaseUser?.emailVerified ?? false;

        // Récupérer les données utilisateur depuis Hive (peut échouer sur web)
        UserModel? user;
        try {
          user = _hiveService.getCurrentUser();
          print('✅ User loaded from Hive cache');
        } catch (hiveError) {
          print('⚠️ Hive not available: $hiveError');
          user = null;
        }

        // Si pas en local, récupérer depuis Firebase
        if (user == null) {
          final userDoc = await _firebaseService.getDocument(
            'users',
            firebaseUser.uid,
          );

          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            user = UserModel.fromJson({
              ...userData,
              'id': userDoc.id,
              'isVerified': isEmailVerified,
            });

            // Si l'email vient d'être vérifié, mettre à jour Firestore
            final currentIsVerified = userData['isVerified'] ?? false;
            if (isEmailVerified && !currentIsVerified) {
              await _firebaseService.updateDocument('users', firebaseUser.uid, {
                'isVerified': true,
              });
              print('✅ Email vérifié! isVerified mis à jour dans Firestore');
            }

            // Essayer de sauvegarder dans Hive (optionnel)
            try {
              await _hiveService.saveUser(user);
              print('✅ User saved to Hive cache');
            } catch (hiveError) {
              print('⚠️ Could not save to Hive: $hiveError');
            }
          }
        } else {
          // L'utilisateur est en cache local, vérifier si le statut a changé
          if (isEmailVerified && !user.isVerified) {
            await _firebaseService.updateDocument('users', firebaseUser.uid, {
              'isVerified': true,
            });

            user = user.copyWith(isVerified: true);

            try {
              await _hiveService.saveUser(user);
              print(
                '✅ Email vérifié! Mis à jour dans Firestore et cache local',
              );
            } catch (hiveError) {
              print('⚠️ Could not update Hive: $hiveError');
            }
          }
        }

        if (user != null) {
          // Charger les paramètres de l'utilisateur
          try {
            await _settingsService.loadUserSettings(user.id);
          } catch (e) {
            print('⚠️ Could not load settings: $e');
          }

          // Initialiser les listeners de synchronisation
          try {
            _syncService.initializeListeners(user.id);
            await _syncService.initialSync(user.id);
          } catch (e) {
            print('⚠️ Could not initialize sync: $e');
          }

          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ AuthCheckRequested error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔷 AuthBloc: _onSignInRequested started');
    emit(AuthLoading());

    try {
      // ÉTAPE 1: Connexion Firebase
      print('🔐 Step 1: Signing in to Firebase Auth...');
      final userCredential = await _firebaseService.signInWithEmail(
        event.email,
        event.password,
      );
      print('✅ Firebase Auth sign in successful');
      print('   UID: ${userCredential.user!.uid}');

      // ÉTAPE 2: Vérifier si l'email a été vérifié dans Firebase Auth
      print('📧 Step 2: Checking email verification status...');
      await userCredential.user!.reload();
      final updatedFirebaseUser = _firebaseService.currentUser;
      final isEmailVerified = updatedFirebaseUser?.emailVerified ?? false;
      print('   Email verified: $isEmailVerified');

      // ÉTAPE 3: Récupérer les données utilisateur depuis Firestore
      print('📥 Step 3: Fetching user data from Firestore...');
      final userDoc = await _firebaseService.getDocument(
        'users',
        userCredential.user!.uid,
      );

      if (!userDoc.exists) {
        print('❌ User document not found in Firestore!');
        throw Exception(
          'Les données utilisateur sont introuvables. Veuillez réessayer.',
        );
      }

      print('✅ User document found in Firestore');
      final userData = userDoc.data() as Map<String, dynamic>;
      print('   User data: $userData');

      final currentIsVerified = userData['isVerified'] ?? false;

      // ÉTAPE 4: Créer l'objet user avec le statut de vérification à jour
      print('👤 Step 4: Creating user model...');
      final user = UserModel.fromJson({
        ...userData,
        'id': userDoc.id,
        'isVerified': isEmailVerified,
      });
      print('✅ User model created');
      print('   User ID: ${user.id}');
      print('   Email: ${user.email}');
      print('   Role: ${user.role}');
      print('   Name: ${user.firstName} ${user.lastName}');

      // ÉTAPE 5: Mettre à jour Firestore si nécessaire
      print('💾 Step 5: Updating Firestore...');
      if (isEmailVerified && !currentIsVerified) {
        await _firebaseService.updateDocument('users', user.id, {
          'isVerified': true,
          'lastLogin': DateTime.now().toIso8601String(),
        });
        print('✅ Email verified! isVerified updated in Firestore');
      } else {
        await _firebaseService.updateDocument('users', user.id, {
          'lastLogin': DateTime.now().toIso8601String(),
        });
        print('✅ Last login updated in Firestore');
      }

      // ÉTAPE 6: Sauvegarder en local (optionnel, peut échouer sur web)
      print('📱 Step 6: Saving user to local storage (Hive)...');
      try {
        await _hiveService.saveUser(user);
        print('✅ User saved to Hive');
      } catch (hiveError) {
        print('⚠️ Hive save failed (non-critical): $hiveError');
        print('   User will still be authenticated using Firebase data');
      }

      // ÉTAPE 7: Charger les paramètres de l'utilisateur
      print('⚙️ Step 7: Loading user settings...');
      try {
        await _settingsService.loadUserSettings(user.id);
        print('✅ User settings loaded');
      } catch (settingsError) {
        print('⚠️ Settings load failed (non-critical): $settingsError');
      }

      // ÉTAPE 8: Initialiser la synchronisation
      print('🔄 Step 8: Initializing sync...');
      try {
        _syncService.initializeListeners(user.id);
        await _syncService.initialSync(user.id);
        print('✅ Sync initialized');
      } catch (syncError) {
        print('⚠️ Sync initialization failed (non-critical): $syncError');
      }

      print('🎉 Sign in completed successfully!');
      print('   Emitting AuthAuthenticated state...');
      emit(AuthAuthenticated(user: user));
      print('✅ AuthAuthenticated state emitted');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException during sign in:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');

      String message = 'Une erreur est survenue';

      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          message = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'invalid-credential':
          message = 'Email ou mot de passe incorrect';
          break;
        case 'user-disabled':
          message = 'Ce compte a été désactivé';
          break;
        case 'too-many-requests':
          message = 'Trop de tentatives. Veuillez réessayer plus tard';
          break;
        default:
          message = e.message ?? 'Erreur de connexion';
      }

      emit(AuthError(message: message));
    } catch (e, stackTrace) {
      print('❌ Generic error during sign in:');
      print('   Type: ${e.runtimeType}');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');

      emit(AuthError(message: 'Erreur de connexion: ${e.toString()}'));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔷 AuthBloc: _onSignUpRequested started');
    print('   Email: ${event.email}');
    print('   Role: ${event.role}');

    emit(AuthLoading());

    try {
      // ÉTAPE 1: Créer le compte Firebase Auth
      print('📧 Step 1: Creating Firebase Auth account...');
      final userCredential = await _firebaseService.signUpWithEmail(
        event.email,
        event.password,
      );
      print('✅ Firebase Auth account created successfully!');
      print('   UID: ${userCredential.user!.uid}');
      print('   Email: ${userCredential.user!.email}');

      // ÉTAPE 2: Créer le modèle utilisateur
      print('👤 Step 2: Creating user profile...');
      final user = UserModel(
        id: userCredential.user!.uid,
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        role: event.role,
        createdAt: DateTime.now(),
        isVerified: false,
      );
      print('✅ User model created');

      // ÉTAPE 3: Sauvegarder le profil dans Firestore
      print('💾 Step 3: Saving user profile to Firestore...');
      try {
        await _firebaseService
            .setDocument('users', user.id, user.toJson())
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Firestore timeout après 10 secondes');
              },
            );
        print('✅ User profile saved to Firestore successfully');
      } catch (firestoreError) {
        print('⚠️ Firestore save failed: $firestoreError');
      }

      // ÉTAPE 4: Sauvegarder en local avec Hive (optionnel)
      print('📱 Step 4: Saving user profile to local storage (Hive)...');
      try {
        await _hiveService.saveUser(user);
        print('✅ User profile saved to Hive successfully');
      } catch (hiveError) {
        print('⚠️ Hive save failed (non-critical): $hiveError');
      }

      // ÉTAPE 5: Initialiser la synchronisation
      print('🔄 Step 5: Initializing sync listeners...');
      try {
        _syncService.initializeListeners(user.id);
        print('✅ Sync listeners initialized');
      } catch (syncError) {
        print('⚠️ Sync initialization failed (non-critical): $syncError');
      }

      print('🎉 Registration completed successfully!');
      print('   Emitting AuthAuthenticated state...');
      emit(AuthAuthenticated(user: user));
      print('✅ AuthAuthenticated state emitted');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException during registration:');
      print('   Code: ${e.code}');
      print('   Message: ${e.message}');

      String message = 'Une erreur est survenue';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Cet email est déjà utilisé';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        case 'weak-password':
          message = 'Le mot de passe est trop faible';
          break;
        case 'internal-error':
          message =
              'Erreur interne Firebase: ${e.message ?? "Configuration incorrecte"}';
          break;
        default:
          message = e.message ?? 'Erreur d\'inscription';
      }

      emit(AuthError(message: message));
    } catch (e, stackTrace) {
      print('❌ Generic error during registration:');
      print('   Type: ${e.runtimeType}');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');

      emit(AuthError(message: 'Erreur d\'inscription: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _firebaseService.signOut();

      // Essayer de supprimer les données Hive (peut échouer sur web)
      try {
        await _hiveService.deleteCurrentUser();
      } catch (e) {
        print('⚠️ Could not delete Hive data: $e');
      }

      _syncService.dispose();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Erreur de déconnexion: ${e.toString()}'));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _firebaseService.resetPassword(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } on FirebaseAuthException catch (e) {
      String message = 'Une erreur est survenue';

      switch (e.code) {
        case 'user-not-found':
          message = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'invalid-email':
          message = 'Email invalide';
          break;
        default:
          message = e.message ?? 'Erreur de réinitialisation';
      }

      emit(AuthError(message: message));
    } catch (e) {
      emit(AuthError(message: 'Erreur: ${e.toString()}'));
    }
  }
}
