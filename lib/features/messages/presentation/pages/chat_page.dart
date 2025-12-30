import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/size_config.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/message_model.dart';
import 'create_prescription_page.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final bool isDoctor;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.isDoctor,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      // Marquer les messages non lus comme lus
      final unreadMessages = await FirebaseFirestore.instance
          .collection('messages')
          .where('conversationId', isEqualTo: widget.conversationId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Réinitialiser le compteur non lu dans la conversation
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .update({'unreadCount.$currentUserId': 0});
    } catch (e) {
      print('═══════════════════════════════════════════════════════════');
      print('🔴 ERREUR FIRESTORE - INDEX REQUIS (Mark as Read)');
      print('═══════════════════════════════════════════════════════════');
      print('');
      print('Collection: messages');
      print('Champs utilisés:');
      print('  - conversationId (where ==)');
      print('  - receiverId (where ==)');
      print('  - isRead (where ==)');
      print('');
      print('Index requis:');
      print('{');
      print('  "collectionGroup": "messages",');
      print('  "queryScope": "COLLECTION",');
      print('  "fields": [');
      print('    { "fieldPath": "conversationId", "order": "ASCENDING" },');
      print('    { "fieldPath": "receiverId", "order": "ASCENDING" },');
      print('    { "fieldPath": "isRead", "order": "ASCENDING" }');
      print('  ]');
      print('}');
      print('');
      print('📝 Solutions:');
      print('1. Cliquez sur le lien dans l\'erreur Firebase ci-dessous');
      print('2. Ou ajoutez l\'index dans firestore.indexes.json et déployez');
      print('');
      print('Erreur: $e');
      print('═══════════════════════════════════════════════════════════');
    }
  }

  Future<void> _sendMessage({
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    if (content.trim().isEmpty && type == MessageType.text) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      // Récupérer les infos de l'utilisateur actuel
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final currentUserData = currentUserDoc.data() ?? {};
      final currentUserName =
          '${currentUserData['firstName'] ?? ''} ${currentUserData['lastName'] ?? ''}'
              .trim();
      final currentUserAvatar = currentUserData['photoUrl'] ?? '';

      // Créer le message
      final message = MessageModel(
        id: '',
        conversationId: widget.conversationId,
        senderId: currentUserId,
        senderName: currentUserName,
        senderAvatar: currentUserAvatar,
        receiverId: widget.otherUserId,
        content: content,
        type: type,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Ajouter le message à Firestore
      await FirebaseFirestore.instance
          .collection('messages')
          .add(message.toFirestore());

      // Mettre à jour la conversation
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .update({
            'lastMessage': content,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'lastMessageType': type.toString().split('.').last,
            'unreadCount.${widget.otherUserId}': FieldValue.increment(1),
          });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('❌ Erreur envoi message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final file = File(image.path);
      final fileName = image.name;
      final fileSize = await file.length();

      // Upload vers Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'chat_images/${widget.conversationId}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await _sendMessage(
        content: 'Photo',
        type: MessageType.image,
        fileUrl: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      print('❌ Erreur envoi image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickAndSendDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isUploading = true;
      });

      final file = File(result.files.first.path!);
      final fileName = result.files.first.name;
      final fileSize = result.files.first.size;

      // Upload vers Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'chat_documents/${widget.conversationId}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await _sendMessage(
        content: fileName,
        type: MessageType.document,
        fileUrl: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      print('❌ Erreur envoi document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi du document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _createAndSendPrescription() async {
    try {
      // Récupérer le nom du docteur actuel
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final doctorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final doctorName =
          doctorDoc.data()?['firstName'] != null &&
              doctorDoc.data()?['lastName'] != null
          ? '${doctorDoc.data()!['firstName']} ${doctorDoc.data()!['lastName']}'
          : 'Docteur';

      if (!mounted) return;

      // Ouvrir la page de création d'ordonnance
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePrescriptionPage(
            doctorName: doctorName,
            patientName: widget.otherUserName,
          ),
        ),
      );

      if (result == null || result is! File) return;

      setState(() {
        _isUploading = true;
      });

      final pdfFile = result;
      final fileName =
          'Ordonnance_${widget.otherUserName}_${DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now())}.pdf';
      final fileSize = await pdfFile.length();

      // Upload vers Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'chat_documents/${widget.conversationId}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await storageRef.putFile(pdfFile);
      final downloadUrl = await storageRef.getDownloadURL();

      // Supprimer le fichier temporaire
      await pdfFile.delete();

      await _sendMessage(
        content: '📋 Ordonnance médicale',
        type: MessageType.document,
        fileUrl: downloadUrl,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ordonnance envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur création ordonnance: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de création de l\'ordonnance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showAttachmentOptions() {
    showAdaptiveSimpleSheet(
      context: context,
      dialogWidth: 400,
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: getProportionateScreenHeight(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(10)),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.photo, color: Colors.blue),
              ),
              title: const Text('Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(10)),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.doc, color: Colors.orange),
              ),
              title: const Text('Document'),
              subtitle: const Text('PDF, DOC, DOCX, JPG, PNG'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendDocument();
              },
            ),
            if (widget.isDoctor)
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(10)),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.doc_text,
                    color: Colors.green,
                  ),
                ),
                title: const Text('Ordonnance'),
                subtitle: const Text('Créer une ordonnance médicale'),
                onTap: () {
                  Navigator.pop(context);
                  _createAndSendPrescription();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final maxWidth = isDesktop ? 800.0 : (isTablet ? 700.0 : double.infinity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: widget.otherUserAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(widget.otherUserAvatar)
                  : null,
              child: widget.otherUserAvatar.isEmpty
                  ? Text(
                      widget.otherUserName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Messages List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .where('conversationId', isEqualTo: widget.conversationId)
                      .orderBy('timestamp', descending: false)
                      .snapshots()
                      .handleError((error) {
                        print(
                          '═══════════════════════════════════════════════════════════',
                        );
                        print('🔴 ERREUR FIRESTORE - INDEX REQUIS (Messages)');
                        print(
                          '═══════════════════════════════════════════════════════════',
                        );
                        print('');
                        print('Collection: messages');
                        print('Champs utilisés:');
                        print('  - conversationId (where ==)');
                        print('  - timestamp (orderBy ascending)');
                        print('');
                        print('Index requis:');
                        print('{');
                        print('  "collectionGroup": "messages",');
                        print('  "queryScope": "COLLECTION",');
                        print('  "fields": [');
                        print(
                          '    { "fieldPath": "conversationId", "order": "ASCENDING" },',
                        );
                        print(
                          '    { "fieldPath": "timestamp", "order": "ASCENDING" }',
                        );
                        print('  ]');
                        print('}');
                        print('');
                        print('📝 Solutions:');
                        print(
                          '1. Cliquez sur le lien dans l\'erreur Firebase ci-dessous',
                        );
                        print(
                          '2. Ou ajoutez l\'index manuellement dans Firebase Console',
                        );
                        print(
                          '3. Ou exécutez: firebase deploy --only firestore:indexes --project doctolo',
                        );
                        print('');
                        print('Conversation ID: ${widget.conversationId}');
                        print('');
                        print('Erreur complète:');
                        print(error.toString());
                        print(
                          '═══════════════════════════════════════════════════════════',
                        );
                      }),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            getProportionateScreenWidth(24),
                          ),
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
                                padding: EdgeInsets.all(
                                  getProportionateScreenWidth(16),
                                ),
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
                                      'Un print avec le lien Firebase pour créer l\'index a été affiché. Copiez et collez le lien dans votre navigateur.',
                                      style: TextStyle(
                                        fontSize: getProportionateScreenHeight(
                                          12,
                                        ),
                                        color: AppColors.textSecondary,
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
                              'Aucun message',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(18),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Commencez la conversation',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(14),
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final messages = snapshot.data!.docs
                        .map((doc) => MessageModel.fromFirestore(doc))
                        .toList();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe =
                            message.senderId ==
                            FirebaseAuth.instance.currentUser?.uid;
                        final showDate =
                            index == 0 ||
                            !_isSameDay(
                              message.timestamp,
                              messages[index - 1].timestamp,
                            );

                        return Column(
                          children: [
                            if (showDate) _buildDateDivider(message.timestamp),
                            _MessageBubble(message: message, isMe: isMe),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Upload indicator
              if (_isUploading)
                Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                  color: Colors.blue.withOpacity(0.1),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Envoi en cours...'),
                    ],
                  ),
                ),

              // Input Area
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(8),
                  vertical: getProportionateScreenHeight(8),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Attachment button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.paperclip,
                          color: AppColors.primary,
                        ),
                        onPressed: _showAttachmentOptions,
                      ),

                      // Text field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Votre message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ),

                      // Send button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        onPressed: () =>
                            _sendMessage(content: _messageController.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isYesterday = _isSameDay(date, now.subtract(const Duration(days: 1)));

    String dateText;
    if (isToday) {
      dateText = 'Aujourd\'hui';
    } else if (isYesterday) {
      dateText = 'Hier';
    } else {
      dateText = DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(16)),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Text(
              dateText,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(12),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: getProportionateScreenHeight(8)),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(12),
                vertical: getProportionateScreenHeight(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == MessageType.image)
                    _buildImageMessage()
                  else if (message.type == MessageType.document)
                    _buildDocumentMessage()
                  else
                    _buildTextMessage(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: getProportionateScreenHeight(10),
                          color: isMe
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? CupertinoIcons.checkmark_alt_circle_fill
                              : CupertinoIcons.checkmark_alt_circle,
                          size: 12,
                          color: message.isRead
                              ? Colors.blue.shade200
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextMessage() {
    return Text(
      message.content,
      style: TextStyle(
        fontSize: getProportionateScreenHeight(15),
        color: isMe ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildImageMessage() {
    return GestureDetector(
      onTap: () {
        if (message.fileUrl != null) {
          _openFile(message.fileUrl!);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.fileUrl ?? '',
          width: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade200,
            child: const Icon(CupertinoIcons.photo, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentMessage() {
    return GestureDetector(
      onTap: () {
        if (message.fileUrl != null) {
          _openFile(message.fileUrl!);
        }
      },
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenWidth(12)),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.doc_fill,
              color: isMe ? Colors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'Document',
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(14),
                      fontWeight: FontWeight.w600,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(message.fileSize),
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(12),
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondary,
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
