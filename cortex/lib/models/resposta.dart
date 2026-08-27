class Resposta {
  final int id;
  final int perguntaId;
  final int userId;
  final String texto;
  final bool melhorResposta;

  const Resposta({
    required this.id,
    required this.perguntaId,
    required this.userId,
    required this.texto,
    this.melhorResposta = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'perguntaId': perguntaId,
      'userId': userId,
      'texto': texto,
      'melhorResposta': melhorResposta,
    };
  }

  factory Resposta.fromMap(Map<String, dynamic> map) {
    return Resposta(
      id: map['id'] as int,
      perguntaId: map['perguntaId'] as int,
      userId: map['userId'] as int,
      texto: map['texto'] as String,
      melhorResposta: map['melhorResposta'] as bool? ?? false,
    );
  }
}
