import 'package:DoctoLo/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';

class ProfessionalExperiencePage extends StatefulWidget {
  const ProfessionalExperiencePage({super.key});

  @override
  State<ProfessionalExperiencePage> createState() =>
      _ProfessionalExperiencePageState();
}

class _ProfessionalExperiencePageState extends State<ProfessionalExperiencePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = true;

  List<Map<String, dynamic>> _education = [];
  List<Map<String, dynamic>> _experiences = [];
  List<Map<String, dynamic>> _certifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_currentUserId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _education = List<Map<String, dynamic>>.from(data['education'] ?? []);
          _experiences = List<Map<String, dynamic>>.from(
            data['experiences'] ?? [],
          );
          _certifications = List<Map<String, dynamic>>.from(
            data['certifications'] ?? [],
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Erreur chargement données: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveData() async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_currentUserId)
          .set({
            'education': _education,
            'experiences': _experiences,
            'certifications': _certifications,
          }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Données sauvegardées avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.professionalExperience),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Études',
              icon: Icon(
                CupertinoIcons.book,
                size: getProportionateScreenHeight(20),
              ),
            ),
            Tab(
              text: 'Expériences',
              icon: Icon(
                CupertinoIcons.briefcase_fill,
                size: getProportionateScreenHeight(20),
              ),
            ),
            Tab(
              text: 'Certifications',
              icon: Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: getProportionateScreenHeight(20),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _EducationTab(
                  education: _education,
                  onAdd: _addEducation,
                  onEdit: _editEducation,
                  onDelete: _deleteEducation,
                ),
                _ExperienceTab(
                  experiences: _experiences,
                  onAdd: _addExperience,
                  onEdit: _editExperience,
                  onDelete: _deleteExperience,
                ),
                _CertificationTab(
                  certifications: _certifications,
                  onAdd: _addCertification,
                  onEdit: _editCertification,
                  onDelete: _deleteCertification,
                ),
              ],
            ),
    );
  }

  // Helper to show modal based on screen size
  Future<T?> _showAdaptiveModal<T>({
    required Widget Function(BuildContext) builder,
  }) async {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    if (isLargeScreen) {
      // Show Cupertino dialog on large screens
      return showCupertinoDialog<T>(context: context, builder: builder);
    } else {
      // Show Cupertino modal bottom sheet on mobile
      return showCupertinoModalPopup<T>(context: context, builder: builder);
    }
  }

  // EDUCATION
  void _addEducation() async {
    final result = await _showAdaptiveModal<Map<String, dynamic>>(
      builder: (context) => _EducationDialog(),
    );

    if (result != null) {
      setState(() {
        _education.add(result);
      });
      _saveData();
    }
  }

  void _editEducation(int index) async {
    final result = await _showAdaptiveModal<Map<String, dynamic>>(
      builder: (context) => _EducationDialog(education: _education[index]),
    );

    if (result != null) {
      setState(() {
        _education[index] = result;
      });
      _saveData();
    }
  }

  void _deleteEducation(int index) {
    setState(() {
      _education.removeAt(index);
    });
    _saveData();
  }

  // EXPERIENCE
  void _addExperience() async {
    final result = await _showAdaptiveModal<Map<String, dynamic>>(
      builder: (context) => _ExperienceDialog(),
    );

    if (result != null) {
      setState(() {
        _experiences.add(result);
      });
      _saveData();
    }
  }

  void _editExperience(int index) async {
    final result = await _showAdaptiveModal<Map<String, dynamic>>(
      builder: (context) => _ExperienceDialog(experience: _experiences[index]),
    );

    if (result != null) {
      setState(() {
        _experiences[index] = result;
      });
      _saveData();
    }
  }

  void _deleteExperience(int index) {
    setState(() {
      _experiences.removeAt(index);
    });
    _saveData();
  }

  // CERTIFICATION
  void _addCertification() async {
    final result = await _showAdaptiveModal<Map<String, dynamic>>(
      builder: (context) => _CertificationDialog(),
    );

    if (result != null) {
      setState(() {
        _certifications.add(result);
      });
      _saveData();
    }
  }

  void _editCertification(int index) async {
    final result = await _showAdaptiveModal<Map<String, dynamic>>(
      builder: (context) =>
          _CertificationDialog(certification: _certifications[index]),
    );

    if (result != null) {
      setState(() {
        _certifications[index] = result;
      });
      _saveData();
    }
  }

  void _deleteCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
    _saveData();
  }
}

// EDUCATION TAB
class _EducationTab extends StatelessWidget {
  final List<Map<String, dynamic>> education;
  final VoidCallback onAdd;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const _EducationTab({
    required this.education,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(CupertinoIcons.add),
            label: const Text('Ajouter une formation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: education.isEmpty
              ? _buildEmptyState(
                  icon: CupertinoIcons.book,
                  message: 'Aucune formation ajoutée',
                )
              : ListView.separated(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  itemCount: education.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = education[index];
                    return _EducationCard(
                      degree: item['degree'] ?? '',
                      institution: item['institution'] ?? '',
                      startYear: item['startYear'] ?? '',
                      endYear: item['endYear'] ?? '',
                      description: item['description'] ?? '',
                      onEdit: () => onEdit(index),
                      onDelete: () => onDelete(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EducationCard extends StatelessWidget {
  final String degree;
  final String institution;
  final String startYear;
  final String endYear;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EducationCard({
    required this.degree,
    required this.institution,
    required this.startYear,
    required this.endYear,
    required this.description,
    required this.onEdit,
    required this.onDelete,
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
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(8)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        degree,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        institution,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(14),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    CupertinoIcons.ellipsis_vertical,
                    size: getProportionateScreenHeight(20),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            size: getProportionateScreenHeight(20),
                          ),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          const Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.trash,
                            size: 20,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '$startYear - $endYear',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(13),
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(14),
                  color: Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// EXPERIENCE TAB
class _ExperienceTab extends StatelessWidget {
  final List<Map<String, dynamic>> experiences;
  final VoidCallback onAdd;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const _ExperienceTab({
    required this.experiences,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(CupertinoIcons.add),
            label: const Text('Ajouter une expérience'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: experiences.isEmpty
              ? _buildEmptyState(
                  icon: CupertinoIcons.briefcase_fill,
                  message: 'Aucune expérience ajoutée',
                )
              : ListView.separated(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  itemCount: experiences.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = experiences[index];
                    return _ExperienceCard(
                      position: item['position'] ?? '',
                      organization: item['organization'] ?? '',
                      startDate: item['startDate'] ?? '',
                      endDate: item['endDate'] ?? '',
                      current: item['current'] ?? false,
                      description: item['description'] ?? '',
                      onEdit: () => onEdit(index),
                      onDelete: () => onDelete(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final String position;
  final String organization;
  final String startDate;
  final String endDate;
  final bool current;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.position,
    required this.organization,
    required this.startDate,
    required this.endDate,
    required this.current,
    required this.description,
    required this.onEdit,
    required this.onDelete,
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
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(8)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        position,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        organization,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(14),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (current)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Actuel',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: getProportionateScreenHeight(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: Icon(
                    CupertinoIcons.ellipsis_vertical,
                    size: getProportionateScreenHeight(20),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            size: getProportionateScreenHeight(20),
                          ),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          const Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.trash,
                            size: 20,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  current ? '$startDate - Présent' : '$startDate - $endDate',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(13),
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(14),
                  color: Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// CERTIFICATION TAB
class _CertificationTab extends StatelessWidget {
  final List<Map<String, dynamic>> certifications;
  final VoidCallback onAdd;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const _CertificationTab({
    required this.certifications,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(CupertinoIcons.add),
            label: const Text('Ajouter une certification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: certifications.isEmpty
              ? _buildEmptyState(
                  icon: CupertinoIcons.checkmark_seal_fill,
                  message: 'Aucune certification ajoutée',
                )
              : ListView.separated(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  itemCount: certifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = certifications[index];
                    return _CertificationCard(
                      name: item['name'] ?? '',
                      issuer: item['issuer'] ?? '',
                      date: item['date'] ?? '',
                      credentialId: item['credentialId'] ?? '',
                      onEdit: () => onEdit(index),
                      onDelete: () => onDelete(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CertificationCard extends StatelessWidget {
  final String name;
  final String issuer;
  final String date;
  final String credentialId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CertificationCard({
    required this.name,
    required this.issuer,
    required this.date,
    required this.credentialId,
    required this.onEdit,
    required this.onDelete,
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
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(8)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issuer,
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(14),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(
                    CupertinoIcons.ellipsis_vertical,
                    size: getProportionateScreenHeight(20),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            size: getProportionateScreenHeight(20),
                          ),
                          SizedBox(width: getProportionateScreenWidth(8)),
                          const Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.trash,
                            size: 20,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(13),
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (credentialId.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.tag_fill,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ID: $credentialId',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// DIALOGS
class _EducationDialog extends StatefulWidget {
  final Map<String, dynamic>? education;

  const _EducationDialog({this.education});

  @override
  State<_EducationDialog> createState() => _EducationDialogState();
}

class _EducationDialogState extends State<_EducationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _degreeController;
  late TextEditingController _institutionController;
  late TextEditingController _startYearController;
  late TextEditingController _endYearController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _degreeController = TextEditingController(
      text: widget.education?['degree'] ?? '',
    );
    _institutionController = TextEditingController(
      text: widget.education?['institution'] ?? '',
    );
    _startYearController = TextEditingController(
      text: widget.education?['startYear'] ?? '',
    );
    _endYearController = TextEditingController(
      text: widget.education?['endYear'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.education?['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    final content = _buildFormContent();

    if (isLargeScreen) {
      // Dialog style for large screens
      return CupertinoAlertDialog(
        title: Text(
          widget.education == null
              ? 'Ajouter une formation'
              : 'Modifier la formation',
        ),
        content: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: getProportionateScreenHeight(12)),
              child: content,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: _saveForm,
            child: const Text('Enregistrer'),
          ),
        ],
      );
    } else {
      // Bottom sheet style for mobile
      return CupertinoActionSheet(
        title: Text(
          widget.education == null
              ? 'Ajouter une formation'
              : 'Modifier la formation',
          style: TextStyle(
            fontSize: getProportionateScreenHeight(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(child: content),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: _saveForm,
            isDefaultAction: true,
            child: const Text('Enregistrer'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      );
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'degree': _degreeController.text,
        'institution': _institutionController.text,
        'startYear': _startYearController.text,
        'endYear': _endYearController.text,
        'description': _descriptionController.text,
      });
    }
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoTextField(
            controller: _degreeController,
            placeholder: 'Ex: Doctorat en Médecine',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Diplôme *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _institutionController,
            placeholder: 'Ex: Université de Paris',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Établissement *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _startYearController,
                  placeholder: '2015',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('Début *'),
                  ),
                  padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                  keyboardType: TextInputType.number,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoTextField(
                  controller: _endYearController,
                  placeholder: '2021',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('Fin *'),
                  ),
                  padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                  keyboardType: TextInputType.number,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _descriptionController,
            placeholder: 'Mention, spécialisation...',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Description'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            maxLines: 3,
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceDialog extends StatefulWidget {
  final Map<String, dynamic>? experience;

  const _ExperienceDialog({this.experience});

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _positionController;
  late TextEditingController _organizationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descriptionController;
  late bool _current;

  @override
  void initState() {
    super.initState();
    _positionController = TextEditingController(
      text: widget.experience?['position'] ?? '',
    );
    _organizationController = TextEditingController(
      text: widget.experience?['organization'] ?? '',
    );
    _startDateController = TextEditingController(
      text: widget.experience?['startDate'] ?? '',
    );
    _endDateController = TextEditingController(
      text: widget.experience?['endDate'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.experience?['description'] ?? '',
    );
    _current = widget.experience?['current'] ?? false;
  }

  @override
  void dispose() {
    _positionController.dispose();
    _organizationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    final content = _buildFormContent();

    if (isLargeScreen) {
      // Dialog style for large screens
      return CupertinoAlertDialog(
        title: Text(
          widget.experience == null
              ? 'Ajouter une expérience'
              : 'Modifier l\'expérience',
        ),
        content: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: getProportionateScreenHeight(12)),
              child: content,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: _saveForm,
            child: const Text('Enregistrer'),
          ),
        ],
      );
    } else {
      // Bottom sheet style for mobile
      return CupertinoActionSheet(
        title: Text(
          widget.experience == null
              ? 'Ajouter une expérience'
              : 'Modifier l\'expérience',
          style: TextStyle(
            fontSize: getProportionateScreenHeight(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(child: content),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: _saveForm,
            isDefaultAction: true,
            child: const Text('Enregistrer'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      );
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'position': _positionController.text,
        'organization': _organizationController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'current': _current,
        'description': _descriptionController.text,
      });
    }
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoTextField(
            controller: _positionController,
            placeholder: 'Ex: Médecin généraliste',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Poste *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _organizationController,
            placeholder: 'Ex: Hôpital Saint-Louis',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Organisation *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _startDateController,
                  placeholder: 'Janv. 2020',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('Début *'),
                  ),
                  padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoTextField(
                  controller: _endDateController,
                  placeholder: 'Déc. 2023',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('Fin'),
                  ),
                  padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                  enabled: !_current,
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.systemGrey4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CupertinoListTile(
              title: const Text('Poste actuel'),
              trailing: CupertinoSwitch(
                value: _current,
                onChanged: (value) {
                  setState(() {
                    _current = value;
                    if (_current) {
                      _endDateController.clear();
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _descriptionController,
            placeholder: 'Responsabilités, réalisations...',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Description'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            maxLines: 3,
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificationDialog extends StatefulWidget {
  final Map<String, dynamic>? certification;

  const _CertificationDialog({this.certification});

  @override
  State<_CertificationDialog> createState() => _CertificationDialogState();
}

class _CertificationDialogState extends State<_CertificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _issuerController;
  late TextEditingController _dateController;
  late TextEditingController _credentialIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.certification?['name'] ?? '',
    );
    _issuerController = TextEditingController(
      text: widget.certification?['issuer'] ?? '',
    );
    _dateController = TextEditingController(
      text: widget.certification?['date'] ?? '',
    );
    _credentialIdController = TextEditingController(
      text: widget.certification?['credentialId'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _credentialIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    final content = _buildFormContent();

    if (isLargeScreen) {
      // Dialog style for large screens
      return CupertinoAlertDialog(
        title: Text(
          widget.certification == null
              ? 'Ajouter une certification'
              : 'Modifier la certification',
        ),
        content: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: getProportionateScreenHeight(12)),
              child: content,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: _saveForm,
            child: const Text('Enregistrer'),
          ),
        ],
      );
    } else {
      // Bottom sheet style for mobile
      return CupertinoActionSheet(
        title: Text(
          widget.certification == null
              ? 'Ajouter une certification'
              : 'Modifier la certification',
          style: TextStyle(
            fontSize: getProportionateScreenHeight(16),
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(child: content),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: _saveForm,
            isDefaultAction: true,
            child: const Text('Enregistrer'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      );
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text,
        'issuer': _issuerController.text,
        'date': _dateController.text,
        'credentialId': _credentialIdController.text,
      });
    }
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Ex: Certification en Cardiologie',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Nom *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _issuerController,
            placeholder: 'Ex: Collège de Cardiologie',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Organisme *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _dateController,
            placeholder: 'Ex: Juin 2022',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Date *'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _credentialIdController,
            placeholder: 'Ex: CERT-2022-1234',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('ID'),
            ),
            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildEmptyState({required IconData icon, required String message}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(16),
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
