import 'dart:convert';

class TeamRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String status; // "pending", "accepted", "rejected", "cancelled"
  final DateTime createdAt;
  final DateTime expiresAt;

  TeamRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  bool get isExpired {
    if (status != 'pending') return false;
    return DateTime.now().isAfter(expiresAt);
  }

  String get expiryStatusText {
    if (status != 'pending') return status.toUpperCase();
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return 'Expired';
    final diff = expiresAt.difference(now);
    if (diff.inHours >= 48) {
      return 'Expires in ${(diff.inHours / 24).ceil()}d';
    } else if (diff.inHours >= 24) {
      return 'Expires in 48h';
    } else if (diff.inHours >= 1) {
      return 'Expires in ${diff.inHours}h';
    } else {
      return 'Expires today';
    }
  }

  TeamRequest copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return TeamRequest(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory TeamRequest.fromMap(Map<String, dynamic> map) {
    return TeamRequest(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : DateTime.now().add(const Duration(hours: 72)),
    );
  }

  String toJson() => json.encode(toMap());

  factory TeamRequest.fromJson(String source) =>
      TeamRequest.fromMap(json.decode(source) as Map<String, dynamic>);
}
