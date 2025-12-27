import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, document, audio }

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String receiverId;
  final String content;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.receiverId,
    required this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantsInfo;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final MessageType? lastMessageType;
  final Map<String, int> unreadCount;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.participants,
    required this.participantsInfo,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageType,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantsInfo: Map<String, dynamic>.from(
        data['participantsInfo'] ?? {},
      ),
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageType: data['lastMessageType'] != null
          ? MessageType.values.firstWhere(
              (e) => e.toString() == 'MessageType.${data['lastMessageType']}',
              orElse: () => MessageType.text,
            )
          : null,
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantsInfo': participantsInfo,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'lastMessageType': lastMessageType?.toString().split('.').last,
      'unreadCount': unreadCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  Map<String, dynamic> getOtherParticipantInfo(String currentUserId) {
    final otherParticipantId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    return participantsInfo[otherParticipantId] ?? {};
  }
}
