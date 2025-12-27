class AppConstants {
  // App Info
  static const String appName = 'DoctoLo';
  static const String appVersion = '1.0.0';

  // API Keys (À remplacer par vos vraies clés)
  static const String agoraAppId = 'YOUR_AGORA_APP_ID';
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Pagination
  static const int pageSize = 20;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration appointmentReminderBefore = Duration(hours: 2);

  // Appointment Durations
  static const Map<String, int> appointmentDurations = {
    'consultation': 30,
    'follow_up': 20,
    'emergency': 60,
    'teleconsultation': 30,
  };

  // Specialties
  static const List<String> medicalSpecialties = [
    'Médecin généraliste',
    'Cardiologue',
    'Dermatologue',
    'Dentiste',
    'Kinésithérapeute',
    'Psychologue',
    'Pédiatre',
    'Gynécologue',
    'Ophtalmologue',
    'ORL',
    'Radiologue',
    'Neurologue',
    'Psychiatre',
    'Nutritionniste',
    'Rhumatologue',
  ];

  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'it', 'name': 'Italiano'},
  ];

  // User Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';
}
