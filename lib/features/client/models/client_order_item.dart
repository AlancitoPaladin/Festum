class ClientOrderItem {
  const ClientOrderItem({
    required this.id,
    required this.title,
    required this.status,
    required this.totalLabel,
  });

  final String id;
  final String title;
  final String status;
  final String totalLabel;
}
