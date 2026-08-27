class Pergunta {
  final int? id;
  final int userId;
  final String titulo;
  final String descricao;
  final int? materiaId;

  const Pergunta({
    this.id,
    required this.userId,
    required this.titulo,
    required this.descricao,
    this.materiaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'titulo': titulo,
      'descricao': descricao,
      'materia_id': materiaId,
    };
  }

  factory Pergunta.fromMap(Map<String, dynamic> map) {
    return Pergunta(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      materiaId: map['materia_id'] as int?,
    );
  }
}
