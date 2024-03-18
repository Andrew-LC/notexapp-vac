class Note {
  int? id;
  String? title;
  String? content;

  Note({
    this.id,
    this.title,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "content": content,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
}
