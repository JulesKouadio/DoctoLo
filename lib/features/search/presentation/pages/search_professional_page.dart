import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/size_config.dart';
import '../../../doctor/presentation/pages/doctor_profile_page.dart';

class SearchProfessionalPage extends StatefulWidget {
  const SearchProfessionalPage({super.key});

  @override
  State<SearchProfessionalPage> createState() => _SearchProfessionalPageState();
}

class _SearchProfessionalPageState extends State<SearchProfessionalPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedConsultationType;
  String? _selectedLocation;
  bool _isSearching = false;
  List<Map<String, dynamic>> _results = [];

  final List<String> _consultationTypes = [
    'Tous',
    'Consultation physique',
    'Téléconsultation',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
      _results = [];
    });

    try {
      // Chercher tous les professionnels dans la collection doctors
      Query query = FirebaseFirestore.instance.collection('doctors');
      // DÉSACTIVÉ: .where('verificationStatus', isEqualTo: 'approved');

      // Filtre par spécialité
      if (_selectedSpecialty != null && _selectedSpecialty != 'Toutes') {
        query = query.where('specialty', isEqualTo: _selectedSpecialty);
      }

      // Filtre par type de consultation
      if (_selectedConsultationType == 'Téléconsultation') {
        query = query.where('offersTelemedicine', isEqualTo: true);
      }

      // Filtre par localité
      if (_selectedLocation != null && _selectedLocation != 'Toutes') {
        query = query.where('city', isEqualTo: _selectedLocation);
      }

      final snapshot = await query.limit(20).get();

      List<Map<String, dynamic>> results = [];
      for (var doc in snapshot.docs) {
        final doctorData = doc.data() as Map<String, dynamic>;

        // Récupérer les données utilisateur correspondantes
        final userId = doctorData['userId'];
        if (userId != null) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>;

            // DÉSACTIVÉ: Vérification d'email supprimée
            // if (userData['isVerified'] == true) {
            results.add({
              'user': userData,
              'doctor': doctorData,
              'userId': userId,
            });
            // }
          }
        }
      }

      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Erreur recherche: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchProfessional),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtres de recherche
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: Column(
              children: [
                // Barre de recherche
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nom, spécialité...',
                    prefixIcon: const Icon(CupertinoIcons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),

                // Filtre spécialité
                DropdownButtonFormField<String>(
                  initialValue: _selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'Spécialité',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Toutes', ...AppConstants.medicalSpecialties]
                      .map(
                        (specialty) => DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filtre type de consultation
                DropdownButtonFormField<String>(
                  initialValue: _selectedConsultationType,
                  decoration: InputDecoration(
                    labelText: 'Type de consultation',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _consultationTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedConsultationType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filtre localité
                DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Localité',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items:
                      [
                            'Toutes',
                            'Abidjan',
                            'Bouaké',
                            'Daloa',
                            'Yamoussoukro',
                            'San-Pedro',
                            'Korhogo',
                            'Man',
                          ]
                          .map(
                            (location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Bouton de recherche
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenHeight(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Rechercher',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(16),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Résultats
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(18),
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(14),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final user = result['user'] as Map<String, dynamic>;
                      final doctor = result['doctor'] as Map<String, dynamic>;

                      return _DoctorCard(
                        name: '${user['firstName']} ${user['lastName']}',
                        specialty:
                            doctor['specialty'] ?? 'Spécialité non renseignée',
                        consultationFee: (doctor['consultationFee'] ?? 0.0)
                            .toDouble(),
                        offersTelemedicine:
                            doctor['offersTelemedicine'] ?? false,
                        offersPhysicalConsultation:
                            doctor['offersPhysicalConsultation'] ?? true,
                        photoUrl: user['photoUrl'],
                        location: doctor['city'] ?? '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorProfilePage(
                                userId: result['userId'],
                                doctorId:
                                    result['userId'], // Utiliser userId comme doctorId
                              ),
                            ),
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

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double consultationFee;
  final bool offersTelemedicine;
  final bool offersPhysicalConsultation;
  final String location;
  final String? photoUrl;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.name,
    required this.specialty,
    required this.consultationFee,
    required this.offersTelemedicine,
    required this.offersPhysicalConsultation,
    required this.location,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: Row(
            children: [
              // Photo
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl!)
                    : null,
                child: photoUrl == null
                    ? Icon(
                        CupertinoIcons.person,
                        size: 35,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(14),
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Afficher les types de consultations
                        if (offersTelemedicine && offersPhysicalConsultation)
                          Expanded(
                            child: Text(
                              'Téléconsultation et consultation physique',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(10),
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else if (offersTelemedicine)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.videocam_fill,
                                  size: 12,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Téléconsultation',
                                  style: TextStyle(
                                    fontSize: getProportionateScreenHeight(10),
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (offersPhysicalConsultation)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Consultation physique',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(10),
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.location_solid,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(12),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'À partir de ${consultationFee < 1000 ? 1000 : consultationFee.toStringAsFixed(0)} XOF',
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(CupertinoIcons.right_chevron, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
