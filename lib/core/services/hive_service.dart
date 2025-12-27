import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/firebase_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/models/doctor_model.dart';
import '../../data/models/appointment_model.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Future<void> initialize() async {
    // Initialize Hive with the app's directory
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DoctorModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AppointmentModelAdapter());
    }

    // Open Boxes
    await openBoxes();
  }

  Future<void> openBoxes() async {
    // TODO: Use typed boxes after running build_runner
    await Future.wait([
      Hive.openBox(FirebaseConstants.userBox),
      Hive.openBox(FirebaseConstants.appointmentsBox),
      Hive.openBox(FirebaseConstants.medicalRecordsBox),
      Hive.openBox(FirebaseConstants.settingsBox),
      Hive.openBox(FirebaseConstants.cacheBox),
    ]);
  }

  // Get Boxes
  // TODO: Use typed boxes after running build_runner
  Box get userBox => Hive.box(FirebaseConstants.userBox);

  Box get appointmentsBox => Hive.box(FirebaseConstants.appointmentsBox);

  Box get medicalRecordsBox => Hive.box(FirebaseConstants.medicalRecordsBox);

  Box get settingsBox => Hive.box(FirebaseConstants.settingsBox);

  Box get cacheBox => Hive.box(FirebaseConstants.cacheBox);

  // User Methods
  Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user', user);
  }

  UserModel? getCurrentUser() {
    final user = userBox.get('current_user');
    return user as UserModel?;
  }

  Future<void> deleteCurrentUser() async {
    await userBox.delete('current_user');
  }

  // Appointment Methods
  Future<void> saveAppointment(AppointmentModel appointment) async {
    await appointmentsBox.put(appointment.id, appointment);
  }

  Future<void> saveAppointments(List<AppointmentModel> appointments) async {
    final map = {for (var a in appointments) a.id: a};
    await appointmentsBox.putAll(map);
  }

  List<AppointmentModel> getAppointments() {
    return appointmentsBox.values.cast<AppointmentModel>().toList();
  }

  AppointmentModel? getAppointment(String id) {
    final appointment = appointmentsBox.get(id);
    return appointment as AppointmentModel?;
  }

  Future<void> deleteAppointment(String id) async {
    await appointmentsBox.delete(id);
  }

  Future<void> clearAppointments() async {
    await appointmentsBox.clear();
  }

  // Settings Methods
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  // Theme
  Future<void> setThemeMode(String mode) async {
    await saveSetting('theme_mode', mode);
  }

  String getThemeMode() {
    return getSetting('theme_mode', defaultValue: 'system');
  }

  // Language
  Future<void> setLanguage(String languageCode) async {
    await saveSetting('language', languageCode);
  }

  String getLanguage() {
    return getSetting('language', defaultValue: 'fr');
  }

  // Cache Methods
  Future<void> cacheData(String key, dynamic data, {Duration? ttl}) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await cacheBox.put(key, cacheEntry);
  }

  dynamic getCachedData(String key) {
    final cacheEntry = cacheBox.get(key);
    if (cacheEntry == null) return null;

    final timestamp = cacheEntry['timestamp'] as int;
    final ttl = cacheEntry['ttl'] as int?;

    if (ttl != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > ttl) {
        cacheBox.delete(key);
        return null;
      }
    }

    return cacheEntry['data'];
  }

  Future<void> clearCache() async {
    await cacheBox.clear();
  }

  // Clear all data
  Future<void> clearAllData() async {
    await Future.wait([
      userBox.clear(),
      appointmentsBox.clear(),
      medicalRecordsBox.clear(),
      cacheBox.clear(),
    ]);
  }

  // Close all boxes
  Future<void> closeBoxes() async {
    await Hive.close();
  }
}
