/// Represents a single message in the chat conversation.
///
/// TYPES:
/// - system  → hidden prompt (never shown in UI)
/// - ai      → Vicharane's response (shown as AI bubble)
/// - user    → user's selected option or typed text (shown as user bubble)
///
/// The [metadata] field stores structured data like parsed options,
/// phase info, etc. — anything beyond the display text.
class ChatMessage {
  final String id;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.type,
    required this.content,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convenience constructors for common message types
  factory ChatMessage.ai(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: _generateId(),
      type: MessageType.ai,
      content: content,
      metadata: metadata,
    );
  }

  factory ChatMessage.user(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: _generateId(),
      type: MessageType.user,
      content: content,
      metadata: metadata,
    );
  }

  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: _generateId(),
      type: MessageType.system,
      content: content,
    );
  }

  /// Convert to the format OpenRouter API expects
  Map<String, String> toApiFormat() {
    return {
      'role': type == MessageType.ai
          ? 'assistant'
          : type == MessageType.system
              ? 'system'
              : 'user',
      'content': content,
    };
  }

  static int _counter = 0;
  static String _generateId() {
    _counter++;
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_$_counter';
  }
}

enum MessageType {
  system,
  ai,
  user,
}
