class ReturnItem {
  final int itemId;
  final int quantity;
  final String condition;

  ReturnItem({
    required this.itemId,
    required this.quantity,
    required this.condition,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
        'condition': condition,
      };
}

class ReturnRequest {
  final int loanId;
  final List<ReturnItem> items;

  ReturnRequest({required this.loanId, required this.items});

  Map<String, dynamic> toJson() => {
        'loan_id': loanId,
        'items': items.map((item) => item.toJson()).toList(),
      };
}
