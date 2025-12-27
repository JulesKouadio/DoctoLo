# Guide de Traduction Automatique - Doctolo

## Principe

Pour traduire l'application, il faut :
1. Ajouter les clés manquantes dans `app_localizations.dart`
2. Remplacer tous les `Text('texte dur')` par `Text(l10n.clé)`

## Script de traduction automatique

Créez ce script Python `translate_app.py` :

```python
import re
import os

# Mapping des textes français vers les clés
translations = {
    # Navigation
    "Accueil": "home",
    "Rendez-vous": "appointments",
    "Messages": "messages",
    "Dossier médical": "medicalRecords",
    "Profil": "profile",
    
    # Actions
    "Enregistrer": "save",
    "Annuler": "cancel",
    "Confirmer": "confirm",
    "Supprimer": "delete",
    "Retour": "back",
    "Rechercher": "search",
    
    # Statuts
    "Tous": "all",
    "En attente": "pending",
    "Confirmés": "confirmed",
    "Terminés": "completed",
    "Annulés": "cancelled",
    
    # Consultation
    "Mes rendez-vous": "myAppointments",
    "Mes consultations": "myConsultations",
    "Consultation physique": "physicalConsultation",
    "Téléconsultation": "telemedicine",
    "Tarif consultation physique": "consultationFee",
    "Tarif téléconsultation": "teleconsultationFee",
    
    # Paramètres
    "Paramètres du compte": "accountSettings",
    "Langue": "language",
    "Devise": "currency",
    "Mes disponibilités": "myAvailability",
    "Types de consultation": "consultationTypes",
    "Parcours professionnel": "professionalExperience",
    "CV et diplômes": "cvAndDiplomas",
    "Informations personnelles": "personalInfo",
    "Notifications": "notifications",
    "Confidentialité": "privacy",
    
    # Temps
    "Lundi": "monday",
    "Mardi": "tuesday",
    "Mercredi": "wednesday",
    "Jeudi": "jeudi",
    "Vendredi": "friday",
    "Samedi": "saturday",
    "Dimanche": "sunday",
    
    # Messages
    "Erreur": "error",
    "Succès": "success",
    "Chargement...": "loading",
    "Enregistrement...": "saving",
    
    # Médecin
    "Médecin": "doctor",
    "Patient": "patient",
    "Patients": "patients",
    "Liste des patients": "patientsList",
    "Messagerie sécurisée": "secureMessaging",
    "Accepte de nouveaux patients": "acceptsNewPatients",
    "Propose des consultations physiques": "offersPhysicalConsultation",
    "Propose la téléconsultation": "offersTelemedicine",
    
    # Divers
    "Vous avez déjà un compte ?": "alreadyHaveAccount",
    "Vous n'avez pas de compte ?": "dontHaveAccount",
    "Mot de passe oublié ?": "forgotPassword",
    "Je suis un(e):": "iAmA",
    "Créer un compte": "createAccount",
    "Connexion": "login",
    "Déconnexion": "logout",
    "Bienvenue sur Doctolo": "welcomeToDoctolo",
}

def translate_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Ajouter import si manquant
    if 'app_localizations.dart' not in content:
        import_line = "import '../../../../core/l10n/app_localizations.dart';"
        if 'import' in content:
            content = content.replace(
                "import 'package:flutter/material.dart';",
                f"import 'package:flutter/material.dart';\n{import_line}"
            )
    
    # Ajouter final l10n au début du build method
    if 'final l10n = AppLocalizations.of(context)!' not in content:
        content = re.sub(
            r'Widget build\(BuildContext context\) \{',
            'Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;',
            content
        )
    
    # Remplacer les textes
    for french, key in translations.items():
        # Pattern pour Text('texte') et Text("texte")
        patterns = [
            f"Text\\('{ french}'\\)",
            f'Text\\("{french}"\\)',
            f"const Text\\('{french}'\\)",
            f'const Text\\("{french}"\\)',
        ]
        
        for pattern in patterns:
            content = re.sub(pattern, f'Text(l10n.{key})', content)
    
    # Sauvegarder
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ Traduit: {filepath}")

# Fichiers à traduire
files_to_translate = [
    'lib/features/doctor/presentation/pages/doctor_home_page.dart',
    'lib/features/patient/presentation/pages/patient_home_page.dart',
    'lib/features/appointment/presentation/pages/appointments_list_page.dart',
    'lib/features/doctor/presentation/pages/consultation_settings_page.dart',
    'lib/features/doctor/presentation/pages/availability_settings_page.dart',
    # Ajoutez d'autres fichiers...
]

for file in files_to_translate:
    if os.path.exists(file):
        translate_file(file)
```

## Ajout des clés manquantes dans app_localizations.dart

Ajoutez ces getters dans la classe `AppLocalizations` :

```dart
// Ajouts nécessaires
String get confirm => translate('confirm');
String get delete => translate('delete');
String get back => translate('back');
String get consultationTypes => translate('consultation_types');
String get cvAndDiplomas => translate('cv_and_diplomas');
String get patients => translate('patients');
String get patientsList => translate('patients_list');
String get secureMessaging => translate('secure_messaging');
String get welcomeToDoctolo => translate('welcome_to_doctolo');
String get joinCall => translate('join_call');
String get startConsultation => translate('start_consultation');
String get bookAppointment => translate('book_appointment');
String get appointmentDetails => translate('appointment_details');
String get selectDate => translate('select_date');
String get selectTime => translate('select_time');
String get confirmAppointment => translate('confirm_appointment');
String get cancelAppointment => translate('cancel_appointment');
String get specialties => translate('specialties');
String get location => translate('location');
String get price => translate('price');
String get years => translate('years');
String get yearsExperience => translate('years_experience');
String get languages => translate('languages');
String get education => translate('education');
String get certifications => translate('certifications');
String get reviews => translate('reviews');
String get rating => translate('rating');
String get viewProfile => translate('view_profile');
```

Et dans chaque map de traduction (\_frenchStrings, \_englishStrings, etc.), ajoutez :

```dart
// Français
'confirm': 'Confirmer',
'delete': 'Supprimer',
'back': 'Retour',
'consultation_types': 'Types de consultation',
'cv_and_diplomas': 'CV et diplômes',
'patients': 'Patients',
'patients_list': 'Liste des patients',
'secure_messaging': 'Messagerie sécurisée',
'welcome_to_doctolo': 'Bienvenue sur DoctoLo',
'join_call': 'Rejoindre',
'start_consultation': 'Démarrer la consultation',
'book_appointment': 'Réserver un rendez-vous',
'appointment_details': 'Détails du rendez-vous',
'select_date': 'Sélectionner une date',
'select_time': 'Sélectionner l\'heure',
'confirm_appointment': 'Confirmer le rendez-vous',
'cancel_appointment': 'Annuler le rendez-vous',
'specialties': 'Spécialités',
'location': 'Localisation',
'price': 'Prix',
'years': 'ans',
'years_experience': 'ans d\'expérience',
'languages': 'Langues',
'education': 'Formation',
'certifications': 'Certifications',
'reviews': 'Avis',
'rating': 'Note',
'view_profile': 'Voir le profil',

// English
'confirm': 'Confirm',
'delete': 'Delete',
'back': 'Back',
'consultation_types': 'Consultation Types',
'cv_and_diplomas': 'CV and Diplomas',
'patients': 'Patients',
'patients_list': 'Patients List',
'secure_messaging': 'Secure Messaging',
'welcome_to_doctolo': 'Welcome to Doctolo',
// etc...
```

## Utilisation manuelle rapide

Dans chaque page, ajoutez au début du `build`:

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Scaffold(
    appBar: AppBar(
      title: Text(l10n.myAppointments), // Au lieu de Text('Mes rendez-vous')
    ),
    // ...
  );
}
```

## Commandes utiles

```bash
# Rechercher tous les Text avec du texte dur en français
grep -r "Text('" lib/ | grep -v "l10n\."

# Compter combien de textes restent à traduire  
grep -r "Text('" lib/ | grep -v "l10n\." | wc -l

# Hot reload après modifications
flutter run
# Puis appuyez sur 'r' pour hot reload
```

## Priorités de traduction

1. ✅ Navigation bottom bar (patient/doctor)
2. ✅ Page de paramètres
3. ⚠️ Pages d'authentification (login, register)
4. ⚠️ Pages de rendez-vous (liste, détails, réservation)
5. ⚠️ Pages médecin (home, profil, disponibilités)
6. ⚠️ Pages recherche et profils

## Test

Après traduction :
1. Lancer l'app : `flutter run`
2. Aller dans Paramètres → Langue
3. Changer la langue vers English
4. Vérifier que les textes changent partout
