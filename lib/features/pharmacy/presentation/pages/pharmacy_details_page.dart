import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../data/models/pharmacy_model.dart';
import '../../../../data/models/medicine_model.dart';
import '../../../../data/constants/medicine_data.dart';

class PharmacyDetailsPage extends StatefulWidget {
  final PharmacyModel pharmacy;
  final double? distance;

  const PharmacyDetailsPage({super.key, required this.pharmacy, this.distance});

  @override
  State<PharmacyDetailsPage> createState() => _PharmacyDetailsPageState();
}

class _PharmacyDetailsPageState extends State<PharmacyDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MedicineModel> _medicines = [];
  List<MedicineModel> _filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    _medicines = MedicineData.medicines;
    _filteredMedicines = _medicines;
  }

  void _searchMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMedicines = _medicines;
      } else {
        _filteredMedicines = _medicines.where((m) {
          return m.commercialName.toLowerCase().contains(query.toLowerCase()) ||
              m.therapeuticGroup.toLowerCase().contains(query.toLowerCase()) ||
              m.code.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _callPharmacy() async {
    final cleanPhone = widget.pharmacy.phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openInMaps() async {
    if (widget.pharmacy.latitude == null || widget.pharmacy.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coordonnées GPS non disponibles')),
      );
      return;
    }

    final lat = widget.pharmacy.latitude!;
    final lon = widget.pharmacy.longitude!;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails Pharmacie'),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          titleTextStyle: TextStyle(
            color: AppColors.primary,
            fontSize: getProportionateScreenHeight(20),
            fontWeight: FontWeight.bold,
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(CupertinoIcons.info_circle), text: 'Informations'),
              Tab(icon: Icon(CupertinoIcons.square_list), text: 'Médicaments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet Informations
            _buildInfoTab(),
            // Onglet Médicaments
            _buildMedicinesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom de la pharmacie
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.building_2_fill,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.pharmacy.name,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(20),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'PHARMACIE DE GARDE',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: getProportionateScreenHeight(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Informations de contact
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.location_solid,
                    color: AppColors.primary,
                  ),
                  title: const Text('Commune'),
                  subtitle: Text(widget.pharmacy.commune),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.person_fill,
                    color: AppColors.primary,
                  ),
                  title: const Text('Responsable'),
                  subtitle: Text(widget.pharmacy.doctorName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    CupertinoIcons.phone_fill,
                    color: AppColors.primary,
                  ),
                  title: const Text('Téléphone'),
                  subtitle: Text(widget.pharmacy.phone),
                  trailing: IconButton(
                    icon: const Icon(
                      CupertinoIcons.phone_circle_fill,
                      color: AppColors.accent,
                    ),
                    onPressed: _callPharmacy,
                  ),
                ),
                if (widget.distance != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.location,
                      color: AppColors.primary,
                    ),
                    title: const Text('Distance'),
                    subtitle: Text('${widget.distance!.toStringAsFixed(1)} km'),
                  ),
                ],
                if (widget.pharmacy.latitude != null &&
                    widget.pharmacy.longitude != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.map_fill,
                      color: AppColors.primary,
                    ),
                    title: const Text('Coordonnées GPS'),
                    subtitle: Text(
                      '${widget.pharmacy.latitude!.toStringAsFixed(6)}, ${widget.pharmacy.longitude!.toStringAsFixed(6)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        CupertinoIcons.map,
                        color: AppColors.accent,
                      ),
                      onPressed: _openInMaps,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _callPharmacy,
                  icon: const Icon(CupertinoIcons.phone_fill),
                  label: const Text('Appeler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.pharmacy.latitude != null
                      ? _openInMaps
                      : null,
                  icon: const Icon(CupertinoIcons.map),
                  label: const Text('Itinéraire'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesTab() {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: TextField(
            controller: _searchController,
            onChanged: _searchMedicines,
            decoration: InputDecoration(
              hintText: 'Rechercher un médicament...',
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.clear_circled_solid),
                      onPressed: () {
                        _searchController.clear();
                        _searchMedicines('');
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

        // Info
        Padding(
          padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
          child: Text(
            '${_filteredMedicines.length} médicaments disponibles',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 8),

        // Liste des médicaments
        Expanded(
          child: _filteredMedicines.isEmpty
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
                        'Aucun médicament trouvé',
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
                  itemCount: _filteredMedicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _filteredMedicines[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          padding: EdgeInsets.all(getProportionateScreenWidth(8)),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            CupertinoIcons.capsule,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          medicine.commercialName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: getProportionateScreenHeight(14),
                          ),
                        ),
                        subtitle: Text(
                          '${medicine.price} FCFA',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Code', medicine.code),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Groupe thérapeutique',
                                  medicine.therapeuticGroup,
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow('Prix', '${medicine.price} FCFA'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
