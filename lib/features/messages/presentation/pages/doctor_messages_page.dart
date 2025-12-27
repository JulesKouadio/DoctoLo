import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../data/models/message_model.dart';
import 'chat_page.dart';
import 'search_patients_page.dart';

class DoctorMessagesPage extends StatefulWidget {
  const DoctorMessagesPage({super.key});

  @override
  State<DoctorMessagesPage> createState() => _DoctorMessagesPageState();
}

class _DoctorMessagesPageState extends State<DoctorMessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // App Bar
          Container(
            color: AppColors.primary,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                    child: Row(
                      children: [
                        Text(
                          'Messages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getProportionateScreenHeight(20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SearchPatientsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  Container(
                    color: AppColors.primary,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.6),
                      labelStyle: TextStyle(
                        fontSize: getProportionateScreenHeight(16),
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [
                        Tab(text: 'Conversations'),
                        Tab(text: 'Patients récents'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_ConversationsTab(), _RecentPatientsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPatientsPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }
}

// Onglet Conversations
class _ConversationsTab extends StatefulWidget {
  const _ConversationsTab();

  @override
  State<_ConversationsTab> createState() => _ConversationsTabState();
}

class _ConversationsTabState extends State<_ConversationsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getConversationsStream() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .handleError((error) {
          print('═══════════════════════════════════════════════════════════');
          print('🔴 ERREUR FIRESTORE - INDEX REQUIS (Conversations)');
          print('═══════════════════════════════════════════════════════════');
          print('');
          print('Collection: conversations');
          print('Champs utilisés:');
          print('  - participants (arrayContains)');
          print('  - lastMessageTime (orderBy descending)');
          print('');
          print('Erreur complète:');
          print(error.toString());
          print('═══════════════════════════════════════════════════════════');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: CupertinoSearchTextField(
            controller: _searchController,
            placeholder: 'Rechercher une conversation...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Conversations List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getConversationsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(24)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur de chargement',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Index Firestore requis',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(14),
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.chat_bubble_2,
                        size: 80,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune conversation',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(18),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vos patients peuvent vous contacter',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(14),
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final conversations = snapshot.data!.docs
                  .map((doc) => ConversationModel.fromFirestore(doc))
                  .where((conv) {
                    if (_searchQuery.isEmpty) return true;
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    final otherInfo = conv.getOtherParticipantInfo(
                      currentUserId!,
                    );
                    final name = (otherInfo['name'] ?? '').toLowerCase();
                    return name.contains(_searchQuery);
                  })
                  .toList();

              if (conversations.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun résultat pour "$_searchQuery"',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(16),
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return _ConversationTile(conversation: conversation);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Onglet Patients récents
class _RecentPatientsTab extends StatefulWidget {
  const _RecentPatientsTab();

  @override
  State<_RecentPatientsTab> createState() => _RecentPatientsTabState();
}

class _RecentPatientsTabState extends State<_RecentPatientsTab> {
  final List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  bool _hasMore = true;
  final int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMorePatients();
    }
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: currentUserId)
          .orderBy('date', descending: true)
          .limit(_pageSize)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }

      _lastDocument = appointmentsSnapshot.docs.last;

      final patientIds = <String>{};
      for (var doc in appointmentsSnapshot.docs) {
        final patientId = doc.data()['patientId'] as String?;
        if (patientId != null && patientId.isNotEmpty) {
          patientIds.add(patientId);
        }
      }

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
          print('❌ Erreur chargement patient: $e');
        }
      }

      setState(() {
        _patients.addAll(patients);
        _isLoading = false;
        _hasMore = appointmentsSnapshot.docs.length == _pageSize;
      });
    } catch (e) {
      print('❌ Erreur chargement patients: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePatients() async {
    if (_lastDocument == null || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: currentUserId)
          .orderBy('date', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      if (appointmentsSnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }

      _lastDocument = appointmentsSnapshot.docs.last;

      final patientIds = <String>{};
      for (var doc in appointmentsSnapshot.docs) {
        final patientId = doc.data()['patientId'] as String?;
        if (patientId != null &&
            patientId.isNotEmpty &&
            !_patients.any((p) => p['id'] == patientId)) {
          patientIds.add(patientId);
        }
      }

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
          print('❌ Erreur chargement patient: $e');
        }
      }

      setState(() {
        _patients.addAll(patients);
        _isLoading = false;
        _hasMore = appointmentsSnapshot.docs.length == _pageSize;
      });
    } catch (e) {
      print('❌ Erreur chargement plus de patients: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getOrCreateConversation(String patientId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) throw Exception('Non authentifié');

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
      Navigator.pop(context);

      Navigator.push(
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
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _patients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_patients.isEmpty) {
      return Center(
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
              'Aucun patient',
              style: TextStyle(
                fontSize: getProportionateScreenHeight(18),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
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
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _patients.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _patients.length) {
          return Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final patient = _patients[index];
        return _PatientTile(
          patient: patient,
          onTap: () => _startConversation(patient),
        );
      },
    );
  }
}

// Widget Conversation Tile
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationTile({required this.conversation});

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'fr_FR').format(time);
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  String _getMessagePreview() {
    if (conversation.lastMessage == null) return '';

    switch (conversation.lastMessageType) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.document:
        return '📄 Document';
      case MessageType.audio:
        return '🎤 Audio';
      default:
        return conversation.lastMessage ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherParticipantInfo = conversation.getOtherParticipantInfo(
      currentUserId!,
    );
    final unreadCount = conversation.getUnreadCountForUser(currentUserId);

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  conversationId: conversation.id,
                  otherUserId: otherParticipantInfo['id'] ?? '',
                  otherUserName: otherParticipantInfo['name'] ?? 'Utilisateur',
                  otherUserAvatar: otherParticipantInfo['avatar'] ?? '',
                  isDoctor: true,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenHeight(12),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage:
                          otherParticipantInfo['avatar'] != null &&
                              otherParticipantInfo['avatar']!.isNotEmpty
                          ? CachedNetworkImageProvider(
                              otherParticipantInfo['avatar']!,
                            )
                          : null,
                      child:
                          otherParticipantInfo['avatar'] == null ||
                              otherParticipantInfo['avatar']!.isEmpty
                          ? Text(
                              (otherParticipantInfo['name'] ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(24),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(
                            getProportionateScreenWidth(4),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: getProportionateScreenHeight(10),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              otherParticipantInfo['name'] ?? 'Utilisateur',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(16),
                                fontWeight: unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(12),
                              color: unreadCount > 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMessagePreview(),
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(14),
                          color: unreadCount > 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Patient Tile
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage:
                      patient['avatar'] != null && patient['avatar']!.isNotEmpty
                      ? CachedNetworkImageProvider(patient['avatar']!)
                      : null,
                  child: patient['avatar'] == null || patient['avatar']!.isEmpty
                      ? Icon(
                          CupertinoIcons.person,
                          size: 28,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'] ?? 'Patient',
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (patient['email'] != null &&
                          patient['email']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          patient['email'] ?? '',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(14),
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
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
