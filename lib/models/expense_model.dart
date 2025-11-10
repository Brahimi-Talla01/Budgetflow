class Expense {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final String? projectId;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.projectId,
  });

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    String? projectId,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
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
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'projectId': projectId,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      projectId: map['projectId'],
    );
  }
}
