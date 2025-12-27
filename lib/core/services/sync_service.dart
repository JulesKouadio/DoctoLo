import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'hive_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/appointment_model.dart';
import '../constants/firebase_constants.dart';

/// Service de synchronisation hybride entre Hive (local) et Firebase (cloud)
/// Architecture: Firebase comme source de vérité, Hive comme cache local
class SyncService {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// Initialise les listeners Firebase pour synchronisation temps réel
  void initializeListeners(String userId) {
    // Listener pour les appointments
    _listenToAppointments(userId);

    // Listener pour l'utilisateur
    _listenToUserChanges(userId);
  }

  /// Écoute les changements d'appointments en temps réel
  void _listenToAppointments(String userId) {
    _firebaseService
        .streamCollection(
          FirebaseConstants.appointmentsCollection,
          queryBuilder: (query) => query
              .where('patientId', isEqualTo: userId)
              .orderBy('dateTime', descending: false),
        )
        .listen((snapshot) {
          _syncAppointmentsToLocal(snapshot);
        });
  }

  /// Synchronise les appointments de Firebase vers Hive
  Future<void> _syncAppointmentsToLocal(QuerySnapshot snapshot) async {
    final appointments = snapshot.docs
        .map(
          (doc) => AppointmentModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();

    await _hiveService.saveAppointments(appointments);
    print('✅ Synced ${appointments.length} appointments to local storage');
  }

  /// Écoute les changements de l'utilisateur en temps réel
  void _listenToUserChanges(String userId) {
    _firebaseService
        .streamDocument(FirebaseConstants.usersCollection, userId)
        .listen((snapshot) {
          if (snapshot.exists) {
            final user = UserModel.fromJson({
              ...snapshot.data() as Map<String, dynamic>,
              'id': snapshot.id,
            });
            _hiveService.saveUser(user);
            print('✅ User data synced to local storage');
          }
        });
  }

  /// Synchronisation initiale au démarrage de l'app
  Future<void> initialSync(String userId) async {
    print('🔄 Starting initial sync...');

    try {
      // Sync user data
      await _syncUserData(userId);

      // Sync appointments
      await _syncAppointmentsData(userId);

      print('✅ Initial sync completed successfully');
    } catch (e) {
      print('❌ Initial sync failed: $e');
      throw Exception('Sync failed: $e');
    }
  }

  /// Synchronise les données utilisateur
  Future<void> _syncUserData(String userId) async {
    try {
      final userDoc = await _firebaseService.getDocument(
        FirebaseConstants.usersCollection,
        userId,
      );

      if (userDoc.exists) {
        final user = UserModel.fromJson({
          ...userDoc.data() as Map<String, dynamic>,
          'id': userDoc.id,
        });
        await _hiveService.saveUser(user);
      }
    } catch (e) {
      print('Error syncing user data: $e');
    }
  }

  /// Synchronise les appointments
  Future<void> _syncAppointmentsData(String userId) async {
    try {
      final snapshot = await _firebaseService.getCollection(
        FirebaseConstants.appointmentsCollection,
        queryBuilder: (query) => query
            .where('patientId', isEqualTo: userId)
            .orderBy('dateTime', descending: false)
            .limit(50),
      );

      await _syncAppointmentsToLocal(snapshot);
    } catch (e) {
      print('Error syncing appointments: $e');
    }
  }

  /// Crée un appointment localement puis le synchronise sur Firebase
  Future<AppointmentModel> createAppointment(
    AppointmentModel appointment,
  ) async {
    // 1. Sauvegarder localement d'abord (performance)
    await _hiveService.saveAppointment(appointment);

    // 2. Envoyer vers Firebase (cloud)
    try {
      await _firebaseService.setDocument(
        FirebaseConstants.appointmentsCollection,
        appointment.id,
        appointment.toJson(),
      );
      print('✅ Appointment synced to Firebase');
    } catch (e) {
      print('⚠️ Failed to sync appointment to Firebase: $e');
      // L'appointment reste en local, sera synchronisé plus tard
    }

    return appointment;
  }

  /// Met à jour un appointment localement puis sur Firebase
  Future<void> updateAppointment(
    String appointmentId,
    Map<String, dynamic> updates,
  ) async {
    // 1. Mettre à jour localement
    final appointment = _hiveService.getAppointment(appointmentId);
    if (appointment != null) {
      final updated = appointment.copyWith(
        status: updates['status'] ?? appointment.status,
        notes: updates['notes'] ?? appointment.notes,
        updatedAt: DateTime.now(),
      );
      await _hiveService.saveAppointment(updated);
    }

    // 2. Synchroniser vers Firebase
    try {
      await _firebaseService.updateDocument(
        FirebaseConstants.appointmentsCollection,
        appointmentId,
        {...updates, 'updatedAt': DateTime.now().toIso8601String()},
      );
      print('✅ Appointment update synced to Firebase');
    } catch (e) {
      print('⚠️ Failed to sync update to Firebase: $e');
    }
  }

  /// Supprime un appointment localement puis sur Firebase
  Future<void> deleteAppointment(String appointmentId) async {
    // 1. Supprimer localement
    await _hiveService.deleteAppointment(appointmentId);

    // 2. Supprimer sur Firebase
    try {
      await _firebaseService.deleteDocument(
        FirebaseConstants.appointmentsCollection,
        appointmentId,
      );
      print('✅ Appointment deletion synced to Firebase');
    } catch (e) {
      print('⚠️ Failed to sync deletion to Firebase: $e');
    }
  }

  /// Force la synchronisation manuelle
  Future<void> forceSync(String userId) async {
    await initialSync(userId);
  }

  /// Nettoie les listeners lors de la déconnexion
  void dispose() {
    // Les listeners Firebase sont automatiquement gérés
    print('🔌 Sync service disposed');
  }
}
