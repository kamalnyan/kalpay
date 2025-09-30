import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String transactionId,
    required String shopId,
    required String customerId,
    required int amount, // in paise
    required String type, // 'credit' or 'debit'
    required String status, // 'outstanding', 'paid', 'partial'
    required String method, // 'paylater', 'upi', 'cash', 'other'
    String? note,
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? updatedAt,
    PaymentInfo? paymentInfo,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.create({
    required String shopId,
    required String customerId,
    required int amount,
    required String type,
    required String method,
    String? note,
    DateTime? dueDate,
  }) =>
      TransactionModel(
        transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        shopId: shopId,
        customerId: customerId,
        amount: amount,
        type: type,
        status: method == 'paylater' ? 'outstanding' : 'paid',
        method: method,
        note: note,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        paymentInfo: method != 'paylater' ? PaymentInfo(
          paidAt: DateTime.now(),
          paidBy: method,
        ) : null,
      );
}

@freezed
class PaymentInfo with _$PaymentInfo {
  const factory PaymentInfo({
    String? upiTxnId,
    DateTime? paidAt,
    String? paidBy,
    String? attachmentUrl,
    String? reference,
  }) = _PaymentInfo;

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);
}
