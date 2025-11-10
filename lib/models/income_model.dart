class Income {
  final String id;
  final String userId;
  final double amount;
  final String source; // Ex: Salaire, Vente, Investissement, ...
  final DateTime date;
  final String description;
  final String? projectId;

  Income({
    required this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.date,
    required this.description,
    this.projectId,
  });

  Income copyWith({
    String? id,
    String? userId,
    double? amount,
    String? source,
    DateTime? date,
    String? description,
    String? projectId,
  }) {
    return Income(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      date: date ?? this.date,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'source': source,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'projectId': projectId,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      source: map['source'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      projectId: map['projectId'],
    );
  }
}
