class History {
  final String id;
  final String question;
  final String answer;
  final DateTime timestamp;

  History({
    required this.id,
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
