  class Item {
    final int id;
    final String name;
    final String description;
    final int stock;
    final int total;
    final String image_url;
    final String categoryName;

    Item({
      required this.id,
      required this.name,
      required this.description,
      required this.stock,
      required this.total,
      required this.image_url,
      required this.categoryName,
    });

    factory Item.fromJson(Map<String, dynamic> json) {
      return Item(
        id: int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        stock: int.tryParse(json['stock'].toString()) ?? 0,
        total: int.tryParse(json['total'].toString()) ?? 0,
        image_url: json['image_url'] ?? '',
        categoryName: json['category']?['name'] ?? '-',
      );
    }

  }
