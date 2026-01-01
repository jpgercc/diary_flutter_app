class Entry {
  final int id;
  final String title;
  final String content;
  final DateTime date;

  Entry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': dateStr,
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    // Conversão segura do ID (aceita String ou int)
    int parsedId;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] is String) {
      parsedId = int.tryParse(json['id']) ?? DateTime.now().millisecondsSinceEpoch;
    } else {
      parsedId = DateTime.now().millisecondsSinceEpoch;
    }

    // Conversão segura da data (aceita formato antigo com hora ou novo só data)
    DateTime parsedDate;
    try {
      if (json['date'] != null) {
        parsedDate = DateTime.parse(json['date'].toString());
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Entry(
      id: parsedId,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      date: parsedDate,
    );
  }
}
