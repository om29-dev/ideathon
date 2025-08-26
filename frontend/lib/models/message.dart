enum MessageSender { user, bot, error }

class Message {
  final int id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool hasExpenses;
  final Map<String, dynamic>? excelData;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.hasExpenses = false,
    this.excelData,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      sender: MessageSender.values[json['sender']],
      timestamp: DateTime.parse(json['timestamp']),
      hasExpenses: json['hasExpenses'] ?? false,
      excelData: json['excelData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.index,
      'timestamp': timestamp.toIso8601String(),
      'hasExpenses': hasExpenses,
      'excelData': excelData,
    };
  }
}
