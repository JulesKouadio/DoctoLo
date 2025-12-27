import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import 'chat_page.dart';

class SearchDoctorsPage extends StatefulWidget {
  const SearchDoctorsPage({super.key});

  @override
  State<SearchDoctorsPage> createState() => _SearchDoctorsPageState();
}

class _SearchDoctorsPageState extends State<SearchDoctorsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      setState(() {
        _allDoctors = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['firstName'] != null && data['lastName'] != null
                ? '${data['firstName']} ${data['lastName']}'
                : data['name'] ?? 'Docteur',
            'specialty': data['specialty'] ?? 'Médecine générale',
            'avatar': data['photoUrl'] ?? '',
            'city': data['city'] ?? '',
            'rating': data['rating'] ?? 0.0,
            'reviewCount': data['reviewCount'] ?? 0,
          };
        }).toList();
        _filteredDoctors = _allDoctors;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement docteurs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredDoctors = _allDoctors;
      } else {
        _filteredDoctors = _allDoctors.where((doctor) {
          final name = (doctor['name'] as String).toLowerCase();
          final specialty = (doctor['specialty'] as String).toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || specialty.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<String> _getOrCreateConversation(String doctorId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('Non authentifié');

    // Chercher une conversation existante
    final existingConversation = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in existingConversation.docs) {
      final participants = List<String>.from(doc.data()['participants']);
      if (participants.contains(doctorId)) {
        return doc.id;
      }
    }

    // Créer une nouvelle conversation
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final currentUserData = currentUserDoc.data() ?? {};

    final doctorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(doctorId)
        .get();
    final doctorData = doctorDoc.data() ?? {};

    final conversationRef = FirebaseFirestore.instance
        .collection('conversations')
        .doc();

    await conversationRef.set({
      'participants': [currentUserId, doctorId],
      'participantsInfo': {
        currentUserId: {
          'id': currentUserId,
          'name':
              '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
                  .trim(),
          'avatar': currentUserData['photoUrl'] ?? '',
          'role': 'patient',
        },
        doctorId: {
          'id': doctorId,
          'name':
              '${doctorData['firstName'] ?? ''} ${doctorData['lastName'] ?? ''}'
                  .trim(),
          'avatar': doctorData['photoUrl'] ?? '',
          'role': 'doctor',
          'specialty': doctorData['specialty'] ?? '',
        },
      },
      'unreadCount': {currentUserId: 0, doctorId: 0},
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return conversationRef.id;
  }

  Future<void> _startConversation(Map<String, dynamic> doctor) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      final conversationId = await _getOrCreateConversation(doctor['id']);

      if (!mounted) return;
      Navigator.pop(context); // Fermer le loader

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            conversationId: conversationId,
            otherUserId: doctor['id'],
            otherUserName: doctor['name'],
            otherUserAvatar: doctor['avatar'],
            isDoctor: false,
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
          'Rechercher un docteur',
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
              placeholder: 'Nom ou spécialité...',
              onChanged: _filterDoctors,
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Recherchez un docteur'
                              : 'Aucun résultat pour "$_searchQuery"',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(16),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = _filteredDoctors[index];
                      return _DoctorTile(
                        doctor: doctor,
                        onTap: () => _startConversation(doctor),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const _DoctorTile({required this.doctor, required this.onTap});

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
                      doctor['avatar'] != null && doctor['avatar']!.isNotEmpty
                      ? CachedNetworkImageProvider(doctor['avatar']!)
                      : null,
                  child: doctor['avatar'] == null || doctor['avatar']!.isEmpty
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
                        doctor['name'] ?? 'Docteur',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.briefcase,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor['specialty'] ?? '',
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
                      if (doctor['city'] != null &&
                          doctor['city']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.location,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor['city'] ?? '',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(12),
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (doctor['rating'] != null && doctor['rating'] > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.star_fill,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor['rating'].toStringAsFixed(1)} (${doctor['reviewCount']} avis)',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(12),
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
