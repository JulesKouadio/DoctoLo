import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../data/models/medical_record_model.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currentDoctorId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Informations médicales'),
            Tab(text: 'Historique des consultations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MedicalInfoTab(patientId: widget.patientId),
          _ConsultationHistoryTab(
            patientId: widget.patientId,
            doctorId: _currentDoctorId!,
          ),
        ],
      ),
    );
  }
}

// Onglet des informations médicales
class _MedicalInfoTab extends StatelessWidget {
  final String patientId;

  const _MedicalInfoTab({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('Patient non trouvé'));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('patient_medical_info')
              .doc(patientId)
              .get(),
          builder: (context, medicalSnapshot) {
            PatientMedicalInfo? medicalInfo;
            if (medicalSnapshot.hasData && medicalSnapshot.data!.exists) {
              medicalInfo = PatientMedicalInfo.fromJson(
                medicalSnapshot.data!.data() as Map<String, dynamic>,
                patientId,
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations personnelles
                  _InfoSection(
                    title: 'Informations personnelles',
                    icon: CupertinoIcons.person_fill,
                    children: [
                      _InfoRow(
                        label: 'Nom complet',
                        value:
                            '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
                        icon: CupertinoIcons.person,
                      ),
                      _InfoRow(
                        label: 'Email',
                        value: userData['email'] ?? 'Non renseigné',
                        icon: CupertinoIcons.mail,
                      ),
                      _InfoRow(
                        label: 'Téléphone',
                        value: userData['phone'] ?? 'Non renseigné',
                        icon: CupertinoIcons.phone,
                      ),
                      if (userData['dateOfBirth'] != null)
                        _InfoRow(
                          label: 'Date de naissance',
                          value: DateFormat('dd/MM/yyyy').format(
                            (userData['dateOfBirth'] as Timestamp).toDate(),
                          ),
                          icon: CupertinoIcons.calendar,
                        ),
                      if (userData['gender'] != null)
                        _InfoRow(
                          label: 'Genre',
                          value: userData['gender'] == 'male'
                              ? 'Masculin'
                              : 'Féminin',
                          icon: CupertinoIcons.person_2,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Informations médicales
                  _InfoSection(
                    title: 'Informations médicales',
                    icon: CupertinoIcons.heart_fill,
                    children: [
                      _InfoRow(
                        label: 'Groupe sanguin',
                        value: medicalInfo?.bloodGroup ?? 'Non renseigné',
                        icon: CupertinoIcons.drop_fill,
                        valueColor: Colors.red,
                      ),
                      _InfoRow(
                        label: 'Taille',
                        value: medicalInfo?.height != null
                            ? '${medicalInfo!.height!.toStringAsFixed(0)} cm'
                            : 'Non renseigné',
                        icon: CupertinoIcons.arrow_up_down,
                      ),
                      _InfoRow(
                        label: 'Poids',
                        value: medicalInfo?.weight != null
                            ? '${medicalInfo!.weight!.toStringAsFixed(1)} kg'
                            : 'Non renseigné',
                        icon: CupertinoIcons.infinite,
                      ),
                      if (medicalInfo != null &&
                          medicalInfo.emergencyContact != null)
                        _InfoRow(
                          label: 'Contact d\'urgence',
                          value: medicalInfo.emergencyContact!,
                          icon: CupertinoIcons.phone_circle_fill,
                          valueColor: Colors.red,
                        ),
                    ],
                  ),

                  // Allergies
                  if (medicalInfo != null &&
                      medicalInfo.allergies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Allergies',
                      icon: CupertinoIcons.exclamationmark_triangle_fill,
                      iconColor: Colors.orange,
                      children: medicalInfo.allergies
                          .map(
                            (allergy) =>
                                _ChipRow(label: allergy, color: Colors.orange),
                          )
                          .toList(),
                    ),
                  ],

                  // Maladies chroniques
                  if (medicalInfo != null &&
                      medicalInfo.chronicDiseases.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Maladies chroniques',
                      icon: CupertinoIcons.heart_fill,
                      iconColor: Colors.red,
                      children: medicalInfo.chronicDiseases
                          .map(
                            (disease) =>
                                _ChipRow(label: disease, color: Colors.red),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Onglet de l'historique des consultations
class _ConsultationHistoryTab extends StatelessWidget {
  final String patientId;
  final String doctorId;

  const _ConsultationHistoryTab({
    required this.patientId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    // Afficher les paramètres de la requête
    print('🔍 Chargement historique consultations:');
    print('   Patient ID: $patientId');
    print('   Doctor ID: $doctorId');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('date', descending: true)
          .snapshots()
          .handleError((error) {
            // Capturer les erreurs du stream
            print('\n');
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print(
              '🔴 ERREUR FIRESTORE - INDEX REQUIS (Historique Consultations)',
            );
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print('📍 Collection: appointments');
            print('📍 Patient ID: $patientId');
            print('📍 Doctor ID: $doctorId');
            print(
              '───────────────────────────────────────────────────────────',
            );
            print('📋 Index composite nécessaire:');
            print('   1. patientId (Ascending) - Égalité');
            print('   2. doctorId (Ascending) - Égalité');
            print('   3. date (Descending) - OrderBy');
            print(
              '───────────────────────────────────────────────────────────',
            );
            print('❌ ERREUR COMPLÈTE:');
            print(error.toString());
            print(
              '───────────────────────────────────────────────────────────',
            );
            print('✅ SOLUTION 1 - Lien automatique:');
            print(
              '   Cherchez dans l\'erreur ci-dessus un lien commençant par:',
            );
            print('   https://console.firebase.google.com/...');
            print(
              '   ⚠️ CLIQUEZ SUR CE LIEN pour créer l\'index automatiquement!',
            );
            print(
              '───────────────────────────────────────────────────────────',
            );
            print('✅ SOLUTION 2 - Ajout manuel dans firestore.indexes.json:');
            print('''
{
  "collectionGroup": "appointments",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "patientId", "order": "ASCENDING" },
    { "fieldPath": "doctorId", "order": "ASCENDING" },
    { "fieldPath": "date", "order": "DESCENDING" }
  ]
}''');
            print(
              '   Puis: firebase deploy --only firestore:indexes --project doctolo',
            );
            print(
              '═══════════════════════════════════════════════════════════',
            );
            print('\n');
          }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Afficher l'erreur dans la console ET dans l'UI
          print('\n');
          print('═══════════════════════════════════════════════════════════');
          print('🔴 ERREUR STREAMBUILDER (Historique Consultations)');
          print('═══════════════════════════════════════════════════════════');
          print('Type: ${snapshot.error.runtimeType}');
          print('Message: ${snapshot.error}');
          if (snapshot.stackTrace != null) {
            print('StackTrace: ${snapshot.stackTrace}');
          }
          print('═══════════════════════════════════════════════════════════');
          print(
            '💡 CHERCHEZ LE LIEN dans l\'erreur ci-dessus et CLIQUEZ dessus!',
          );
          print('═══════════════════════════════════════════════════════════');
          print('\n');

          return Center(
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(32.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Index Firestore requis',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consultez la console pour le lien de création',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(14),
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Afficher les instructions
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Créer l\'index Firestore'),
                          content: const SingleChildScrollView(
                            child: Text(
                              '1. Vérifiez la console (terminal)\n'
                              '2. Trouvez le lien "https://console.firebase.google.com/..."\n'
                              '3. Cliquez sur ce lien\n'
                              '4. Firebase créera l\'index automatiquement\n'
                              '5. Attendez 2-5 minutes\n'
                              '6. Relancez l\'application',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.info_circle),
                    label: const Text('Comment créer l\'index?'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final consultations = snapshot.data?.docs ?? [];

        if (consultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.doc_text,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune consultation',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(18),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          itemCount: consultations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final consultation =
                consultations[index].data() as Map<String, dynamic>;
            return _ConsultationCard(
              consultation: consultation,
              consultationId: consultations[index].id,
            );
          },
        );
      },
    );
  }
}

// Widget pour une section d'informations
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Widget pour une ligne d'information
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(13),
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour une puce d'information (allergies, maladies)
class _ChipRow extends StatelessWidget {
  final String label;
  final Color color;

  const _ChipRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(8)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(12), vertical: getProportionateScreenHeight(8)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(14),
                  color: color.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Carte de consultation
class _ConsultationCard extends StatelessWidget {
  final Map<String, dynamic> consultation;
  final String consultationId;

  const _ConsultationCard({
    required this.consultation,
    required this.consultationId,
  });

  @override
  Widget build(BuildContext context) {
    final consultationDate = (consultation['date'] as Timestamp).toDate();
    final formattedDate = DateFormat(
      'dd MMMM yyyy',
      'fr_FR',
    ).format(consultationDate);
    final formattedTime = DateFormat('HH:mm').format(consultationDate);
    final reason = consultation['reason'] ?? 'Non spécifiée';
    final type = consultation['type'] ?? '';
    final status = consultation['status'] ?? '';

    // Vérifier si c'est une téléconsultation
    final isTelemedicine =
        type.toLowerCase().contains('telemedicine') ||
        type.toLowerCase().contains('téléconsultation');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showConsultationDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec date et type
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(14),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isTelemedicine
                          ? AppColors.accent.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTelemedicine
                              ? CupertinoIcons.videocam_fill
                              : CupertinoIcons.building_2_fill,
                          size: 14,
                          color: isTelemedicine
                              ? AppColors.accent
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isTelemedicine ? 'Téléconsultation' : 'Au cabinet',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(12),
                            color: isTelemedicine
                                ? AppColors.accent
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Raison de consultation
              _DetailRow(
                icon: CupertinoIcons.doc_text,
                label: 'Raison',
                value: reason,
              ),

              // Statut
              const SizedBox(height: 8),
              _DetailRow(
                icon: CupertinoIcons.info_circle,
                label: 'Statut',
                value: _getStatusLabel(status),
                valueColor: _getStatusColor(status),
              ),

              // Afficher diagnostic et ordonnance si disponibles
              if (consultation['diagnosis'] != null) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  icon: CupertinoIcons.check_mark_circled,
                  label: 'Diagnostic',
                  value: consultation['diagnosis'],
                ),
              ],
              if (consultation['prescription'] != null) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  icon: CupertinoIcons.square_list,
                  label: 'Ordonnance',
                  value: consultation['prescription'],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final consultationDate = (consultation['date'] as Timestamp).toDate();
          final formattedDate = DateFormat(
            'EEEE d MMMM yyyy',
            'fr_FR',
          ).format(consultationDate);
          final formattedTime = DateFormat('HH:mm').format(consultationDate);
          final reason = consultation['reason'] ?? 'Non spécifiée';
          final type = consultation['type'] ?? '';
          final status = consultation['status'] ?? '';
          final diagnosis = consultation['diagnosis'] ?? 'Non renseigné';
          final prescription =
              consultation['prescription'] ?? 'Aucune ordonnance';
          final notes = consultation['notes'] ?? '';

          final isTelemedicine =
              type.toLowerCase().contains('telemedicine') ||
              type.toLowerCase().contains('téléconsultation');

          return ListView(
            controller: scrollController,
            padding: EdgeInsets.all(getProportionateScreenWidth(24)),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Text(
                'Détails de la consultation',
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(22),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Date et heure
              _DetailCard(
                icon: CupertinoIcons.calendar,
                title: 'Date et heure',
                content: '$formattedDate à $formattedTime',
              ),

              // Type de consultation
              _DetailCard(
                icon: isTelemedicine
                    ? CupertinoIcons.videocam_fill
                    : CupertinoIcons.building_2_fill,
                title: 'Type de consultation',
                content: isTelemedicine
                    ? 'Téléconsultation'
                    : 'Consultation au cabinet',
              ),

              // Raison
              _DetailCard(
                icon: CupertinoIcons.doc_text,
                title: 'Raison de consultation',
                content: reason,
              ),

              // Diagnostic
              _DetailCard(
                icon: CupertinoIcons.check_mark_circled,
                title: 'Diagnostic',
                content: diagnosis,
              ),

              // Ordonnance
              _DetailCard(
                icon: CupertinoIcons.square_list,
                title: 'Ordonnance',
                content: prescription,
              ),

              // Notes supplémentaires
              if (notes.isNotEmpty)
                _DetailCard(
                  icon: CupertinoIcons.text_bubble,
                  title: 'Notes',
                  content: notes,
                ),

              // Statut
              _DetailCard(
                icon: CupertinoIcons.info_circle,
                title: 'Statut',
                content: _getStatusLabel(status),
                contentColor: _getStatusColor(status),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'scheduled':
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'scheduled':
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Widget pour une ligne de détail dans la carte
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: getProportionateScreenHeight(14),
                color: Colors.grey[800],
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Widget pour une carte de détail dans le modal
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color? contentColor;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
    this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(13),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: getProportionateScreenHeight(15),
              color: contentColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
