class Genre {
  final int id;
  final String name;
  final int? parentId;

  const Genre({
    required this.id,
    required this.name,
    this.parentId,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (parentId != null) 'parent_id': parentId,
    };
  }
}

class GenresResponse {
  final List<Genre> genres;

  const GenresResponse({required this.genres});

  factory GenresResponse.fromJson(Map<String, dynamic> json) {
    return GenresResponse(
      genres: (json['genres'] as List<dynamic>)
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}