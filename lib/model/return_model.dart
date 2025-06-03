class ReturnItem {
  final int loanId;
  final int itemId;
  final int quantity;

  ReturnItem({
    required this.loanId,
    required this.itemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'loan_id': loanId,
      'item_id': itemId,
      'quantity': quantity
    };
  }
}
