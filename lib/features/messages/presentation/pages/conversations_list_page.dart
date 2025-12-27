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
import 'search_doctors_page.dart';

class ConversationsListPage extends StatefulWidget {
  final bool isDoctor;

  const ConversationsListPage({super.key, required this.isDoctor});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
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
          print('Index requis:');
          print('{');
          print('  "collectionGroup": "conversations",');
          print('  "queryScope": "COLLECTION",');
          print('  "fields": [');
          print(
            '    { "fieldPath": "participants", "arrayConfig": "CONTAINS" },',
          );
          print(
            '    { "fieldPath": "lastMessageTime", "order": "DESCENDING" }',
          );
          print('  ]');
          print('}');
          print('');
          print('📝 Solutions:');
          print('1. Cliquez sur le lien dans l\'erreur Firebase ci-dessous');
          print('2. Ou ajoutez l\'index manuellement dans Firebase Console');
          print('3. Ou ajoutez dans firestore.indexes.json et déployez');
          print('');
          print('Erreur complète:');
          print(error.toString());
          print('═══════════════════════════════════════════════════════════');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            title: Text(
              'Messages',
              style: TextStyle(
                color: Colors.white,
                fontSize: getProportionateScreenHeight(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (!widget.isDoctor)
                IconButton(
                  icon: const Icon(CupertinoIcons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchDoctorsPage(),
                      ),
                    );
                  },
                ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
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
          ),

          // Conversations List
          StreamBuilder<QuerySnapshot>(
            stream: _getConversationsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
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
                          const SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.info_circle,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Consultez la console',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Un print détaillé avec le lien Firebase pour créer l\'index a été affiché dans la console.',
                                  style: TextStyle(
                                    fontSize: getProportionateScreenHeight(12),
                                    color: AppColors.textSecondary,
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

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
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
                          widget.isDoctor
                              ? 'Vos patients peuvent vous contacter'
                              : 'Commencez une conversation avec un docteur',
                          style: TextStyle(
                            fontSize: getProportionateScreenHeight(14),
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                        if (!widget.isDoctor) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SearchDoctorsPage(),
                                ),
                              );
                            },
                            icon: const Icon(CupertinoIcons.search),
                            label: const Text('Rechercher un docteur'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun résultat pour "$_searchQuery"',
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final conversation = conversations[index];
                  return _ConversationTile(
                    conversation: conversation,
                    isDoctor: widget.isDoctor,
                  );
                }, childCount: conversations.length),
              );
            },
          ),
        ],
      ),
      floatingActionButton: widget.isDoctor
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchDoctorsPage(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(CupertinoIcons.add, color: Colors.white),
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final bool isDoctor;

  const _ConversationTile({required this.conversation, required this.isDoctor});

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
                  isDoctor: isDoctor,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16), vertical: getProportionateScreenHeight(12)),
            child: Row(
              children: [
                // Avatar
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
                          padding: EdgeInsets.all(getProportionateScreenWidth(4)),
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

                // Info
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
                      Row(
                        children: [
                          if (otherParticipantInfo['specialty'] != null &&
                              !isDoctor) ...[
                            Icon(
                              CupertinoIcons.briefcase,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              otherParticipantInfo['specialty'] ?? '',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(12),
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
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
                          ),
                        ],
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
