class PackItem {
  String id;
  String name;
  String category;
  int quantity;
  bool packed;
  bool essential;
  String notes;

  PackItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.packed,
    required this.essential,
    required this.notes,
  });

  factory PackItem.fromJson(Map<String, dynamic> json) {
    return PackItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      packed: json['packed'] as bool? ?? false,
      essential: json['essential'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'packed': packed,
        'essential': essential,
        'notes': notes,
      };
}

class Trip {
  String id;
  String title;
  String destination;
  DateTime startDate;
  DateTime endDate;
  String notes;
  List<PackItem> items;
  DateTime createdAt;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.items,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String? ?? '',
      items: ((json['items'] as List?) ?? [])
          .whereType<Map>()
          .map((e) => PackItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'destination': destination,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'notes': notes,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  Trip duplicate() {
    final now = DateTime.now();
    final duration = endDate.difference(startDate);

    return Trip(
      id: '${now.microsecondsSinceEpoch}',
      title: '$title Copy',
      destination: destination,
      startDate: now,
      endDate: now.add(duration.isNegative ? Duration.zero : duration),
      notes: notes,
      items: List.generate(
        items.length,
        (index) {
          final item = items[index];
          return PackItem(
            id: '${now.microsecondsSinceEpoch}_$index',
            name: item.name,
            category: item.category,
            quantity: item.quantity,
            packed: false,
            essential: item.essential,
            notes: item.notes,
          );
        },
      ),
      createdAt: now,
    );
  }
}
