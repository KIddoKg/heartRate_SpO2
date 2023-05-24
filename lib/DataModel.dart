class Feed {
  DateTime createdAt;
  int entryId;
  String field1;
  String? field2;

  Feed({
    required this.createdAt,
    required this.entryId,
    required this.field1,
    this.field2,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
    createdAt: DateTime.parse(json["created_at"]),
    entryId: json["entry_id"],
    field1: json["field1"],
    field2: json["field2"],
  );
}

class Model {
  DateTime createdAt;
  int entryId;
  String field1;
  String? field2;

  Model({
    required this.createdAt,
    required this.entryId,
    required this.field1,
    this.field2,
  });

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    createdAt: DateTime.parse(json["created_at"]),
    entryId: json["entry_id"],
    field1: json["field1"],
    field2: json["field2"],
  );
}