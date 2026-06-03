class AbonelikModel {
  final String type; // 'su', 'elektrik', 'dogalgaz'
  final bool isSubscribed;
  final String subscriptionNo;
  final int daysRemaining;
  final double usageRemaining;
  final String planName;
  final double debt;
  final List<InvoiceModel> invoiceHistory;

  AbonelikModel({
    required this.type,
    required this.isSubscribed,
    required this.subscriptionNo,
    required this.daysRemaining,
    required this.usageRemaining,
    required this.planName,
    required this.debt,
    required this.invoiceHistory,
  });

  AbonelikModel copyWith({
    String? type,
    bool? isSubscribed,
    String? subscriptionNo,
    int? daysRemaining,
    double? usageRemaining,
    String? planName,
    double? debt,
    List<InvoiceModel>? invoiceHistory,
  }) {
    return AbonelikModel(
      type: type ?? this.type,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionNo: subscriptionNo ?? this.subscriptionNo,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      usageRemaining: usageRemaining ?? this.usageRemaining,
      planName: planName ?? this.planName,
      debt: debt ?? this.debt,
      invoiceHistory: invoiceHistory ?? this.invoiceHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'isSubscribed': isSubscribed,
      'subscriptionNo': subscriptionNo,
      'daysRemaining': daysRemaining,
      'usageRemaining': usageRemaining,
      'planName': planName,
      'debt': debt,
      'invoiceHistory': invoiceHistory.map((x) => x.toJson()).toList(),
    };
  }

  factory AbonelikModel.fromJson(Map<String, dynamic> json) {
    return AbonelikModel(
      type: json['type'] as String,
      isSubscribed: json['isSubscribed'] as bool,
      subscriptionNo: json['subscriptionNo'] as String,
      daysRemaining: json['daysRemaining'] as int,
      usageRemaining: (json['usageRemaining'] as num).toDouble(),
      planName: json['planName'] as String,
      debt: (json['debt'] as num).toDouble(),
      invoiceHistory: (json['invoiceHistory'] as List<dynamic>)
          .map((x) => InvoiceModel.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InvoiceModel {
  final String id;
  final double amount;
  final DateTime date;
  final String status; // 'odenmis', 'odenmemis'

  InvoiceModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
    );
  }
}
