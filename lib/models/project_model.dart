import 'package:flutter/material.dart';

class Project {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final DateTime creationDate;
  final Color color;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.creationDate,
    required this.color,
  });

  //Convertir un objet ProjetModal en Map (Pour la sauvegarde dans Firebase);
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'color': color.value,
    };
  }

  // Objet Projet à partir d'une Map (Récupéré depuis Firebase)
  factory Project.fromMap(Map<String, dynamic> map) {
    final targetAmount = (map['targetAmount'] as num?)?.toDouble() ?? 0.0;
    final colorValue = (map['colorValue'] as int?) ?? 0xFF9E9E9E;

    // Sécurisation de la lecture de la date
    final creationDateMillis =
        map['creationDate'] as int? ?? DateTime.now().millisecondsSinceEpoch;

    return Project(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      // Utiliser les valeurs sécurisées
      targetAmount: targetAmount,
      creationDate: DateTime.fromMillisecondsSinceEpoch(creationDateMillis),
      color: Color(colorValue),
    );
  }

  // Faciliter la modification d'un projet
  Project copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    DateTime? creationDate,
    Color? color,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      creationDate: creationDate ?? this.creationDate,
      color: color ?? this.color,
    );
  }
}
