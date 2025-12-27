import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': _frenchStrings,
    'en': _englishStrings,
    'es': _spanishStrings,
    'ar': _arabicStrings,
    'de': _germanStrings,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters pour accès facile
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get hello => translate('hello');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get firstName => translate('first_name');
  String get lastName => translate('last_name');
  String get phoneNumber => translate('phone_number');
  String get logout => translate('logout');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get accountSettings => translate('account_settings');
  String get language => translate('language');
  String get currency => translate('currency');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get home => translate('home');
  String get appointments => translate('appointments');
  String get messages => translate('messages');
  String get medicalRecords => translate('medical_records');
  String get search => translate('search');
  String get searchProfessional => translate('search_professional');
  String get doctor => translate('doctor');
  String get patient => translate('patient');
  String get consultation => translate('consultation');
  String get telemedicine => translate('telemedicine');
  String get physicalConsultation => translate('physical_consultation');
  String get followUp => translate('follow_up');
  String get user => translate('user');
  String get myAppointments => translate('my_appointments');
  String get myConsultations => translate('my_consultations');
  String get all => translate('all');
  String get pending => translate('pending');
  String get confirmed => translate('confirmed');
  String get completed => translate('completed');
  String get cancelled => translate('cancelled');
  String get availability => translate('availability');
  String get schedule => translate('schedule');
  String get rate => translate('rate');
  String get duration => translate('duration');
  String get minutes => translate('minutes');
  String get consultationFee => translate('consultation_fee');
  String get teleconsultationFee => translate('teleconsultation_fee');
  String get consultationDuration => translate('consultation_duration');
  String get personalInfo => translate('personal_info');
  String get notifications => translate('notifications');
  String get privacy => translate('privacy');
  String get professionalExperience => translate('professional_experience');
  String get documents => translate('documents');
  String get offersPhysicalConsultation =>
      translate('offers_physical_consultation');
  String get offersTelemedicine => translate('offers_telemedicine');
  String get acceptsNewPatients => translate('accepts_new_patients');
  String get myAvailability => translate('my_availability');
  String get addTimeSlot => translate('add_time_slot');
  String get from => translate('from');
  String get to => translate('to');
  String get monday => translate('monday');
  String get tuesday => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday => translate('thursday');
  String get friday => translate('friday');
  String get saturday => translate('saturday');
  String get sunday => translate('sunday');
  String get selectLanguage => translate('select_language');
  String get selectCurrency => translate('select_currency');
  String get example => translate('example');
  String get settingsAppliedEverywhere =>
      translate('settings_applied_everywhere');
  String get saving => translate('saving');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get settingsSaved => translate('settings_saved');
  String get emailVerification => translate('email_verification');
  String get verifyYourEmail => translate('verify_your_email');
  String get createAccount => translate('create_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get dontHaveAccount => translate('dont_have_account');
  String get forgotPassword => translate('forgot_password');
  String get iAmA => translate('i_am_a');
  String get acceptTerms => translate('accept_terms');

  // Actions
  String get confirm => translate('confirm');
  String get delete => translate('delete');
  String get back => translate('back');
  String get next => translate('next');
  String get finish => translate('finish');
  String get close => translate('close');
  String get continue_ => translate('continue');

  // Menu & Navigation
  String get dashboard => translate('dashboard');
  String get agenda => translate('agenda');
  String get patients => translate('patients');
  String get secureMessaging => translate('secure_messaging');
  String get patientsList => translate('patients_list');

  // Consultation
  String get consultationTypes => translate('consultation_types');
  String get consultationAtOffice => translate('consultation_at_office');
  String get consultationByVideo => translate('consultation_by_video');
  String get joinCall => translate('join_call');
  String get startConsultation => translate('start_consultation');

  // Rendez-vous
  String get bookAppointment => translate('book_appointment');
  String get appointmentDetails => translate('appointment_details');
  String get selectDate => translate('select_date');
  String get selectTime => translate('select_time');
  String get confirmAppointment => translate('confirm_appointment');
  String get cancelAppointment => translate('cancel_appointment');
  String get rescheduleAppointment => translate('reschedule_appointment');
  String get appointmentConfirmed => translate('appointment_confirmed');
  String get appointmentCancelled => translate('appointment_cancelled');
  String get areYouSureCancel => translate('are_you_sure_cancel');
  String get areYouSureConfirm => translate('are_you_sure_confirm');

  // Profil médecin
  String get myProfile => translate('my_profile');
  String get editProfile => translate('edit_profile');
  String get professionalInfo => translate('professional_info');
  String get cvAndDiplomas => translate('cv_and_diplomas');
  String get manageDocuments => translate('manage_documents');
  String get specialties => translate('specialties');
  String get location => translate('location');
  String get languages => translate('languages');
  String get education => translate('education');
  String get certifications => translate('certifications');
  String get yearsExperience => translate('years_experience');
  String get years => translate('years');

  // Paramètres consultation
  String get defineWorkHours => translate('define_work_hours');
  String get pricesAndDuration => translate('prices_and_duration');
  String get acceptNewPatients => translate('accept_new_patients');
  String get youMustOfferAtLeastOne => translate('you_must_offer_at_least_one');

  // Messages & Erreurs
  String get savedSuccessfully => translate('saved_successfully');
  String get errorOccurred => translate('error_occurred');
  String get availabilitySaved => translate('availability_saved');
  String get settingsSavedSuccess => translate('settings_saved_success');
  String get loadingData => translate('loading_data');
  String get noDataAvailable => translate('no_data_available');
  String get noAppointments => translate('no_appointments');
  String get noPendingAppointments => translate('no_pending_appointments');
  String get noConfirmedAppointments => translate('no_confirmed_appointments');
  String get noCompletedAppointments => translate('no_completed_appointments');

  // Jours de la semaine (abrégés)
  String get mon => translate('mon');
  String get tue => translate('tue');
  String get wed => translate('wed');
  String get thu => translate('thu');
  String get fri => translate('fri');
  String get sat => translate('sat');
  String get sun => translate('sun');

  // Documents
  String get cv => translate('cv');
  String get diploma => translate('diploma');
  String get certification => translate('certification');
  String get other => translate('other');
  String get documentType => translate('document_type');
  String get addDocument => translate('add_document');
  String get deleteDocument => translate('delete_document');
  String get areYouSureDeleteDocument =>
      translate('are_you_sure_delete_document');
  String get documentAdded => translate('document_added');
  String get documentDeleted => translate('document_deleted');

  // Sections supplémentaires
  String get professionalSettings => translate('professional_settings');
  String get myAccount => translate('my_account');
  String get studiesExperienceCertifications =>
      translate('studies_experience_certifications');
  String get physicalTeleconsultationPrices =>
      translate('physical_teleconsultation_prices');

  // Dashboard
  String get todaysAppointments => translate('todays_appointments');
  String get viewAgenda => translate('view_agenda');
  String get newPatient => translate('new_patient');
  String get waiting => translate('waiting');
  String get revenue => translate('revenue');
  String get today => translate('today');
  String get recentPatients => translate('recent_patients');
  String get viewAll => translate('view_all');
  String get lastVisit => translate('last_visit');
  String get nextAppointment => translate('next_appointment');

  // Agenda
  String get myAgenda => translate('my_agenda');
  String get noAppointmentsForDate => translate('no_appointments_for_date');
  String get month => translate('month');
  String get twoWeeks => translate('two_weeks');
  String get week => translate('week');
  String get refresh => translate('refresh');
  String get format => translate('format');
  String get localeCode => translate('locale_code');

  // Recherche
  String get searchDoctor => translate('search_doctor');
  String get searchBySpecialty => translate('search_by_specialty');
  String get searchByName => translate('search_by_name');
  String get filter => translate('filter');
  String get sortBy => translate('sort_by');
  String get nearMe => translate('near_me');
  String get viewProfile => translate('view_profile');
  String get reviews => translate('reviews');
  String get rating => translate('rating');
  String get price => translate('price');

  // Authentification
  String get welcomeBack => translate('welcome_back');
  String get welcomeToDoctolo => translate('welcome_to_doctolo');
  String get loginToContinue => translate('login_to_continue');
  String get joinDoctolo => translate('join_doctolo');
  String get rememberMe => translate('remember_me');

  // Email Verification
  String get emailVerificationSent => translate('email_verification_sent');
  String get checkYourEmail => translate('check_your_email');
  String get clickLinkToVerify => translate('click_link_to_verify');
  String get resendEmail => translate('resend_email');
  String get verifyNow => translate('verify_now');
  String get emailVerifiedSuccess => translate('email_verified_success');
  String get checkingVerification => translate('checking_verification');
  String get autoCheckingEnabled => translate('auto_checking_enabled');
}

// Français
final Map<String, String> _frenchStrings = {
  'app_name': 'Doctolo',
  'welcome': 'Bienvenue',
  'hello': 'Bonjour',
  'login': 'Connexion',
  'register': 'Inscription',
  'email': 'Email',
  'password': 'Mot de passe',
  'confirm_password': 'Confirmer le mot de passe',
  'first_name': 'Prénom',
  'last_name': 'Nom',
  'phone_number': 'Téléphone',
  'logout': 'Déconnexion',
  'profile': 'Profil',
  'settings': 'Paramètres',
  'account_settings': 'Paramètres du compte',
  'language': 'Langue',
  'currency': 'Devise',
  'save': 'Enregistrer',
  'cancel': 'Annuler',
  'home': 'Accueil',
  'appointments': 'Rendez-vous',
  'messages': 'Messages',
  'medical_records': 'Dossier médical',
  'search': 'Rechercher',
  'search_professional': 'Rechercher un professionnel',
  'doctor': 'Médecin',
  'patient': 'Patient',
  'consultation': 'Consultation',
  'telemedicine': 'Téléconsultation',
  'physical_consultation': 'Consultation physique',
  'follow_up': 'Suivi',
  'user': 'Utilisateur',
  'my_appointments': 'Mes rendez-vous',
  'my_consultations': 'Mes consultations',
  'all': 'Tous',
  'pending': 'En attente',
  'confirmed': 'Confirmés',
  'completed': 'Terminés',
  'cancelled': 'Annulés',
  'availability': 'Disponibilités',
  'schedule': 'Agenda',
  'rate': 'Tarif',
  'duration': 'Durée',
  'minutes': 'minutes',
  'consultation_fee': 'Tarif consultation physique',
  'teleconsultation_fee': 'Tarif téléconsultation',
  'consultation_duration': 'Durée d\'une consultation',
  'personal_info': 'Informations personnelles',
  'notifications': 'Notifications',
  'privacy': 'Confidentialité',
  'professional_experience': 'Expérience professionnelle',
  'documents': 'Documents',
  'offers_physical_consultation': 'Propose des consultations physiques',
  'offers_telemedicine': 'Propose la téléconsultation',
  'accepts_new_patients': 'Accepte de nouveaux patients',
  'my_availability': 'Mes disponibilités',
  'add_time_slot': 'Ajouter un créneau',
  'from': 'De',
  'to': 'À',
  'monday': 'Lundi',
  'tuesday': 'Mardi',
  'wednesday': 'Mercredi',
  'thursday': 'Jeudi',
  'friday': 'Vendredi',
  'saturday': 'Samedi',
  'sunday': 'Dimanche',
  'select_language': 'Choisissez la langue d\'affichage',
  'select_currency': 'Choisissez votre devise pour les tarifs',
  'example': 'Exemple',
  'settings_applied_everywhere':
      'Ces paramètres s\'appliquent à toute l\'application et sont synchronisés sur tous vos appareils.',
  'saving': 'Enregistrement...',
  'loading': 'Chargement...',
  'error': 'Erreur',
  'success': 'Succès',
  'settings_saved': 'Paramètres enregistrés',
  'email_verification': 'Vérification de l\'email',
  'verify_your_email': 'Vérifiez votre email',
  'create_account': 'Créer un compte',
  'already_have_account': 'Vous avez déjà un compte ?',
  'dont_have_account': 'Vous n\'avez pas de compte ?',
  'forgot_password': 'Mot de passe oublié ?',
  'i_am_a': 'Je suis un(e):',
  'accept_terms': 'J\'accepte les conditions d\'utilisation',

  // Actions
  'confirm': 'Confirmer',
  'delete': 'Supprimer',
  'back': 'Retour',
  'next': 'Suivant',
  'finish': 'Terminer',
  'close': 'Fermer',
  'continue': 'Continuer',

  // Menu & Navigation
  'dashboard': 'Tableau de bord',
  'agenda': 'Agenda',
  'patients': 'Patients',
  'secure_messaging': 'Messagerie sécurisée',
  'patients_list': 'Liste des patients',

  // Consultation
  'consultation_types': 'Types de consultation',
  'consultation_at_office': 'Consultation au cabinet',
  'consultation_by_video': 'Consultation par vidéo',
  'join_call': 'Rejoindre',
  'start_consultation': 'Démarrer la consultation',

  // Rendez-vous
  'book_appointment': 'Réserver un rendez-vous',
  'appointment_details': 'Détails du rendez-vous',
  'select_date': 'Sélectionner une date',
  'select_time': 'Sélectionner l\'heure',
  'confirm_appointment': 'Confirmer le rendez-vous',
  'cancel_appointment': 'Annuler le rendez-vous',
  'reschedule_appointment': 'Reprogrammer',
  'appointment_confirmed': 'Rendez-vous confirmé',
  'appointment_cancelled': 'Rendez-vous annulé',
  'are_you_sure_cancel': 'Êtes-vous sûr de vouloir annuler ce rendez-vous ?',
  'are_you_sure_confirm': 'Voulez-vous confirmer ce rendez-vous ?',

  // Profil médecin
  'my_profile': 'Mon profil',
  'edit_profile': 'Modifier le profil',
  'professional_info': 'Informations professionnelles',
  'cv_and_diplomas': 'CV et diplômes',
  'manage_documents': 'Gérer mes documents',
  'specialties': 'Spécialités',
  'location': 'Localisation',
  'languages': 'Langues',
  'education': 'Formation',
  'certifications': 'Certifications',
  'years_experience': 'ans d\'expérience',
  'years': 'ans',

  // Paramètres consultation
  'define_work_hours': 'Définir mes horaires de travail',
  'prices_and_duration': 'Tarifs et durée',
  'accept_new_patients': 'Accepter de nouveaux patients',
  'you_must_offer_at_least_one':
      'Vous devez proposer au moins un type de consultation',

  // Messages & Erreurs
  'saved_successfully': 'Enregistré avec succès',
  'error_occurred': 'Une erreur est survenue',
  'availability_saved': 'Disponibilités enregistrées',
  'settings_saved_success': 'Paramètres enregistrés avec succès',
  'loading_data': 'Chargement des données...',
  'no_data_available': 'Aucune donnée disponible',
  'no_appointments': 'Aucun rendez-vous',
  'no_pending_appointments': 'Aucun rendez-vous en attente',
  'no_confirmed_appointments': 'Aucun rendez-vous confirmé',
  'no_completed_appointments': 'Aucun rendez-vous terminé',

  // Jours de la semaine (abrégés)
  'mon': 'Lun',
  'tue': 'Mar',
  'wed': 'Mer',
  'thu': 'Jeu',
  'fri': 'Ven',
  'sat': 'Sam',
  'sun': 'Dim',

  // Documents
  'cv': 'CV',
  'diploma': 'Diplôme',
  'certification': 'Certification',
  'other': 'Autre',
  'document_type': 'Type de document',
  'add_document': 'Ajouter un document',
  'delete_document': 'Supprimer le document',
  'are_you_sure_delete_document':
      'Êtes-vous sûr de vouloir supprimer ce document ?',
  'document_added': 'Document ajouté',
  'document_deleted': 'Document supprimé',

  // Sections supplémentaires
  'professional_settings': 'Paramètres professionnels',
  'my_account': 'Mon compte',
  'studies_experience_certifications': 'Études, expériences, certifications',
  'physical_teleconsultation_prices': 'Physique, téléconsultation, tarifs',

  // Dashboard
  'todays_appointments': 'Rendez-vous du jour',
  'view_agenda': 'Voir l\'agenda',
  'new_patient': 'Nouveau patient',
  'waiting': 'En attente',
  'revenue': 'Revenus',
  'today': 'Aujourd...',
  'recent_patients': 'Patients récents',
  'view_all': 'Voir tous',
  'last_visit': 'Dernière visite',
  'next_appointment': 'Prochain RDV',

  // Agenda
  'my_agenda': 'Mon Agenda',
  'no_appointments_for_date': 'Aucun rendez-vous',
  'month': 'Mois',
  'two_weeks': '2 Semaines',
  'week': 'Semaine',
  'refresh': 'Actualiser',
  'format': 'Format',
  'locale_code': 'fr_FR',

  // Recherche
  'search_doctor': 'Rechercher un médecin',
  'search_by_specialty': 'Rechercher par spécialité',
  'search_by_name': 'Rechercher par nom',
  'filter': 'Filtrer',
  'sort_by': 'Trier par',
  'near_me': 'Près de moi',
  'view_profile': 'Voir le profil',
  'reviews': 'Avis',
  'rating': 'Note',
  'price': 'Prix',

  // Authentification
  'welcome_back': 'Bienvenue',
  'welcome_to_doctolo': 'Bienvenue sur DoctoLo',
  'login_to_continue': 'Connectez-vous pour continuer',
  'join_doctolo': 'Rejoignez Doctolo dès aujourd\'hui',
  'remember_me': 'Se souvenir de moi',

  // Email Verification
  'email_verification_sent': 'Email de vérification envoyé',
  'check_your_email': 'Vérifiez votre boîte mail',
  'click_link_to_verify': 'Cliquez sur le lien pour vérifier',
  'resend_email': 'Renvoyer l\'email',
  'verify_now': 'Vérifier maintenant',
  'email_verified_success': 'Email vérifié avec succès',
  'checking_verification': 'Vérification en cours...',
  'auto_checking_enabled': 'Vérification automatique active',
};

// English
final Map<String, String> _englishStrings = {
  'app_name': 'Doctolo',
  'welcome': 'Welcome',
  'hello': 'Hello',
  'login': 'Login',
  'register': 'Register',
  'email': 'Email',
  'password': 'Password',
  'confirm_password': 'Confirm Password',
  'first_name': 'First Name',
  'last_name': 'Last Name',
  'phone_number': 'Phone Number',
  'logout': 'Logout',
  'profile': 'Profile',
  'settings': 'Settings',
  'account_settings': 'Account Settings',
  'language': 'Language',
  'currency': 'Currency',
  'save': 'Save',
  'cancel': 'Cancel',
  'home': 'Home',
  'appointments': 'Appointments',
  'messages': 'Messages',
  'medical_records': 'Medical Records',
  'search': 'Search',
  'search_professional': 'Search Professional',
  'doctor': 'Doctor',
  'patient': 'Patient',
  'consultation': 'Consultation',
  'telemedicine': 'Telemedicine',
  'physical_consultation': 'Physical Consultation',
  'follow_up': 'Follow-up',
  'user': 'User',
  'my_appointments': 'My Appointments',
  'my_consultations': 'My Consultations',
  'all': 'All',
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
  'availability': 'Availability',
  'schedule': 'Schedule',
  'rate': 'Rate',
  'duration': 'Duration',
  'minutes': 'minutes',
  'consultation_fee': 'Physical Consultation Fee',
  'teleconsultation_fee': 'Telemedicine Fee',
  'consultation_duration': 'Consultation Duration',
  'personal_info': 'Personal Information',
  'notifications': 'Notifications',
  'privacy': 'Privacy',
  'professional_experience': 'Professional Experience',
  'documents': 'Documents',
  'offers_physical_consultation': 'Offers Physical Consultations',
  'offers_telemedicine': 'Offers Telemedicine',
  'accepts_new_patients': 'Accepts New Patients',
  'my_availability': 'My Availability',
  'add_time_slot': 'Add Time Slot',
  'from': 'From',
  'to': 'To',
  'monday': 'Monday',
  'tuesday': 'Tuesday',
  'wednesday': 'Wednesday',
  'thursday': 'Thursday',
  'friday': 'Friday',
  'saturday': 'Saturday',
  'sunday': 'Sunday',
  'select_language': 'Choose display language',
  'select_currency': 'Choose your currency for rates',
  'example': 'Example',
  'settings_applied_everywhere':
      'These settings apply to the entire app and are synced across all your devices.',
  'saving': 'Saving...',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'settings_saved': 'Settings Saved',
  'email_verification': 'Email Verification',
  'verify_your_email': 'Verify Your Email',
  'create_account': 'Create Account',
  'already_have_account': 'Already have an account?',
  'dont_have_account': 'Don\'t have an account?',
  'forgot_password': 'Forgot Password?',
  'i_am_a': 'I am a:',
  'accept_terms': 'I accept the terms of service',

  // Actions
  'confirm': 'Confirm',
  'delete': 'Delete',
  'back': 'Back',
  'next': 'Next',
  'finish': 'Finish',
  'close': 'Close',
  'continue': 'Continue',

  // Menu & Navigation
  'dashboard': 'Dashboard',
  'agenda': 'Schedule',
  'patients': 'Patients',
  'secure_messaging': 'Secure Messaging',
  'patients_list': 'Patients List',

  // Consultation
  'consultation_types': 'Consultation Types',
  'consultation_at_office': 'Office Consultation',
  'consultation_by_video': 'Video Consultation',
  'join_call': 'Join',
  'start_consultation': 'Start Consultation',

  // Rendez-vous
  'book_appointment': 'Book Appointment',
  'appointment_details': 'Appointment Details',
  'select_date': 'Select Date',
  'select_time': 'Select Time',
  'confirm_appointment': 'Confirm Appointment',
  'cancel_appointment': 'Cancel Appointment',
  'reschedule_appointment': 'Reschedule',
  'appointment_confirmed': 'Appointment Confirmed',
  'appointment_cancelled': 'Appointment Cancelled',
  'are_you_sure_cancel': 'Are you sure you want to cancel this appointment?',
  'are_you_sure_confirm': 'Do you want to confirm this appointment?',

  // Profil médecin
  'my_profile': 'My Profile',
  'edit_profile': 'Edit Profile',
  'professional_info': 'Professional Information',
  'cv_and_diplomas': 'CV and Diplomas',
  'manage_documents': 'Manage Documents',
  'specialties': 'Specialties',
  'location': 'Location',
  'languages': 'Languages',
  'education': 'Education',
  'certifications': 'Certifications',
  'years_experience': 'years of experience',
  'years': 'years',

  // Paramètres consultation
  'define_work_hours': 'Define work hours',
  'prices_and_duration': 'Prices and duration',
  'accept_new_patients': 'Accept new patients',
  'you_must_offer_at_least_one':
      'You must offer at least one consultation type',

  // Messages & Erreurs
  'saved_successfully': 'Saved successfully',
  'error_occurred': 'An error occurred',
  'availability_saved': 'Availability saved',
  'settings_saved_success': 'Settings saved successfully',
  'loading_data': 'Loading data...',
  'no_data_available': 'No data available',
  'no_appointments': 'No appointments',
  'no_pending_appointments': 'No pending appointments',
  'no_confirmed_appointments': 'No confirmed appointments',
  'no_completed_appointments': 'No completed appointments',

  // Jours de la semaine (abrégés)
  'mon': 'Mon',
  'tue': 'Tue',
  'wed': 'Wed',
  'thu': 'Thu',
  'fri': 'Fri',
  'sat': 'Sat',
  'sun': 'Sun',

  // Documents
  'cv': 'CV',
  'diploma': 'Diploma',
  'certification': 'Certification',
  'other': 'Other',
  'document_type': 'Document Type',
  'add_document': 'Add Document',
  'delete_document': 'Delete Document',
  'are_you_sure_delete_document':
      'Are you sure you want to delete this document?',
  'document_added': 'Document added',
  'document_deleted': 'Document deleted',

  // Sections supplémentaires
  'professional_settings': 'Professional Settings',
  'my_account': 'My Account',
  'studies_experience_certifications': 'Studies, experience, certifications',
  'physical_teleconsultation_prices': 'Physical, telemedicine, prices',

  // Dashboard
  'todays_appointments': 'Today\'s appointments',
  'view_agenda': 'View agenda',
  'new_patient': 'New patient',
  'waiting': 'Waiting',
  'revenue': 'Revenue',
  'today': 'Today',
  'recent_patients': 'Recent patients',
  'view_all': 'View all',
  'last_visit': 'Last visit',
  'next_appointment': 'Next appointment',

  // Agenda
  'my_agenda': 'My Agenda',
  'no_appointments_for_date': 'No appointments',
  'month': 'Month',
  'two_weeks': '2 Weeks',
  'week': 'Week',
  'refresh': 'Refresh',
  'format': 'Format',
  'locale_code': 'en_US',

  // Recherche
  'search_doctor': 'Search Doctor',
  'search_by_specialty': 'Search by specialty',
  'search_by_name': 'Search by name',
  'filter': 'Filter',
  'sort_by': 'Sort by',
  'near_me': 'Near me',
  'view_profile': 'View Profile',
  'reviews': 'Reviews',
  'rating': 'Rating',
  'price': 'Price',

  // Authentification
  'welcome_back': 'Welcome back',
  'welcome_to_doctolo': 'Welcome to DoctoLo',
  'login_to_continue': 'Login to continue',
  'join_doctolo': 'Join Doctolo today',
  'remember_me': 'Remember me',

  // Email Verification
  'email_verification_sent': 'Verification email sent',
  'check_your_email': 'Check your email',
  'click_link_to_verify': 'Click the link to verify',
  'resend_email': 'Resend email',
  'verify_now': 'Verify now',
  'email_verified_success': 'Email verified successfully',
  'checking_verification': 'Checking verification...',
  'auto_checking_enabled': 'Auto-checking enabled',
};

// Español
final Map<String, String> _spanishStrings = {
  'app_name': 'Doctolo',
  'welcome': 'Bienvenido',
  'hello': 'Hola',
  'login': 'Iniciar sesión',
  'register': 'Registrarse',
  'email': 'Correo electrónico',
  'password': 'Contraseña',
  'confirm_password': 'Confirmar contraseña',
  'first_name': 'Nombre',
  'last_name': 'Apellido',
  'phone_number': 'Teléfono',
  'logout': 'Cerrar sesión',
  'profile': 'Perfil',
  'settings': 'Configuración',
  'account_settings': 'Configuración de cuenta',
  'language': 'Idioma',
  'currency': 'Moneda',
  'save': 'Guardar',
  'cancel': 'Cancelar',
  'home': 'Inicio',
  'appointments': 'Citas',
  'messages': 'Mensajes',
  'medical_records': 'Expediente médico',
  'search': 'Buscar',
  'search_professional': 'Buscar profesional',
  'doctor': 'Médico',
  'patient': 'Paciente',
  'consultation': 'Consulta',
  'telemedicine': 'Telemedicina',
  'physical_consultation': 'Consulta física',
  'follow_up': 'Seguimiento',
  'user': 'Usuario',
  'my_appointments': 'Mis citas',
  'my_consultations': 'Mis consultas',
  'all': 'Todos',
  'pending': 'Pendientes',
  'confirmed': 'Confirmados',
  'completed': 'Completados',
  'cancelled': 'Cancelados',
  'availability': 'Disponibilidad',
  'schedule': 'Agenda',
  'rate': 'Tarifa',
  'duration': 'Duración',
  'minutes': 'minutos',
  'consultation_fee': 'Tarifa consulta física',
  'teleconsultation_fee': 'Tarifa telemedicina',
  'consultation_duration': 'Duración de consulta',
  'personal_info': 'Información personal',
  'notifications': 'Notificaciones',
  'privacy': 'Privacidad',
  'professional_experience': 'Experiencia profesional',
  'documents': 'Documentos',
  'offers_physical_consultation': 'Ofrece consultas físicas',
  'offers_telemedicine': 'Ofrece telemedicina',
  'accepts_new_patients': 'Acepta nuevos pacientes',
  'my_availability': 'Mi disponibilidad',
  'add_time_slot': 'Agregar horario',
  'from': 'De',
  'to': 'A',
  'monday': 'Lunes',
  'tuesday': 'Martes',
  'wednesday': 'Miércoles',
  'thursday': 'Jueves',
  'friday': 'Viernes',
  'saturday': 'Sábado',
  'sunday': 'Domingo',
  'select_language': 'Elige el idioma de visualización',
  'select_currency': 'Elige tu moneda para las tarifas',
  'example': 'Ejemplo',
  'settings_applied_everywhere':
      'Esta configuración se aplica a toda la aplicación y se sincroniza en todos tus dispositivos.',
  'saving': 'Guardando...',
  'loading': 'Cargando...',
  'error': 'Error',
  'success': 'Éxito',
  'settings_saved': 'Configuración guardada',
  'email_verification': 'Verificación de correo',
  'verify_your_email': 'Verifica tu correo',
  'create_account': 'Crear cuenta',
  'already_have_account': '¿Ya tienes cuenta?',
  'dont_have_account': '¿No tienes cuenta?',
  'forgot_password': '¿Olvidaste tu contraseña?',
  'i_am_a': 'Soy un(a):',
  'accept_terms': 'Acepto los términos de servicio',

  // Actions
  'confirm': 'Confirmar',
  'delete': 'Eliminar',
  'back': 'Volver',
  'next': 'Siguiente',
  'finish': 'Finalizar',
  'close': 'Cerrar',
  'continue': 'Continuar',

  'dashboard': 'Panel',
  'agenda': 'Agenda',
  'patients': 'Pacientes',
  'secure_messaging': 'Mensajería segura',
  'patients_list': 'Lista de pacientes',

  'consultation_types': 'Tipos de consulta',
  'consultation_at_office': 'Consulta en consultorio',
  'consultation_by_video': 'Consulta por video',
  'join_call': 'Unirse',
  'start_consultation': 'Iniciar consulta',

  'book_appointment': 'Reservar cita',
  'appointment_details': 'Detalles de la cita',
  'select_date': 'Seleccionar fecha',
  'select_time': 'Seleccionar hora',
  'confirm_appointment': 'Confirmar cita',
  'cancel_appointment': 'Cancelar cita',
  'reschedule_appointment': 'Reprogramar',
  'appointment_confirmed': 'Cita confirmada',
  'appointment_cancelled': 'Cita cancelada',
  'are_you_sure_cancel': '¿Estás seguro de que quieres cancelar esta cita?',
  'are_you_sure_confirm': '¿Quieres confirmar esta cita?',

  'my_profile': 'Mi perfil',
  'edit_profile': 'Editar perfil',
  'professional_info': 'Información profesional',
  'cv_and_diplomas': 'CV y diplomas',
  'manage_documents': 'Gestionar documentos',
  'specialties': 'Especialidades',
  'location': 'Ubicación',
  'languages': 'Idiomas',
  'education': 'Formación',
  'certifications': 'Certificaciones',
  'years_experience': 'años de experiencia',
  'years': 'años',

  'define_work_hours': 'Definir horarios de trabajo',
  'prices_and_duration': 'Precios y duración',
  'accept_new_patients': 'Aceptar nuevos pacientes',
  'you_must_offer_at_least_one': 'Debes ofrecer al menos un tipo de consulta',

  'saved_successfully': 'Guardado exitosamente',
  'error_occurred': 'Ocurrió un error',
  'availability_saved': 'Disponibilidad guardada',
  'settings_saved_success': 'Configuración guardada exitosamente',
  'loading_data': 'Cargando datos...',
  'no_data_available': 'No hay datos disponibles',
  'no_appointments': 'No hay citas',
  'no_pending_appointments': 'No hay citas pendientes',
  'no_confirmed_appointments': 'No hay citas confirmadas',
  'no_completed_appointments': 'No hay citas completadas',

  'mon': 'Lun',
  'tue': 'Mar',
  'wed': 'Mié',
  'thu': 'Jue',
  'fri': 'Vie',
  'sat': 'Sáb',
  'sun': 'Dom',

  'cv': 'CV',
  'diploma': 'Diploma',
  'certification': 'Certificación',
  'other': 'Otro',
  'document_type': 'Tipo de documento',
  'add_document': 'Agregar documento',
  'delete_document': 'Eliminar documento',
  'are_you_sure_delete_document':
      '¿Estás seguro de que quieres eliminar este documento?',
  'document_added': 'Documento agregado',
  'document_deleted': 'Documento eliminado',

  // Sections supplémentaires
  'professional_settings': 'Configuración profesional',
  'my_account': 'Mi cuenta',
  'studies_experience_certifications': 'Estudios, experiencia, certificaciones',
  'physical_teleconsultation_prices': 'Física, telemedicina, precios',

  // Dashboard
  'todays_appointments': 'Citas de hoy',
  'view_agenda': 'Ver agenda',
  'new_patient': 'Nuevo paciente',
  'waiting': 'En espera',
  'revenue': 'Ingresos',
  'today': 'Hoy',
  'recent_patients': 'Pacientes recientes',
  'view_all': 'Ver todos',
  'last_visit': 'Última visita',
  'next_appointment': 'Próxima cita',

  // Agenda
  'my_agenda': 'Mi Agenda',
  'no_appointments_for_date': 'Sin citas',
  'month': 'Mes',
  'two_weeks': '2 Semanas',
  'week': 'Semana',
  'refresh': 'Actualizar',
  'format': 'Formato',
  'locale_code': 'es_ES',

  'search_doctor': 'Buscar médico',
  'search_by_specialty': 'Buscar por especialidad',
  'search_by_name': 'Buscar por nombre',
  'filter': 'Filtrar',
  'sort_by': 'Ordenar por',
  'near_me': 'Cerca de mí',
  'view_profile': 'Ver perfil',
  'reviews': 'Reseñas',
  'rating': 'Calificación',
  'price': 'Precio',

  'welcome_back': 'Bienvenido de nuevo',
  'welcome_to_doctolo': 'Bienvenido a DoctoLo',
  'login_to_continue': 'Inicia sesión para continuar',
  'join_doctolo': 'Únete a Doctolo hoy',
  'remember_me': 'Recuérdame',

  'email_verification_sent': 'Correo de verificación enviado',
  'check_your_email': 'Revisa tu correo',
  'click_link_to_verify': 'Haz clic en el enlace para verificar',
  'resend_email': 'Reenviar correo',
  'verify_now': 'Verificar ahora',
  'email_verified_success': 'Correo verificado exitosamente',
  'checking_verification': 'Verificando...',
  'auto_checking_enabled': 'Verificación automática activada',
};

// العربية
final Map<String, String> _arabicStrings = {
  'app_name': 'Doctolo',
  'welcome': 'مرحباً',
  'hello': 'مرحباً',
  'login': 'تسجيل الدخول',
  'register': 'التسجيل',
  'email': 'البريد الإلكتروني',
  'password': 'كلمة المرور',
  'confirm_password': 'تأكيد كلمة المرور',
  'first_name': 'الاسم الأول',
  'last_name': 'اسم العائلة',
  'phone_number': 'رقم الهاتف',
  'logout': 'تسجيل الخروج',
  'profile': 'الملف الشخصي',
  'settings': 'الإعدادات',
  'account_settings': 'إعدادات الحساب',
  'language': 'اللغة',
  'currency': 'العملة',
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'home': 'الرئيسية',
  'appointments': 'المواعيد',
  'messages': 'الرسائل',
  'medical_records': 'السجلات الطبية',
  'search': 'بحث',
  'search_professional': 'البحث عن متخصص',
  'doctor': 'طبيب',
  'patient': 'مريض',
  'consultation': 'استشارة',
  'telemedicine': 'الطب عن بعد',
  'physical_consultation': 'استشارة حضورية',
  'follow_up': 'متابعة',
  'user': 'مستخدم',
  'my_appointments': 'مواعيدي',
  'my_consultations': 'استشاراتي',
  'all': 'الكل',
  'pending': 'قيد الانتظار',
  'confirmed': 'مؤكد',
  'completed': 'مكتمل',
  'cancelled': 'ملغى',
  'availability': 'التوفر',
  'schedule': 'الجدول',
  'rate': 'التعريفة',
  'duration': 'المدة',
  'minutes': 'دقيقة',
  'consultation_fee': 'تعريفة الاستشارة الحضورية',
  'teleconsultation_fee': 'تعريفة الطب عن بعد',
  'consultation_duration': 'مدة الاستشارة',
  'personal_info': 'المعلومات الشخصية',
  'notifications': 'الإشعارات',
  'privacy': 'الخصوصية',
  'professional_experience': 'الخبرة المهنية',
  'documents': 'المستندات',
  'offers_physical_consultation': 'يقدم استشارات حضورية',
  'offers_telemedicine': 'يقدم الطب عن بعد',
  'accepts_new_patients': 'يقبل مرضى جدد',
  'my_availability': 'أوقات التوفر',
  'add_time_slot': 'إضافة موعد',
  'from': 'من',
  'to': 'إلى',
  'monday': 'الاثنين',
  'tuesday': 'الثلاثاء',
  'wednesday': 'الأربعاء',
  'thursday': 'الخميس',
  'friday': 'الجمعة',
  'saturday': 'السبت',
  'sunday': 'الأحد',
  'select_language': 'اختر لغة العرض',
  'select_currency': 'اختر عملتك للتعريفات',
  'example': 'مثال',
  'settings_applied_everywhere':
      'يتم تطبيق هذه الإعدادات على التطبيق بالكامل ومزامنتها على جميع أجهزتك.',
  'saving': 'جاري الحفظ...',
  'loading': 'جاري التحميل...',
  'error': 'خطأ',
  'success': 'نجح',
  'settings_saved': 'تم حفظ الإعدادات',
  'email_verification': 'التحقق من البريد الإلكتروني',
  'verify_your_email': 'تحقق من بريدك الإلكتروني',
  'create_account': 'إنشاء حساب',
  'already_have_account': 'هل لديك حساب بالفعل؟',
  'dont_have_account': 'ليس لديك حساب؟',
  'forgot_password': 'نسيت كلمة المرور؟',
  'i_am_a': 'أنا:',
  'accept_terms': 'أوافق على شروط الخدمة',

  'confirm': 'تأكيد',
  'delete': 'حذف',
  'back': 'رجوع',
  'next': 'التالي',
  'finish': 'إنهاء',
  'close': 'إغلاق',
  'continue': 'متابعة',

  'dashboard': 'لوحة التحكم',
  'agenda': 'الجدول',
  'patients': 'المرضى',
  'secure_messaging': 'المراسلة الآمنة',
  'patients_list': 'قائمة المرضى',

  'consultation_types': 'أنواع الاستشارة',
  'consultation_at_office': 'استشارة في العيادة',
  'consultation_by_video': 'استشارة بالفيديو',
  'join_call': 'الانضمام',
  'start_consultation': 'بدء الاستشارة',

  'book_appointment': 'حجز موعد',
  'appointment_details': 'تفاصيل الموعد',
  'select_date': 'اختر التاريخ',
  'select_time': 'اختر الوقت',
  'confirm_appointment': 'تأكيد الموعد',
  'cancel_appointment': 'إلغاء الموعد',
  'reschedule_appointment': 'إعادة جدولة',
  'appointment_confirmed': 'تم تأكيد الموعد',
  'appointment_cancelled': 'تم إلغاء الموعد',
  'are_you_sure_cancel': 'هل أنت متأكد من إلغاء هذا الموعد؟',
  'are_you_sure_confirm': 'هل تريد تأكيد هذا الموعد؟',

  'my_profile': 'ملفي الشخصي',
  'edit_profile': 'تعديل الملف الشخصي',
  'professional_info': 'معلومات مهنية',
  'cv_and_diplomas': 'السيرة الذاتية والشهادات',
  'manage_documents': 'إدارة المستندات',
  'specialties': 'التخصصات',
  'location': 'الموقع',
  'languages': 'اللغات',
  'education': 'التعليم',
  'certifications': 'الشهادات',
  'years_experience': 'سنوات الخبرة',
  'years': 'سنوات',

  'define_work_hours': 'تحديد ساعات العمل',
  'prices_and_duration': 'الأسعار والمدة',
  'accept_new_patients': 'قبول مرضى جدد',
  'you_must_offer_at_least_one':
      'يجب أن تقدم نوعاً واحداً على الأقل من الاستشارة',

  'saved_successfully': 'تم الحفظ بنجاح',
  'error_occurred': 'حدث خطأ',
  'availability_saved': 'تم حفظ التوفر',
  'settings_saved_success': 'تم حفظ الإعدادات بنجاح',
  'loading_data': 'جاري تحميل البيانات...',
  'no_data_available': 'لا توجد بيانات متاحة',
  'no_appointments': 'لا توجد مواعيد',
  'no_pending_appointments': 'لا توجد مواعيد معلقة',
  'no_confirmed_appointments': 'لا توجد مواعيد مؤكدة',
  'no_completed_appointments': 'لا توجد مواعيد مكتملة',

  'mon': 'الإثنين',
  'tue': 'الثلاثاء',
  'wed': 'الأربعاء',
  'thu': 'الخميس',
  'fri': 'الجمعة',
  'sat': 'السبت',
  'sun': 'الأحد',

  'cv': 'السيرة الذاتية',
  'diploma': 'شهادة',
  'certification': 'اعتماد',
  'other': 'آخر',
  'document_type': 'نوع المستند',
  'add_document': 'إضافة مستند',
  'delete_document': 'حذف المستند',
  'are_you_sure_delete_document': 'هل أنت متأكد من حذف هذا المستند؟',
  'document_added': 'تمت إضافة المستند',
  'document_deleted': 'تم حذف المستند',

  // Sections supplémentaires
  'professional_settings': 'الإعدادات المهنية',
  'my_account': 'حسابي',
  'studies_experience_certifications': 'الدراسات، الخبرة، الشهادات',
  'physical_teleconsultation_prices': 'فيزيائي، استشارة عن بعد، أسعار',

  // Dashboard
  'todays_appointments': 'مواعيد اليوم',
  'view_agenda': 'عرض الأجندة',
  'new_patient': 'مريض جديد',
  'waiting': 'في الانتظار',
  'revenue': 'الإيرادات',
  'today': 'اليوم',
  'recent_patients': 'المرضى الحديثون',
  'view_all': 'عرض الكل',
  'last_visit': 'آخر زيارة',
  'next_appointment': 'الموعد القادم',

  // Agenda
  'my_agenda': 'أجندتي',
  'no_appointments_for_date': 'لا توجد مواعيد',
  'month': 'شهر',
  'two_weeks': 'أسبوعين',
  'week': 'أسبوع',
  'refresh': 'تحديث',
  'format': 'التنسيق',
  'locale_code': 'ar',

  'search_doctor': 'البحث عن طبيب',
  'search_by_specialty': 'البحث بالتخصص',
  'search_by_name': 'البحث بالاسم',
  'filter': 'تصفية',
  'sort_by': 'ترتيب حسب',
  'near_me': 'بالقرب مني',
  'view_profile': 'عرض الملف الشخصي',
  'reviews': 'التقييمات',
  'rating': 'التقييم',
  'price': 'السعر',

  'welcome_back': 'مرحباً بعودتك',
  'welcome_to_doctolo': 'مرحباً بك في DoctoLo',
  'login_to_continue': 'سجل الدخول للمتابعة',
  'join_doctolo': 'انضم إلى Doctolo اليوم',
  'remember_me': 'تذكرني',

  'email_verification_sent': 'تم إرسال بريد التحقق',
  'check_your_email': 'تحقق من بريدك الإلكتروني',
  'click_link_to_verify': 'انقر على الرابط للتحقق',
  'resend_email': 'إعادة إرسال البريد',
  'verify_now': 'تحقق الآن',
  'email_verified_success': 'تم التحقق من البريد بنجاح',
  'checking_verification': 'جاري التحقق...',
  'auto_checking_enabled': 'التحقق التلقائي مفعّل',
};

// Deutsch
final Map<String, String> _germanStrings = {
  'app_name': 'Doctolo',
  'welcome': 'Willkommen',
  'hello': 'Hallo',
  'login': 'Anmelden',
  'register': 'Registrieren',
  'email': 'E-Mail',
  'password': 'Passwort',
  'confirm_password': 'Passwort bestätigen',
  'first_name': 'Vorname',
  'last_name': 'Nachname',
  'phone_number': 'Telefonnummer',
  'logout': 'Abmelden',
  'profile': 'Profil',
  'settings': 'Einstellungen',
  'account_settings': 'Kontoeinstellungen',
  'language': 'Sprache',
  'currency': 'Währung',
  'save': 'Speichern',
  'cancel': 'Abbrechen',
  'home': 'Startseite',
  'appointments': 'Termine',
  'messages': 'Nachrichten',
  'medical_records': 'Krankenakte',
  'search': 'Suchen',
  'search_professional': 'Fachkraft suchen',
  'doctor': 'Arzt',
  'patient': 'Patient',
  'consultation': 'Beratung',
  'telemedicine': 'Telemedizin',
  'physical_consultation': 'Persönliche Beratung',
  'follow_up': 'Nachsorge',
  'user': 'Benutzer',
  'my_appointments': 'Meine Termine',
  'my_consultations': 'Meine Beratungen',
  'all': 'Alle',
  'pending': 'Ausstehend',
  'confirmed': 'Bestätigt',
  'completed': 'Abgeschlossen',
  'cancelled': 'Abgesagt',
  'availability': 'Verfügbarkeit',
  'schedule': 'Zeitplan',
  'rate': 'Tarif',
  'duration': 'Dauer',
  'minutes': 'Minuten',
  'consultation_fee': 'Gebühr für persönliche Beratung',
  'teleconsultation_fee': 'Telemedizin-Gebühr',
  'consultation_duration': 'Beratungsdauer',
  'personal_info': 'Persönliche Informationen',
  'notifications': 'Benachrichtigungen',
  'privacy': 'Datenschutz',
  'professional_experience': 'Berufserfahrung',
  'documents': 'Dokumente',
  'offers_physical_consultation': 'Bietet persönliche Beratungen an',
  'offers_telemedicine': 'Bietet Telemedizin an',
  'accepts_new_patients': 'Nimmt neue Patienten an',
  'my_availability': 'Meine Verfügbarkeit',
  'add_time_slot': 'Zeitfenster hinzufügen',
  'from': 'Von',
  'to': 'Bis',
  'monday': 'Montag',
  'tuesday': 'Dienstag',
  'wednesday': 'Mittwoch',
  'thursday': 'Donnerstag',
  'friday': 'Freitag',
  'saturday': 'Samstag',
  'sunday': 'Sonntag',
  'select_language': 'Anzeigesprache wählen',
  'select_currency': 'Wählen Sie Ihre Währung für Tarife',
  'example': 'Beispiel',
  'settings_applied_everywhere':
      'Diese Einstellungen gelten für die gesamte App und werden auf allen Ihren Geräten synchronisiert.',
  'saving': 'Wird gespeichert...',
  'loading': 'Lädt...',
  'error': 'Fehler',
  'success': 'Erfolg',
  'settings_saved': 'Einstellungen gespeichert',
  'email_verification': 'E-Mail-Verifizierung',
  'verify_your_email': 'Verifizieren Sie Ihre E-Mail',
  'create_account': 'Konto erstellen',
  'already_have_account': 'Haben Sie bereits ein Konto?',
  'dont_have_account': 'Haben Sie kein Konto?',
  'forgot_password': 'Passwort vergessen?',
  'i_am_a': 'Ich bin ein(e):',
  'accept_terms': 'Ich akzeptiere die Nutzungsbedingungen',

  'confirm': 'Bestätigen',
  'delete': 'Löschen',
  'back': 'Zurück',
  'next': 'Weiter',
  'finish': 'Beenden',
  'close': 'Schließen',
  'continue': 'Fortfahren',

  'dashboard': 'Dashboard',
  'agenda': 'Terminkalender',
  'patients': 'Patienten',
  'secure_messaging': 'Sichere Nachrichten',
  'patients_list': 'Patientenliste',

  'consultation_types': 'Konsultationsarten',
  'consultation_at_office': 'Praxiskonsultation',
  'consultation_by_video': 'Videokonsultation',
  'join_call': 'Beitreten',
  'start_consultation': 'Konsultation starten',

  'book_appointment': 'Termin buchen',
  'appointment_details': 'Termindetails',
  'select_date': 'Datum wählen',
  'select_time': 'Uhrzeit wählen',
  'confirm_appointment': 'Termin bestätigen',
  'cancel_appointment': 'Termin absagen',
  'reschedule_appointment': 'Neu planen',
  'appointment_confirmed': 'Termin bestätigt',
  'appointment_cancelled': 'Termin abgesagt',
  'are_you_sure_cancel': 'Möchten Sie diesen Termin wirklich absagen?',
  'are_you_sure_confirm': 'Möchten Sie diesen Termin bestätigen?',

  'my_profile': 'Mein Profil',
  'edit_profile': 'Profil bearbeiten',
  'professional_info': 'Berufliche Informationen',
  'cv_and_diplomas': 'Lebenslauf und Diplome',
  'manage_documents': 'Dokumente verwalten',
  'specialties': 'Fachgebiete',
  'location': 'Standort',
  'languages': 'Sprachen',
  'education': 'Ausbildung',
  'certifications': 'Zertifizierungen',
  'years_experience': 'Jahre Erfahrung',
  'years': 'Jahre',

  'define_work_hours': 'Arbeitszeiten festlegen',
  'prices_and_duration': 'Preise und Dauer',
  'accept_new_patients': 'Neue Patienten annehmen',
  'you_must_offer_at_least_one':
      'Sie müssen mindestens eine Konsultationsart anbieten',

  'saved_successfully': 'Erfolgreich gespeichert',
  'error_occurred': 'Ein Fehler ist aufgetreten',
  'availability_saved': 'Verfügbarkeit gespeichert',
  'settings_saved_success': 'Einstellungen erfolgreich gespeichert',
  'loading_data': 'Daten werden geladen...',
  'no_data_available': 'Keine Daten verfügbar',
  'no_appointments': 'Keine Termine',
  'no_pending_appointments': 'Keine ausstehenden Termine',
  'no_confirmed_appointments': 'Keine bestätigten Termine',
  'no_completed_appointments': 'Keine abgeschlossenen Termine',

  'mon': 'Mo',
  'tue': 'Di',
  'wed': 'Mi',
  'thu': 'Do',
  'fri': 'Fr',
  'sat': 'Sa',
  'sun': 'So',

  'cv': 'Lebenslauf',
  'diploma': 'Diplom',
  'certification': 'Zertifizierung',
  'other': 'Andere',
  'document_type': 'Dokumenttyp',
  'add_document': 'Dokument hinzufügen',
  'delete_document': 'Dokument löschen',
  'are_you_sure_delete_document':
      'Möchten Sie dieses Dokument wirklich löschen?',
  'document_added': 'Dokument hinzugefügt',
  'document_deleted': 'Dokument gelöscht',

  // Sections supplémentaires
  'professional_settings': 'Berufseinstellungen',
  'my_account': 'Mein Konto',
  'studies_experience_certifications': 'Studien, Erfahrung, Zertifizierungen',
  'physical_teleconsultation_prices': 'Physisch, Telemedizin, Preise',

  // Dashboard
  'todays_appointments': 'Heutige Termine',
  'view_agenda': 'Agenda anzeigen',
  'new_patient': 'Neuer Patient',
  'waiting': 'Wartend',
  'revenue': 'Einnahmen',
  'today': 'Heute',
  'recent_patients': 'Letzte Patienten',
  'view_all': 'Alle anzeigen',
  'last_visit': 'Letzter Besuch',
  'next_appointment': 'Nächster Termin',

  // Agenda
  'my_agenda': 'Meine Agenda',
  'no_appointments_for_date': 'Keine Termine',
  'month': 'Monat',
  'two_weeks': '2 Wochen',
  'week': 'Woche',
  'refresh': 'Aktualisieren',
  'format': 'Format',
  'locale_code': 'de_DE',

  'search_doctor': 'Arzt suchen',
  'search_by_specialty': 'Nach Fachgebiet suchen',
  'search_by_name': 'Nach Namen suchen',
  'filter': 'Filtern',
  'sort_by': 'Sortieren nach',
  'near_me': 'In meiner Nähe',
  'view_profile': 'Profil ansehen',
  'reviews': 'Bewertungen',
  'rating': 'Bewertung',
  'price': 'Preis',

  'welcome_back': 'Willkommen zurück',
  'welcome_to_doctolo': 'Willkommen bei DoctoLo',
  'login_to_continue': 'Anmelden um fortzufahren',
  'join_doctolo': 'Heute Doctolo beitreten',
  'remember_me': 'Angemeldet bleiben',

  'email_verification_sent': 'Bestätigungs-E-Mail gesendet',
  'check_your_email': 'Überprüfen Sie Ihre E-Mail',
  'click_link_to_verify': 'Klicken Sie auf den Link zur Bestätigung',
  'resend_email': 'E-Mail erneut senden',
  'verify_now': 'Jetzt bestätigen',
  'email_verified_success': 'E-Mail erfolgreich bestätigt',
  'checking_verification': 'Bestätigung wird überprüft...',
  'auto_checking_enabled': 'Auto-Überprüfung aktiviert',
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'es', 'ar', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
