import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String shopId,
    required String name,
    required String phone,
    String? email,
    String? address,
    @Default(0) int outstandingAmount, // in paise
    @Default([]) List<String> transactionIds,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);

  factory Customer.create({
    required String shopId,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) =>
      Customer(
        id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
        shopId: shopId,
        name: name,
        phone: phone,
        email: email,
        address: address,
        createdAt: DateTime.now(),
      );
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String customerId,
    required double amount,
    required TransactionType type,
    required TransactionStatus status,
    required PaymentMethod method,
    String? note,
    String? description,
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? updatedAt,
    PaymentInfo? paymentInfo,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

@freezed
class PaymentInfo with _$PaymentInfo {
  const factory PaymentInfo({
    String? upiTransactionId,
    String? referenceNumber,
    DateTime? paidAt,
    String? paidBy,
    String? attachmentUrl,
    PaymentMethod? actualMethod,
    @Default({}) Map<String, dynamic> additionalData,
  }) = _PaymentInfo;

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => _$PaymentInfoFromJson(json);
}

enum TransactionType {
  @JsonValue('credit')
  credit,
  @JsonValue('debit')
  debit,
}

enum TransactionStatus {
  @JsonValue('outstanding')
  outstanding,
  @JsonValue('paid')
  paid,
  @JsonValue('partial')
  partial,
  @JsonValue('overdue')
  overdue,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('upi')
  upi,
  @JsonValue('card')
  card,
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('other')
  other,
  @JsonValue('pay_later')
  payLater,
}
