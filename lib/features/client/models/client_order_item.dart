enum ClientOrderStatus {
  inProgress('En proceso', 2),
  confirmed('Confirmada', 3),
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
  });

  final String id;
  final String title;
  final ClientOrderStatus status;
  final String totalLabel;

  ClientOrderItem copyWith({
    String? id,
    String? title,
    ClientOrderStatus? status,
    String? totalLabel,
  }) {
    return ClientOrderItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      totalLabel: totalLabel ?? this.totalLabel,
    );
  }
}
