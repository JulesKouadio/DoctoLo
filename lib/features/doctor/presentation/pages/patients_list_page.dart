import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'patient_detail_page.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final _currentDoctorId = FirebaseAuth.instance.currentUser?.uid;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  String _selectedPeriod = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _selectedPeriod = 'custom';
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _selectedPeriod = 'custom';
      });
    }
  }

  void _setPeriod(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
          );
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'all':
          _startDate = null;
          _endDate = null;
          break;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _selectedPeriod = 'all';
      _searchController.clear();
    });
  }

  Stream<QuerySnapshot> _getPatientsStream() {
    Query query = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: _currentDoctorId);

    if (_startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
      );
    }
    if (_endDate != null) {
      final endDateTime = _endDate!.add(const Duration(days: 1));
      query = query.where('date', isLessThan: Timestamp.fromDate(endDateTime));
    }

    return query.orderBy('date', descending: true).snapshots().handleError((
      error,
    ) {
      print('🔴 ERREUR FIRESTORE: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final deviceType = context.deviceType;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return Scaffold(
      backgroundColor: isDesktop || isTablet ? Colors.grey[50] : Colors.white,
      appBar: _buildAppBar(l10n, isDesktop, isTablet),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1400 : (isTablet ? 1000 : double.infinity),
          ),
          child: Column(
            children: [
              if (isDesktop || isTablet)
                _buildDesktopFilters(isDesktop)
              else
                _buildMobileFilters(),
              Expanded(child: _buildPatientsList(deviceType)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    if (isDesktop || isTablet) {
      return AppBar(
        title: Text(
          l10n.patientsList,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 70,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      );
    }

    return AppBar(
      title: Text(l10n.patientsList),
      backgroundColor: AppColors.primary,
      elevation: 0,
    );
  }

  // LAYOUT DESKTOP/TABLETTE MODERNE
  Widget _buildDesktopFilters(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Filtres et recherche',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Barre de recherche + boutons de période
          Row(
            children: [
              Expanded(flex: 2, child: _buildModernSearchField()),
              const SizedBox(width: 24),
              Expanded(flex: 3, child: _buildModernPeriodButtons()),
            ],
          ),
          const SizedBox(height: 20),

          // Sélecteurs de dates + Stats rapides
          Row(
            children: [
              Expanded(child: _buildModernDateSelectors()),
              if (isDesktop) ...[const SizedBox(width: 24), _buildQuickStats()],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un patient par nom...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Colors.grey[600],
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildModernPeriodButtons() {
    return Row(
      children: [
        Expanded(
          child: _ModernPeriodButton(
            label: 'Tout',
            isSelected: _selectedPeriod == 'all',
            onTap: () => _setPeriod('all'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModernPeriodButton(
            label: 'Aujourd\'hui',
            isSelected: _selectedPeriod == 'today',
            onTap: () => _setPeriod('today'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModernPeriodButton(
            label: 'Semaine',
            isSelected: _selectedPeriod == 'week',
            onTap: () => _setPeriod('week'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModernPeriodButton(
            label: 'Mois',
            isSelected: _selectedPeriod == 'month',
            onTap: () => _setPeriod('month'),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDateSelectors() {
    return Row(
      children: [
        Expanded(
          child: _ModernDateButton(
            label: 'Date de début',
            date: _startDate,
            onTap: _selectStartDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernDateButton(
            label: 'Date de fin',
            date: _endDate,
            onTap: _selectEndDate,
          ),
        ),
        if (_startDate != null || _searchQuery.isNotEmpty) ...[
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: IconButton(
              onPressed: _clearFilters,
              icon: const Icon(CupertinoIcons.xmark, size: 20),
              color: Colors.red[700],
              tooltip: 'Effacer les filtres',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPatientsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final appointments = snapshot.data?.docs ?? [];
        final uniquePatients = <String>{};
        for (var doc in appointments) {
          final appointment = doc.data() as Map<String, dynamic>;
          final patientId = appointment['patientId'];
          if (patientId != null) uniquePatients.add(patientId);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.person_2_fill,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${uniquePatients.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Patient${uniquePatients.length > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // LAYOUT MOBILE (INCHANGÉ)
  Widget _buildMobileFilters() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildPeriodButtons(),
          const SizedBox(height: 12),
          _buildDateSelectors(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher un patient...',
        prefixIcon: const Icon(CupertinoIcons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle_fill),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildPeriodButtons() {
    return Row(
      children: [
        Expanded(
          child: _PeriodButton(
            label: 'Tout',
            isSelected: _selectedPeriod == 'all',
            onTap: () => _setPeriod('all'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PeriodButton(
            label: 'Aujourd\'hui',
            isSelected: _selectedPeriod == 'today',
            onTap: () => _setPeriod('today'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PeriodButton(
            label: 'Semaine',
            isSelected: _selectedPeriod == 'week',
            onTap: () => _setPeriod('week'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PeriodButton(
            label: 'Mois',
            isSelected: _selectedPeriod == 'month',
            onTap: () => _setPeriod('month'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _selectStartDate,
            icon: const Icon(CupertinoIcons.calendar, size: 18),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Du',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _startDate != null
                      ? DateFormat('dd-MM-yyyy').format(_startDate!)
                      : 'Date début',
                  style: TextStyle(fontSize: getProportionateScreenHeight(12)),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: _startDate != null
                    ? AppColors.primary
                    : Colors.grey[300]!,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _selectEndDate,
            icon: const Icon(CupertinoIcons.calendar, size: 18),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Au',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _endDate != null
                      ? DateFormat('dd-MM-yyyy').format(_endDate!)
                      : 'Date fin',
                  style: TextStyle(fontSize: getProportionateScreenHeight(12)),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: _endDate != null ? AppColors.primary : Colors.grey[300]!,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        if (_startDate != null || _searchQuery.isNotEmpty) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: _clearFilters,
            icon: const Icon(CupertinoIcons.xmark_circle),
            color: Colors.red,
            tooltip: 'Effacer les filtres',
          ),
        ],
      ],
    );
  }

  Widget _buildPatientsList(DeviceType deviceType) {
    final isDesktop = deviceType == DeviceType.desktop;
    final isTablet = deviceType == DeviceType.tablet;
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return StreamBuilder<QuerySnapshot>(
      stream: _getPatientsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erreur Firestore',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vérifiez la console pour plus de détails',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(CupertinoIcons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return _buildEmptyState('Aucun patient', isDesktop || isTablet);
        }

        final appointments = snapshot.data?.docs ?? [];
        final Map<String, Map<String, dynamic>> uniquePatients = {};

        for (var doc in appointments) {
          final appointment = doc.data() as Map<String, dynamic>;
          final patientId = appointment['patientId'];
          final patientName = (appointment['patientName'] ?? '').toLowerCase();

          if (_searchQuery.isNotEmpty && !patientName.contains(_searchQuery))
            continue;

          if (patientId != null) {
            if (!uniquePatients.containsKey(patientId)) {
              uniquePatients[patientId] = {
                'patientId': patientId,
                'patientName': appointment['patientName'],
                'lastConsultationDate': (appointment['date'] as Timestamp)
                    .toDate(),
                'consultationsCount': 1,
                'appointments': [appointment],
              };
            } else {
              uniquePatients[patientId]!['consultationsCount']++;
              uniquePatients[patientId]!['appointments'].add(appointment);
            }
          }
        }

        if (uniquePatients.isEmpty) {
          return _buildEmptyState(
            _searchQuery.isNotEmpty || _startDate != null
                ? 'Aucun patient trouvé'
                : 'Aucun patient',
            isDesktop || isTablet,
          );
        }

        final patientsList = uniquePatients.values.toList();
        final padding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);

        if (crossAxisCount > 1) {
          return GridView.builder(
            padding: EdgeInsets.all(padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: isDesktop ? 1.2 : 1.1,
            ),
            itemCount: patientsList.length,
            itemBuilder: (context, index) {
              final patient = patientsList[index];
              return _DesktopPatientCard(
                patientId: patient['patientId'],
                patientName: patient['patientName'],
                lastConsultationDate: patient['lastConsultationDate'],
                consultationsCount: patient['consultationsCount'],
              );
            },
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(padding),
          itemCount: patientsList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final patient = patientsList[index];
            return _PatientCard(
              patientId: patient['patientId'],
              patientName: patient['patientName'],
              lastConsultationDate: patient['lastConsultationDate'],
              consultationsCount: patient['consultationsCount'],
              appointments: patient['appointments'],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, bool isLarge) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.person_2,
            size: isLarge ? 100 : 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: isLarge ? 20 : 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty || _startDate != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(CupertinoIcons.xmark_circle),
              label: const Text('Effacer les filtres'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// CARD DESKTOP MODERNE
class _DesktopPatientCard extends StatelessWidget {
  final String patientId;
  final String patientName;
  final DateTime lastConsultationDate;
  final int consultationsCount;

  const _DesktopPatientCard({
    required this.patientId,
    required this.patientName,
    required this.lastConsultationDate,
    required this.consultationsCount,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      'fr_FR',
    ).format(lastConsultationDate);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailPage(
                patientId: patientId,
                patientName: patientName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                patientName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 14,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.doc_text,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$consultationsCount consultation${consultationsCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CARD MOBILE (INCHANGÉE)
class _PatientCard extends StatelessWidget {
  final String patientId;
  final String patientName;
  final DateTime lastConsultationDate;
  final int consultationsCount;
  final List<dynamic> appointments;

  const _PatientCard({
    required this.patientId,
    required this.patientName,
    required this.lastConsultationDate,
    required this.consultationsCount,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd MMM yyyy',
      'fr_FR',
    ).format(lastConsultationDate);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailPage(
                patientId: patientId,
                patientName: patientName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                  style: TextStyle(
                    fontSize: getProportionateScreenHeight(24),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(16),
                        fontWeight: FontWeight.bold,
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
                          'Dernière visite: $formattedDate',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(13),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$consultationsCount consultation${consultationsCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(13),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// BOUTONS MODERNES POUR DESKTOP
class _ModernPeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernPeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernDateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _ModernDateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: date != null
              ? AppColors.primary.withOpacity(0.05)
              : Colors.grey[50],
          border: Border.all(
            color: date != null ? AppColors.primary : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 18,
              color: date != null ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? DateFormat('dd MMM yyyy', 'fr_FR').format(date!)
                        : 'Sélectionner',
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null
                          ? AppColors.primary
                          : Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BOUTON MOBILE (INCHANGÉ)
class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: getProportionateScreenHeight(13),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
