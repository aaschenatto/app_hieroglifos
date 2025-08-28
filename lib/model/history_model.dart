class History {
  final int? id;
  final String texto;
  final String? imagePath;

  History({this.id, required this.texto, this.imagePath});

  Map<String, dynamic> toMap() {
    return {'id': id, 'texto': texto, 'image_path': imagePath};
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      texto: map['texto'],
      imagePath: map['image_path'],
    );
  }

  History copyWith({int? id, String? texto, String? imagePath}) {
    return History(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() => 'History(id: $id, texto: $texto, imagePath: $imagePath)';
}
