import 'package:DoctoLo/features/appointment/presentation/pages/appointment_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../shared/widgets/responsive_layout.dart';

class DoctorProfilePage extends StatefulWidget {
  final String userId;
  final String doctorId;

  const DoctorProfilePage({
    super.key,
    required this.userId,
    required this.doctorId,
  });

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _doctorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      setState(() {
        _userData = userDoc.data();
        _doctorData = doctorDoc.data();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _userData?['firstName'] ?? '';
    final lastName = _userData?['lastName'] ?? '';
    final photoUrl = _userData?['photoUrl'];
    final specialty = _doctorData?['specialty'] ?? 'Spécialité non renseignée';
    final bio = _doctorData?['bio'] ?? '';
    final consultationFee = (_doctorData?['consultationFee'] ?? 0.0).toDouble();
    final teleconsultationFee = (_doctorData?['teleconsultationFee'] ?? 0.0)
        .toDouble();
    final offersTelemedicine = _doctorData?['offersTelemedicine'] ?? false;
    final offersPhysicalConsultation =
        _doctorData?['offersPhysicalConsultation'] ?? true;
    final qualifications = List<String>.from(
      _doctorData?['qualifications'] ?? [],
    );
    final documents = List<Map<String, dynamic>>.from(
      _doctorData?['documents'] ?? [],
    );
    final education = List<Map<String, dynamic>>.from(
      _doctorData?['education'] ?? [],
    );
    final experiences = List<Map<String, dynamic>>.from(
      _doctorData?['experiences'] ?? [],
    );
    final certifications = List<Map<String, dynamic>>.from(
      _doctorData?['certifications'] ?? [],
    );

    // Calculer les années d'expérience dynamiquement
    int yearsOfExperience = 0;
    if (experiences.isNotEmpty) {
      int? earliestYear;
      for (final exp in experiences) {
        final startDate = exp['startDate']?.toString() ?? '';
        // Extraire l'année du format "Janv. 2020" ou "2020"
        final yearMatch = RegExp(r'(\d{4})').firstMatch(startDate);
        if (yearMatch != null) {
          final year = int.parse(yearMatch.group(1)!);
          if (earliestYear == null || year < earliestYear) {
            earliestYear = year;
          }
        }
      }
      if (earliestYear != null) {
        yearsOfExperience = DateTime.now().year - earliestYear;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec photo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Hero(
                          tag: 'doctor_${widget.userId}',
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl == null
                                ? const Icon(
                                    CupertinoIcons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dr. $firstName $lastName',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getProportionateScreenHeight(24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: getProportionateScreenHeight(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Statistiques rapides
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ResponsiveRow(
                    spacing: 8,
                    children: [
                      _StatItem(
                        icon: CupertinoIcons.briefcase,
                        value: '$yearsOfExperience',
                        label: 'ans d\'expérience',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                // Types de consultation
                Padding(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Types de consultation',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ResponsiveRow(
                        spacing: 12,
                        children: [
                          if (offersPhysicalConsultation)
                            _ConsultationTypeCard(
                              icon: CupertinoIcons.plus_circle,
                              title: 'Consultation au cabinet',
                              price: consultationFee,
                              color: AppColors.primary,
                            ),
                          if (offersTelemedicine)
                            _ConsultationTypeCard(
                              icon: CupertinoIcons.videocam_fill,
                              title: 'Téléconsultation',
                              price: teleconsultationFee,
                              color: AppColors.accent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // À propos
                if (bio.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'À propos',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(
                            getProportionateScreenWidth(16),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            bio,
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(15),
                              height: 1.5,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Qualifications
                if (qualifications.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Qualifications',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...qualifications.map(
                          (qual) => Padding(
                            padding: EdgeInsets.only(
                              bottom: getProportionateScreenHeight(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.checkmark_circle,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    qual,
                                    style: TextStyle(
                                      fontSize: getProportionateScreenHeight(
                                        15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Formation académique
                if (education.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Formation académique',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...education.map(
                          (edu) => Card(
                            margin: EdgeInsets.only(
                              bottom: getProportionateScreenHeight(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenWidth(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      getProportionateScreenWidth(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.book,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          edu['degree'] ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  16,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          edu['institution'] ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  14,
                                                ),
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.calendar,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${edu['startYear']} - ${edu['endYear']}',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                      13,
                                                    ),
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (edu['description']?.isNotEmpty ??
                                            false) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            edu['description'],
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                    14,
                                                  ),
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Expériences professionnelles
                if (experiences.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expériences professionnelles',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...experiences.map(
                          (exp) => Card(
                            margin: EdgeInsets.only(
                              bottom: getProportionateScreenHeight(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenWidth(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      getProportionateScreenWidth(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.briefcase_fill,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                exp['position'] ?? '',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        16,
                                                      ),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (exp['current'] == true)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'Actuel',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize:
                                                        getProportionateScreenHeight(
                                                          11,
                                                        ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          exp['organization'] ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  14,
                                                ),
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.calendar,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              exp['current'] == true
                                                  ? '${exp['startDate']} - Présent'
                                                  : '${exp['startDate']} - ${exp['endDate']}',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                      13,
                                                    ),
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (exp['description']?.isNotEmpty ??
                                            false) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            exp['description'],
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                    14,
                                                  ),
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Certifications
                if (certifications.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certifications',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...certifications.map(
                          (cert) => Card(
                            margin: EdgeInsets.only(
                              bottom: getProportionateScreenHeight(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                getProportionateScreenWidth(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      getProportionateScreenWidth(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.checkmark_seal_fill,
                                      color: Colors.amber,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cert['name'] ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  16,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cert['issuer'] ?? '',
                                          style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(
                                                  14,
                                                ),
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.calendar,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              cert['date'] ?? '',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                      13,
                                                    ),
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (cert['credentialId']?.isNotEmpty ??
                                            false) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.tag_fill,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'ID: ${cert['credentialId']}',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                        12,
                                                      ),
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Documents (CV, diplômes)
                if (documents.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Documents professionnels',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...documents.map(
                          (doc) => Card(
                            margin: EdgeInsets.only(
                              bottom: getProportionateScreenHeight(8),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.secondary
                                    .withOpacity(0.1),
                                child: Icon(
                                  _getDocIcon(doc['type']),
                                  color: AppColors.secondary,
                                ),
                              ),
                              title: Text(doc['name'] ?? 'Document'),
                              subtitle: Text(_getDocTypeLabel(doc['type'])),
                              trailing: IconButton(
                                icon: const Icon(
                                  CupertinoIcons.arrow_up_right_square,
                                ),
                                onPressed: () async {
                                  final url = doc['url'];
                                  if (url != null) {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Impossible d\'ouvrir le document',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentBookingPage(
                    userId: widget.userId,
                    doctorId: widget.doctorId,
                    doctorName: 'Dr. $firstName $lastName',
                    specialty: specialty,
                    photoUrl: photoUrl,
                    consultationFee: consultationFee,
                    teleconsultationFee: teleconsultationFee,
                    offersPhysicalConsultation: offersPhysicalConsultation,
                    offersTelemedicine: offersTelemedicine,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                vertical: getProportionateScreenHeight(16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Prendre rendez-vous',
              style: TextStyle(
                fontSize: getProportionateScreenHeight(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDocIcon(String type) {
    switch (type) {
      case 'cv':
        return CupertinoIcons.doc_text;
      case 'diploma':
        return CupertinoIcons.book;
      case 'certification':
        return CupertinoIcons.checkmark_seal_fill;
      default:
        return CupertinoIcons.folder_fill;
    }
  }

  String _getDocTypeLabel(String type) {
    switch (type) {
      case 'cv':
        return 'CV';
      case 'diploma':
        return 'Diplôme';
      case 'certification':
        return 'Certification';
      default:
        return 'Autre';
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 16,
        horizontal: isMobile ? 8 : 16,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isMobile ? 24 : 28),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: getProportionateScreenHeight(isMobile ? 18 : 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: getProportionateScreenHeight(isMobile ? 11 : 12),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConsultationTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double price;
  final Color color;

  const _ConsultationTypeCard({
    required this.icon,
    required this.title,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(0)} XOF',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(18),
                    fontWeight: FontWeight.bold,
                    color: color,
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
