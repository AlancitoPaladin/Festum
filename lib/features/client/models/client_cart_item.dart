class ClientCartItem {
  const ClientCartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
  });

  final String id;
  final String name;
  final int quantity;
  final int unitPriceCents;
}
