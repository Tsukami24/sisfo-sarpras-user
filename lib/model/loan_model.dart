class LoanItem {
  final int id;
  final String name;
  final int quantity;

  LoanItem({
    required this.id,
    required this.name,
    required this.quantity,
  });

  factory LoanItem.fromJson(Map<String, dynamic> json) {
    return LoanItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      quantity: json['pivot'] != null ? json['pivot']['quantity'] ?? 0 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }
}

class ReturnDetail {
  final int itemId;
  final String itemName;
  final int quantity;
  final String condition;
  final int fine;
  final String returnedDate;

  ReturnDetail({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.condition,
    required this.fine,
    required this.returnedDate,
  });

  factory ReturnDetail.fromJson(Map<String, dynamic> json) {
    return ReturnDetail(
      itemId: int.tryParse(json['item_id'].toString()) ?? 0,
      itemName: json['item']?['name'] ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      condition: json['condition'] ?? 'good',
      fine: ((double.tryParse(json['fine'].toString()) ?? 0.0).round()),
      returnedDate: json['returned_date'] ?? '',
    );
  }
}



class LoanHistory {
  final int id;
  final int userId;
  final String loanDate;
  final String returnDate;
  final String status;
  final List<LoanItem> items;
  final List<ReturnDetail> returns;

  LoanHistory({
  required this.id,
  required this.userId,
  required this.loanDate,
  required this.returnDate,
  required this.status,
  required this.items,
  required this.returns,
});

factory LoanHistory.fromJson(Map<String, dynamic> json) {
  return LoanHistory(
    id: int.tryParse(json['id'].toString()) ?? 0,
    userId: int.tryParse(json['user_id'].toString()) ?? 0,
    loanDate: json['loan_date'] ?? '',
    returnDate: json['return_date'] ?? '',
    status: json['status'] ?? '',
    items: (json['items'] as List)
        .map((item) => LoanItem.fromJson(item))
        .toList(),
    returns: (json['return_items'] as List?)
            ?.map((r) => ReturnDetail.fromJson(r))
            .toList() ??
        [],
  );
}
}
