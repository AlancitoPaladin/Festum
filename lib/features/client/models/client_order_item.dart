enum ClientOrderStatus {
  pendingProviderApproval('Pendiente de aprobación del proveedor', 1),
  inProgress('En proceso', 3),
  confirmed('Confirmada', 2),
  pendingPayment('Pendiente de pago', 1),
  completed('Completada', 4),
  cancelled('Cancelada', 1);

  const ClientOrderStatus(this.label, this.timelineCompletedSteps);

  final String label;
  final int timelineCompletedSteps;
}

extension ClientOrderStatusRules on ClientOrderStatus {
  Set<ClientOrderStatus> get allowedTransitions {
    switch (this) {
      case ClientOrderStatus.pendingProviderApproval:
        return <ClientOrderStatus>{
          ClientOrderStatus.confirmed,
          ClientOrderStatus.cancelled,
        };
      case ClientOrderStatus.pendingPayment:
        return <ClientOrderStatus>{
          ClientOrderStatus.confirmed,
          ClientOrderStatus.cancelled,
        };
      case ClientOrderStatus.confirmed:
        return <ClientOrderStatus>{
          ClientOrderStatus.inProgress,
          ClientOrderStatus.cancelled,
        };
      case ClientOrderStatus.inProgress:
        return <ClientOrderStatus>{
          ClientOrderStatus.completed,
          ClientOrderStatus.cancelled,
        };
      case ClientOrderStatus.completed:
      case ClientOrderStatus.cancelled:
        return <ClientOrderStatus>{};
    }
  }

  bool canTransitionTo(ClientOrderStatus next) {
    return allowedTransitions.contains(next);
  }
}

extension ClientOrderStatusApi on ClientOrderStatus {
  String get apiValue {
    switch (this) {
      case ClientOrderStatus.pendingProviderApproval:
        return 'pending_provider_approval';
      case ClientOrderStatus.pendingPayment:
        return 'pending_payment';
      case ClientOrderStatus.confirmed:
        return 'confirmed';
      case ClientOrderStatus.inProgress:
        return 'in_progress';
      case ClientOrderStatus.completed:
        return 'completed';
      case ClientOrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static ClientOrderStatus fromApi(String value) {
    switch (value.toLowerCase()) {
      case 'pending_provider_approval':
      case 'pending-provider-approval':
      case 'pendingproviderapproval':
        return ClientOrderStatus.pendingProviderApproval;
      case 'pending_payment':
      case 'pending-payment':
      case 'pendingpayment':
        return ClientOrderStatus.pendingPayment;
      case 'confirmed':
        return ClientOrderStatus.confirmed;
      case 'in_progress':
      case 'in-progress':
      case 'inprogress':
        return ClientOrderStatus.inProgress;
      case 'completed':
        return ClientOrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return ClientOrderStatus.cancelled;
      default:
        return ClientOrderStatus.pendingPayment;
    }
  }
}

class ClientOrderItem {
  const ClientOrderItem({
    required this.id,
    required this.title,
    required this.status,
    required this.totalLabel,
    this.items = const <ClientOrderLineItem>[],
    this.totalCents,
    this.subtotalCents,
    this.serviceFeeCents,
    this.taxCents,
    this.currency,
  });

  final String id;
  final String title;
  final ClientOrderStatus status;
  final String totalLabel;
  final List<ClientOrderLineItem> items;
  final int? totalCents;
  final int? subtotalCents;
  final int? serviceFeeCents;
  final int? taxCents;
  final String? currency;

  ClientOrderItem copyWith({
    String? id,
    String? title,
    ClientOrderStatus? status,
    String? totalLabel,
    List<ClientOrderLineItem>? items,
    int? totalCents,
    int? subtotalCents,
    int? serviceFeeCents,
    int? taxCents,
    String? currency,
  }) {
    return ClientOrderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      totalLabel: totalLabel ?? this.totalLabel,
      items: items ?? this.items,
      totalCents: totalCents ?? this.totalCents,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      serviceFeeCents: serviceFeeCents ?? this.serviceFeeCents,
      taxCents: taxCents ?? this.taxCents,
      currency: currency ?? this.currency,
    );
  }
}

class ClientOrderLineItem {
  const ClientOrderLineItem({
    required this.serviceId,
    required this.serviceName,
    this.productId,
    this.productName,
    this.unitPriceCents,
    this.totalItemCents,
    this.selectedProductIds = const <String>[],
    this.selectedProducts = const <ClientOrderSelectedProduct>[],
  });

  final String serviceId;
  final String serviceName;
  final String? productId;
  final String? productName;
  final int? unitPriceCents;
  final int? totalItemCents;
  final List<String> selectedProductIds;
  final List<ClientOrderSelectedProduct> selectedProducts;
}

class ClientOrderSelectedProduct {
  const ClientOrderSelectedProduct({
    required this.id,
    required this.name,
    this.unitPriceCents,
  });

  final String id;
  final String name;
  final int? unitPriceCents;
}
