import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import 'chat_page.dart';

class SearchPatientsPage extends StatefulWidget {
  const SearchPatientsPage({super.key});

  @override
  State<SearchPatientsPage> createState() => _SearchPatientsPageState();
}

class _SearchPatientsPageState extends State<SearchPatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      // Récupérer les rendez-vous du docteur pour trouver ses patients
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: currentUserId)
          .orderBy('date', descending: true)
          .get();

      // Extraire les IDs uniques des patients
      final patientIds = <String>{};
      for (var doc in appointmentsSnapshot.docs) {
        final patientId = doc.data()['patientId'] as String?;
        if (patientId != null && patientId.isNotEmpty) {
          patientIds.add(patientId);
        }
      }

      // Récupérer les infos des patients
      final patients = <Map<String, dynamic>>[];
      for (var patientId in patientIds) {
        try {
          final patientDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(patientId)
              .get();

          if (patientDoc.exists) {
            final data = patientDoc.data()!;
            patients.add({
              'id': patientId,
              'name': data['firstName'] != null && data['lastName'] != null
                  ? '${data['firstName']} ${data['lastName']}'
                  : data['name'] ?? 'Patient',
              'avatar': data['photoUrl'] ?? '',
              'email': data['email'] ?? '',
              'phone': data['phone'] ?? '',
            });
          }
        } catch (e) {
          print('❌ Erreur chargement patient $patientId: $e');
        }
      }

      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement patients: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((patient) {
          final name = (patient['name'] as String).toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<String> _getOrCreateConversation(String patientId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('Non authentifié');

    // Chercher une conversation existante
    final existingConversation = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in existingConversation.docs) {
      final participants = List<String>.from(doc.data()['participants']);
      if (participants.contains(patientId)) {
        return doc.id;
      }
    }

    // Créer une nouvelle conversation
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final currentUserData = currentUserDoc.data() ?? {};

    final patientDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(patientId)
        .get();
    final patientData = patientDoc.data() ?? {};

    final conversationRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc();

    await conversationRef.set({
      'participants': [currentUserId, patientId],
      'participantsInfo': {
        currentUserId: {
          'id': currentUserId,
          'name':
              '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
                  .trim(),
          'avatar': currentUserData['photoUrl'] ?? '',
          'role': 'doctor',
          'specialty': currentUserData['specialty'] ?? '',
        },
        patientId: {
          'id': patientId,
          'name':
              '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}'
                  .trim(),
          'avatar': patientData['photoUrl'] ?? '',
          'role': 'patient',
        },
      },
      'unreadCount': {currentUserId: 0, patientId: 0},
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return conversationRef.id;
  }

  Future<void> _startConversation(Map<String, dynamic> patient) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      final conversationId = await _getOrCreateConversation(patient['id']);

      if (!mounted) return;
      Navigator.pop(context); // Fermer le loader

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            conversationId: conversationId,
            otherUserId: patient['id'],
            otherUserName: patient['name'],
            otherUserAvatar: patient['avatar'],
            isDoctor: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fermer le loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rechercher un patient',
          style: TextStyle(
            color: Colors.white,
            fontSize: getProportionateScreenHeight(20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: 'Nom du patient...',
              onChanged: _filterPatients,
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person_2,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Aucun patient'
                              : 'Aucun résultat pour "$_searchQuery"',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(16),
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Vos patients apparaîtront ici après une consultation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(14),
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      return _PatientTile(
                        patient: patient,
                        onTap: () => _startConversation(patient),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onTap;

  const _PatientTile({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage:
                      patient['avatar'] != null && patient['avatar']!.isNotEmpty
                      ? CachedNetworkImageProvider(patient['avatar']!)
                      : null,
                  child: patient['avatar'] == null || patient['avatar']!.isEmpty
                      ? Icon(
                          CupertinoIcons.person,
                          size: 30,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'] ?? 'Patient',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (patient['email'] != null &&
                          patient['email']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.mail,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                patient['email'] ?? '',
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(14),
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (patient['phone'] != null &&
                          patient['phone']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.phone,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              patient['phone'] ?? '',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(14),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  CupertinoIcons.chat_bubble_text_fill,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
