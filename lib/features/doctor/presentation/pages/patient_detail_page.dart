import 'package:DoctoLo/features/doctor/presentation/pages/patient_metrics_page.dart'
    show PatientMetricsPage, PatientConsultationPage;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/utils/responsive.dart';
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
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    if (isDesktop || isTablet) {
      return _buildDesktopLayout();
    }

    return _buildMobileLayout();
  }

  // LAYOUT DESKTOP/TABLETTE MODERNE
  Widget _buildDesktopLayout() {
    final isDesktop = context.isDesktop;
    final maxWidth = isDesktop ? 1400.0 : 1000.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                widget.patientName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Dossier patient',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 80,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne gauche - Informations médicales (40%)
                Expanded(
                  flex: 4,
                  child: _MedicalInfoTab(
                    patientId: widget.patientId,
                    isDesktop: true,
                  ),
                ),
                const SizedBox(width: 24),
                // Colonne droite - Historique consultations (60%)
                Expanded(
                  flex: 6,
                  child: _DesktopConsultationHistory(
                    patientId: widget.patientId,
                    doctorId: _currentDoctorId!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LAYOUT MOBILE (INCHANGÉ)
  Widget _buildMobileLayout() {
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
          _MedicalInfoTab(patientId: widget.patientId, isDesktop: false),
          _ConsultationHistoryTab(
            patientId: widget.patientId,
            doctorId: _currentDoctorId!,
          ),
        ],
      ),
    );
  }
}

// Onglet des informations médicales (adapté pour desktop et mobile)
class _MedicalInfoTab extends StatefulWidget {
  final String patientId;
  final bool isDesktop;

  const _MedicalInfoTab({required this.patientId, this.isDesktop = false});

  @override
  __MedicalInfoTabState createState() => __MedicalInfoTabState();
}

class __MedicalInfoTabState extends State<_MedicalInfoTab> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<PatientMedicalInfo?> _medicalInfoFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
    _medicalInfoFuture = _fetchMedicalInfo();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .get();

    if (!snapshot.exists) {
      throw Exception('Patient non trouvé');
    }

    final data = snapshot.data() as Map<String, dynamic>;
    data['id'] = widget.patientId;
    return data;
  }

  Future<PatientMedicalInfo?> _fetchMedicalInfo() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('medical_records')
        .doc(widget.patientId)
        .get();

    if (snapshot.exists) {
      return PatientMedicalInfo.fromJson(
        snapshot.data() as Map<String, dynamic>,
        widget.patientId,
      );
    }
    return null;
  }

  Future<void> _updateUserField(String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.patientId)
          .update({field: value});

      setState(() {
        _userDataFuture = _fetchUserData();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$field mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(String title, String currentValue, String field) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Entrez le nouveau $title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                await _updateUserField(field, controller.text.trim());
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_userDataFuture, _medicalInfoFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final userData = snapshot.data![0] as Map<String, dynamic>;
        final medicalInfo = snapshot.data![1] as PatientMedicalInfo?;

        if (widget.isDesktop) {
          return _buildDesktopMedicalInfo(userData, medicalInfo);
        }

        return _buildMobileMedicalInfo(userData, medicalInfo);
      },
    );
  }

  Widget _buildMobileMedicalInfo(
    Map<String, dynamic> userData,
    PatientMedicalInfo? medicalInfo,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              _EditableInfoRow(
                label: 'Email',
                value: userData['email'] ?? 'Non renseigné',
                icon: CupertinoIcons.mail,
                onEdit: () =>
                    _showEditDialog('email', userData['email'] ?? '', 'email'),
              ),
              _EditableInfoRow(
                label: 'Téléphone',
                value: userData['phone'] ?? 'Non renseigné',
                icon: CupertinoIcons.phone,
                onEdit: () => _showEditDialog(
                  'numéro de téléphone',
                  userData['phone'] ?? '',
                  'phone',
                ),
              ),
              if (userData['dateOfBirth'] != null)
                _InfoRow(
                  label: 'Date de naissance',
                  value: DateFormat(
                    'dd/MM/yyyy',
                  ).format((userData['dateOfBirth'] as Timestamp).toDate()),
                  icon: CupertinoIcons.calendar,
                ),
              if (userData['gender'] != null)
                _InfoRow(
                  label: 'Genre',
                  value: userData['gender'] == 'male' ? 'Masculin' : 'Féminin',
                  icon: CupertinoIcons.person_2,
                ),
            ],
          ),
          const SizedBox(height: 16),
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
              if (medicalInfo != null && medicalInfo.emergencyContact != null)
                _InfoRow(
                  label: 'Contact d\'urgence',
                  value: medicalInfo.emergencyContact!,
                  icon: CupertinoIcons.phone_circle_fill,
                  valueColor: Colors.red,
                ),
            ],
          ),
          if (medicalInfo != null && medicalInfo.allergies.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Allergies',
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              iconColor: Colors.orange,
              children: medicalInfo.allergies
                  .map(
                    (allergy) => _ChipRow(label: allergy, color: Colors.orange),
                  )
                  .toList(),
            ),
          ],
          if (medicalInfo != null &&
              medicalInfo.chronicDiseases.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Maladies chroniques',
              icon: CupertinoIcons.heart_fill,
              iconColor: Colors.red,
              children: medicalInfo.chronicDiseases
                  .map((disease) => _ChipRow(label: disease, color: Colors.red))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopMedicalInfo(
    Map<String, dynamic> userData,
    PatientMedicalInfo? medicalInfo,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.doc_text_fill,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dossier Médical',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Informations personnelles et médicales',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Informations personnelles
          _DesktopInfoSection(
            title: 'Informations personnelles',
            icon: CupertinoIcons.person_fill,
            children: [
              _DesktopInfoRow(
                label: 'Nom complet',
                value:
                    '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
                icon: CupertinoIcons.person,
                isBold: true,
              ),
              _DesktopEditableInfoRow(
                label: 'Email',
                value: userData['email'] ?? 'Non renseigné',
                icon: CupertinoIcons.mail,
                onEdit: () =>
                    _showEditDialog('email', userData['email'] ?? '', 'email'),
              ),
              _DesktopEditableInfoRow(
                label: 'Téléphone',
                value: userData['phone'] ?? 'Non renseigné',
                icon: CupertinoIcons.phone,
                onEdit: () => _showEditDialog(
                  'numéro de téléphone',
                  userData['phone'] ?? '',
                  'phone',
                ),
              ),
              if (userData['dateOfBirth'] != null)
                _DesktopInfoRow(
                  label: 'Date de naissance',
                  value: DateFormat(
                    'dd/MM/yyyy',
                  ).format((userData['dateOfBirth'] as Timestamp).toDate()),
                  icon: CupertinoIcons.calendar,
                ),
              if (userData['gender'] != null)
                _DesktopInfoRow(
                  label: 'Genre',
                  value: userData['gender'] == 'male' ? 'Masculin' : 'Féminin',
                  icon: CupertinoIcons.person_2,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Informations médicales
          _DesktopInfoSection(
            title: 'Informations médicales',
            icon: CupertinoIcons.heart_fill,
            iconColor: Colors.red,
            children: [
              _DesktopInfoRow(
                label: 'Groupe sanguin',
                value: medicalInfo?.bloodGroup ?? 'Non renseigné',
                icon: CupertinoIcons.drop_fill,
                valueColor: Colors.red,
                isBold: true,
              ),
              _DesktopInfoRow(
                label: 'Taille',
                value: medicalInfo?.height != null
                    ? '${medicalInfo!.height!.toStringAsFixed(0)} cm'
                    : 'Non renseigné',
                icon: CupertinoIcons.arrow_up_down,
              ),
              _DesktopInfoRow(
                label: 'Poids',
                value: medicalInfo?.weight != null
                    ? '${medicalInfo!.weight!.toStringAsFixed(1)} kg'
                    : 'Non renseigné',
                icon: CupertinoIcons.infinite,
              ),
              if (medicalInfo != null && medicalInfo.emergencyContact != null)
                _DesktopInfoRow(
                  label: 'Contact d\'urgence',
                  value: medicalInfo.emergencyContact!,
                  icon: CupertinoIcons.phone_circle_fill,
                  valueColor: Colors.red,
                ),
            ],
          ),

          if (medicalInfo != null && medicalInfo.allergies.isNotEmpty) ...[
            const SizedBox(height: 20),
            _DesktopInfoSection(
              title: 'Allergies',
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              iconColor: Colors.orange,
              children: medicalInfo.allergies
                  .map(
                    (allergy) =>
                        _DesktopChipRow(label: allergy, color: Colors.orange),
                  )
                  .toList(),
            ),
          ],

          if (medicalInfo != null &&
              medicalInfo.chronicDiseases.isNotEmpty) ...[
            const SizedBox(height: 20),
            _DesktopInfoSection(
              title: 'Maladies chroniques',
              icon: CupertinoIcons.heart_fill,
              iconColor: Colors.red,
              children: medicalInfo.chronicDiseases
                  .map(
                    (disease) =>
                        _DesktopChipRow(label: disease, color: Colors.red),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// WIDGETS DESKTOP
class _DesktopInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;

  const _DesktopInfoSection({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _DesktopInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isBold;

  const _DesktopInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
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

class _DesktopEditableInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isBold;
  final VoidCallback onEdit;

  const _DesktopEditableInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isBold = false,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isBold
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: valueColor ?? Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.pencil,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopChipRow extends StatelessWidget {
  final String label;
  final Color color;

  const _DesktopChipRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HISTORIQUE CONSULTATIONS DESKTOP
class _DesktopConsultationHistory extends StatelessWidget {
  final String patientId;
  final String doctorId;

  const _DesktopConsultationHistory({
    required this.patientId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.clock_fill,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historique des Consultations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Toutes les consultations avec ce patient',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Liste des consultations
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('patientId', isEqualTo: patientId)
                .where('doctorId', isEqualTo: doctorId)
                .orderBy('date', descending: true)
                .snapshots()
                .handleError((error) {
                  print('🔴 ERREUR FIRESTORE: $error');
                  return Stream<QuerySnapshot>.empty();
                }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState(context);
              }

              final consultations = snapshot.data?.docs ?? [];

              if (consultations.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                itemCount: consultations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final consultation =
                      consultations[index].data() as Map<String, dynamic>;
                  return _DesktopConsultationCard(
                    consultation: consultation,
                    consultationId: consultations[index].id,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 60,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Index Firestore requis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Consultez la console pour le lien',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Créer l\'index Firestore'),
                  content: const SingleChildScrollView(
                    child: Text(
                      '1. Vérifiez la console (terminal)\n'
                      '2. Trouvez le lien "https://console.firebase.google.com/..."\n'
                      '3. Cliquez sur ce lien\n'
                      '4. Firebase créera l\'index automatiquement',
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.doc_text, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucune consultation',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// CARD CONSULTATION DESKTOP
class _DesktopConsultationCard extends StatelessWidget {
  final Map<String, dynamic> consultation;
  final String consultationId;

  const _DesktopConsultationCard({
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
    final isTelemedicine =
        type.toLowerCase().contains('telemedicine') ||
        type.toLowerCase().contains('téléconsultation');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _showDesktopConsultationDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isTelemedicine
                          ? AppColors.accent.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isTelemedicine
                          ? CupertinoIcons.videocam_fill
                          : CupertinoIcons.building_2_fill,
                      color: isTelemedicine
                          ? AppColors.accent
                          : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 13,
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
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.doc_text,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDesktopConsultationDetails(BuildContext context) {
    final consultationDate = (consultation['date'] as Timestamp).toDate();
    final formattedDate = DateFormat(
      'EEEE d MMMM yyyy',
      'fr_FR',
    ).format(consultationDate);
    final formattedTime = DateFormat('HH:mm').format(consultationDate);
    final reason = consultation['reason'] ?? 'Non spécifiée';
    final type = consultation['type'] ?? '';
    final diagnosis = consultation['diagnosis'] ?? 'Non renseigné';
    final prescription = consultation['prescription'] ?? 'Aucune ordonnance';
    final notes = consultation['notes'] ?? '';
    final isTelemedicine =
        type.toLowerCase().contains('telemedicine') ||
        type.toLowerCase().contains('téléconsultation');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTelemedicine
                            ? CupertinoIcons.videocam_fill
                            : CupertinoIcons.building_2_fill,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Détails de la consultation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _DesktopDetailCard(
                      icon: CupertinoIcons.calendar,
                      title: 'Date et heure',
                      content: '$formattedDate à $formattedTime',
                    ),
                    _DesktopDetailCard(
                      icon: isTelemedicine
                          ? CupertinoIcons.videocam_fill
                          : CupertinoIcons.building_2_fill,
                      title: 'Type',
                      content: isTelemedicine ? 'Téléconsultation' : 'Cabinet',
                    ),
                    _DesktopDetailCard(
                      icon: CupertinoIcons.doc_text,
                      title: 'Raison',
                      content: reason,
                    ),
                    _DesktopDetailCard(
                      icon: CupertinoIcons.check_mark_circled,
                      title: 'Diagnostic',
                      content: diagnosis,
                    ),
                    _DesktopDetailCard(
                      icon: CupertinoIcons.square_list,
                      title: 'Ordonnance',
                      content: prescription,
                    ),
                    if (notes.isNotEmpty)
                      _DesktopDetailCard(
                        icon: CupertinoIcons.text_bubble,
                        title: 'Notes',
                        content: notes,
                      ),
                    const SizedBox(height: 32),
                    consultation['status'] != 'completed'
                        ? Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(CupertinoIcons.play_circle_fill),
                              label: const Text('Démarrer la consultation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientConsultationPage(
                                          patientId:
                                              consultation['patientId'] ?? '',
                                          patientName:
                                              consultation['patientName'] ?? '',
                                        ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
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

// CARTE DETAIL POUR MODAL DESKTOP
class _DesktopDetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color? contentColor;

  const _DesktopDetailCard({
    required this.icon,
    required this.title,
    required this.content,
    this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
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
              fontSize: 14,
              color: contentColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// HISTORIQUE MOBILE (INCHANGÉ)
class _ConsultationHistoryTab extends StatelessWidget {
  final String patientId;
  final String doctorId;

  const _ConsultationHistoryTab({
    required this.patientId,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('date', descending: true)
          .snapshots()
          .handleError((error) {
            print('🔴 ERREUR FIRESTORE: $error');
            return Stream<QuerySnapshot>.empty();
          }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
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

// WIDGETS MOBILES (INCHANGÉS)
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[700]),
          ),
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

class _EditableInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback onEdit;

  const _EditableInfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[700]),
          ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(15),
                          fontWeight: FontWeight.w500,
                          color: valueColor ?? Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.pencil,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final Color color;

  const _ChipRow({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(8)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(12),
          vertical: getProportionateScreenHeight(8),
        ),
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
    final isTelemedicine =
        type.toLowerCase().contains('telemedicine') ||
        type.toLowerCase().contains('téléconsultation');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showConsultationDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          isTelemedicine ? 'Télé' : 'Cabinet',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isTelemedicine
                                ? AppColors.accent
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _DetailRow(
                icon: CupertinoIcons.doc_text,
                label: 'Raison',
                value: reason,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: CupertinoIcons.info_circle,
                label: 'Statut',
                value: _getStatusLabel(status),
                valueColor: _getStatusColor(status),
              ),
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
    final consultationDate = (consultation['date'] as Timestamp).toDate();
    final formattedDate = DateFormat(
      'EEEE d MMMM yyyy',
      'fr_FR',
    ).format(consultationDate);
    final formattedTime = DateFormat('HH:mm').format(consultationDate);
    final reason = consultation['reason'] ?? 'Non spécifiée';
    final type = consultation['type'] ?? '';
    final diagnosis = consultation['diagnosis'] ?? 'Non renseigné';
    final prescription = consultation['prescription'] ?? 'Aucune ordonnance';
    final notes = consultation['notes'] ?? '';
    final isTelemedicine =
        type.toLowerCase().contains('telemedicine') ||
        type.toLowerCase().contains('téléconsultation');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTelemedicine
                            ? CupertinoIcons.videocam_fill
                            : CupertinoIcons.building_2_fill,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Détails de la consultation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  shrinkWrap: true,
                  children: [
                    _DetailCard(
                      icon: CupertinoIcons.calendar,
                      title: 'Date et heure',
                      content: '$formattedDate à $formattedTime',
                    ),
                    _DetailCard(
                      icon: isTelemedicine
                          ? CupertinoIcons.videocam_fill
                          : CupertinoIcons.building_2_fill,
                      title: 'Type de consultation',
                      content: isTelemedicine
                          ? 'Téléconsultation'
                          : 'Consultation au cabinet',
                    ),
                    _DetailCard(
                      icon: CupertinoIcons.doc_text,
                      title: 'Raison de consultation',
                      content: reason,
                    ),
                    _DetailCard(
                      icon: CupertinoIcons.check_mark_circled,
                      title: 'Diagnostic',
                      content: diagnosis,
                    ),
                    _DetailCard(
                      icon: CupertinoIcons.square_list,
                      title: 'Ordonnance',
                      content: prescription,
                    ),
                    if (notes.isNotEmpty)
                      _DetailCard(
                        icon: CupertinoIcons.text_bubble,
                        title: 'Notes',
                        content: notes,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
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
              fontSize: 14,
              color: contentColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
