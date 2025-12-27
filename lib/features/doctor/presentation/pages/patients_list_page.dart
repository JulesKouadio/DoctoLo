import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
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
  String _selectedPeriod = 'all'; // 'all', 'today', 'week', 'month'
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

    // Filtre par intervalle de dates si spécifié
    if (_startDate != null) {
      print('🔍 Filtrage avec date de début: ${_startDate!.toIso8601String()}');
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!),
      );
    }
    if (_endDate != null) {
      // Ajouter 1 jour pour inclure la date de fin
      final endDateTime = _endDate!.add(const Duration(days: 1));
      print('🔍 Filtrage avec date de fin: ${endDateTime.toIso8601String()}');
      query = query.where('date', isLessThan: Timestamp.fromDate(endDateTime));
    }

    print('📊 Requête Firestore configurée avec orderBy date DESC');

    // Utiliser handleError pour capturer les erreurs du stream
    return query.orderBy('date', descending: true).snapshots().handleError((
      error,
    ) {
      print('\n');
      print('═══════════════════════════════════════════════════════════');
      print('🔴 ERREUR FIRESTORE - INDEX REQUIS');
      print('═══════════════════════════════════════════════════════════');
      print('📍 Collection: appointments');
      print('📍 Docteur ID: $_currentDoctorId');
      if (_startDate != null) {
        print('📍 Date début: ${_startDate!.toLocal()}');
      }
      if (_endDate != null) {
        print('📍 Date fin: ${_endDate!.toLocal()}');
      }
      print('───────────────────────────────────────────────────────────');
      print('📋 Index composite nécessaire:');
      print('   1. doctorId (Ascending) - Égalité');
      if (_startDate != null || _endDate != null) {
        print('   2. date (Ascending) - Range (>=, <)');
      }
      print('   3. date (Descending) - OrderBy');
      print('───────────────────────────────────────────────────────────');
      print('❌ ERREUR COMPLÈTE:');
      print(error.toString());
      print('───────────────────────────────────────────────────────────');
      print('✅ SOLUTION 1 - Lien automatique:');
      print('   Cherchez dans l\'erreur ci-dessus un lien commençant par:');
      print('   https://console.firebase.google.com/...');
      print('   Cliquez dessus pour créer l\'index automatiquement!');
      print('───────────────────────────────────────────────────────────');
      print('✅ SOLUTION 2 - Commande manuelle:');
      print('   Exécutez dans le terminal:');
      print('   firebase deploy --only firestore:indexes --project doctolo');
      print('───────────────────────────────────────────────────────────');
      print('✅ SOLUTION 3 - Firebase Console:');
      print(
        '   https://console.firebase.google.com/project/_/firestore/indexes',
      );
      print('   Créez un index composite pour "appointments" avec:');
      print('   - doctorId (Ascending)');
      print('   - date (Ascending)');
      print('   - date (Descending)');
      print('═══════════════════════════════════════════════════════════');
      print('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.patientsList),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: Column(
              children: [
                // Champ de recherche
                TextField(
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
                ),
                const SizedBox(height: 16),

                // Boutons de période rapide
                Row(
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
                ),
                const SizedBox(height: 12),

                // Sélecteurs de dates personnalisés
                Row(
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
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(12),
                              ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(12),
                              ),
                            ),
                          ],
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: _endDate != null
                                ? AppColors.primary
                                : Colors.grey[300]!,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                ),
              ],
            ),
          ),

          // Liste des patients
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPatientsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // Afficher l'erreur dans la console avec plus de détails
                  print('\n');
                  print(
                    '═══════════════════════════════════════════════════════════',
                  );
                  print('🔴 ERREUR STREAMBUILDER - FIRESTORE');
                  print(
                    '═══════════════════════════════════════════════════════════',
                  );
                  print('Type d\'erreur: ${snapshot.error.runtimeType}');
                  print('Message: ${snapshot.error}');
                  if (snapshot.stackTrace != null) {
                    print(
                      '───────────────────────────────────────────────────────────',
                    );
                    print('StackTrace:');
                    print(snapshot.stackTrace);
                  }
                  print(
                    '═══════════════════════════════════════════════════════════',
                  );
                  print(
                    '💡 Si l\'erreur mentionne "index", déployez les index:',
                  );
                  print(
                    '   firebase deploy --only firestore:indexes --project doctolo',
                  );
                  print(
                    '═══════════════════════════════════════════════════════════',
                  );
                  print('\n');

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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(32)),
                          child: Text(
                            'Erreur Firestore',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(32)),
                          child: Text(
                            'Vérifiez la console pour plus de détails',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(14),
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // Forcer le rechargement
                            });
                          },
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

                // Vérifier si on a des données (même vides)
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person_2,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun patient',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(18),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final appointments = snapshot.data?.docs ?? [];

                // Regrouper par patient unique
                final Map<String, Map<String, dynamic>> uniquePatients = {};
                for (var doc in appointments) {
                  final appointment = doc.data() as Map<String, dynamic>;
                  final patientId = appointment['patientId'];
                  final patientName = (appointment['patientName'] ?? '')
                      .toLowerCase();

                  // Filtrer par recherche
                  if (_searchQuery.isNotEmpty &&
                      !patientName.contains(_searchQuery)) {
                    continue;
                  }

                  if (patientId != null) {
                    if (!uniquePatients.containsKey(patientId)) {
                      uniquePatients[patientId] = {
                        'patientId': patientId,
                        'patientName': appointment['patientName'],
                        'lastConsultationDate':
                            (appointment['date'] as Timestamp).toDate(),
                        'consultationsCount': 1,
                        'appointments': [appointment],
                      };
                    } else {
                      uniquePatients[patientId]!['consultationsCount']++;
                      uniquePatients[patientId]!['appointments'].add(
                        appointment,
                      );
                    }
                  }
                }

                if (uniquePatients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person_2,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _startDate != null
                              ? 'Aucun patient trouvé'
                              : 'Aucun patient',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(18),
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || _startDate != null) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(CupertinoIcons.xmark_circle),
                            label: const Text('Effacer les filtres'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final patientsList = uniquePatients.values.toList();

                return ListView.separated(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  itemCount: patientsList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
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
            ),
          ),
        ],
      ),
    );
  }
}

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
              // Avatar
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

              // Informations
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

              // Icône chevron
              Icon(CupertinoIcons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour les boutons de période rapide
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
        padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
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
