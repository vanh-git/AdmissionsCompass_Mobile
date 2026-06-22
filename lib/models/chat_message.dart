import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String author;
  final String content;
  final DateTime timestamp;
  final int likes;

  const ChatMessage({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    required this.likes,
  });

  factory ChatMessage.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return ChatMessage(
      id: document.id,
      author: data['author'] as String? ?? 'Ẩn danh',
      content: data['content'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
    );
  }
}

String getInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  return words
      .take(2)
      .map((word) => word.characters.first)
      .join()
      .toUpperCase();
}

Color getAvatarColor(String name) {
  const colors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF22C55E),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
  ];
  final hash = name.runes.fold<int>(0, (value, rune) => value + rune);
  return colors[hash % colors.length];
}

String formatChatTime(DateTime timestamp, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final isToday =
      current.year == timestamp.year &&
      current.month == timestamp.month &&
      current.day == timestamp.day;
  if (isToday) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
  return '${timestamp.day.toString().padLeft(2, '0')}/'
      '${timestamp.month.toString().padLeft(2, '0')} '
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}';
}
