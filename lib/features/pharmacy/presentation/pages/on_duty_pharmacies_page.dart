import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../data/models/pharmacy_model.dart';
import '../../../../data/constants/pharmacy_data.dart';
import 'pharmacy_details_page.dart';

class OnDutyPharmaciesPage extends StatefulWidget {
  const OnDutyPharmaciesPage({super.key});

  @override
  State<OnDutyPharmaciesPage> createState() => _OnDutyPharmaciesPageState();
}

class _OnDutyPharmaciesPageState extends State<OnDutyPharmaciesPage> {
  List<PharmacyModel> _pharmacies = [];
  List<PharmacyModel> _filteredPharmacies = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _sortByDistance = false;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _userPosition = position;
        if (_sortByDistance) {
          _sortPharmaciesByDistance();
        }
      });
    } catch (e) {
      print('Erreur localisation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPharmacies() {
    _pharmacies = PharmacyData.onDutyPharmacies;
    _filteredPharmacies = _pharmacies;
    setState(() => _isLoading = false);
  }

  void _searchPharmacies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPharmacies = _pharmacies;
      } else {
        _filteredPharmacies = _pharmacies.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.commune.toLowerCase().contains(query.toLowerCase()) ||
              p.doctorName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _sortPharmaciesByDistance() {
    if (_userPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localisation non disponible')),
      );
      return;
    }

    setState(() {
      _sortByDistance = true;
      _filteredPharmacies = PharmacyData.getNearestPharmacies(
        _userPosition!.latitude,
        _userPosition!.longitude,
        limit: _filteredPharmacies.length,
      );
    });
  }

  void _resetSort() {
    setState(() {
      _sortByDistance = false;
      _filteredPharmacies = _pharmacies;
    });
  }

  Future<void> _callPharmacy(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies de Garde'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: getProportionateScreenHeight(20),
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _sortByDistance
                  ? CupertinoIcons.location_fill
                  : CupertinoIcons.location,
              color: _sortByDistance ? AppColors.primary : Colors.grey,
            ),
            onPressed: _sortByDistance ? _resetSort : _sortPharmaciesByDistance,
            tooltip: _sortByDistance
                ? 'Afficher toutes'
                : 'Trier par proximité',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: TextField(
              controller: _searchController,
              onChanged: _searchPharmacies,
              decoration: InputDecoration(
                hintText: 'Rechercher une pharmacie...',
                prefixIcon: const Icon(CupertinoIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid),
                        onPressed: () {
                          _searchController.clear();
                          _searchPharmacies('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Info message
          if (_sortByDistance && _userPosition != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16), vertical: getProportionateScreenHeight(8)),
              padding: EdgeInsets.all(getProportionateScreenWidth(12)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.info,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pharmacies triées par proximité',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

          // Liste des pharmacies
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPharmacies.isEmpty
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
                          'Aucune pharmacie trouvée',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: getProportionateScreenHeight(16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    itemCount: _filteredPharmacies.length,
                    itemBuilder: (context, index) {
                      final pharmacy = _filteredPharmacies[index];
                      double? distance;
                      if (_userPosition != null) {
                        distance = pharmacy.distanceFrom(
                          _userPosition!.latitude,
                          _userPosition!.longitude,
                        );
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: getProportionateScreenHeight(12)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(getProportionateScreenWidth(16)),
                          leading: Container(
                            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              CupertinoIcons.building_2_fill,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            pharmacy.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getProportionateScreenHeight(16),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.location_solid,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(pharmacy.commune),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.person,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      pharmacy.doctorName,
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (distance != null) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.location,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${distance.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              CupertinoIcons.phone_fill,
                              color: AppColors.accent,
                            ),
                            onPressed: () => _callPharmacy(pharmacy.phone),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PharmacyDetailsPage(
                                  pharmacy: pharmacy,
                                  distance: distance,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
