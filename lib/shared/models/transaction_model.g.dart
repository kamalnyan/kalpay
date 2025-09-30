// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      transactionId: json['transactionId'] as String,
      shopId: json['shopId'] as String,
      customerId: json['customerId'] as String,
      amount: (json['amount'] as num).toInt(),
      type: json['type'] as String,
      status: json['status'] as String,
      method: json['method'] as String,
      note: json['note'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      paymentInfo: json['paymentInfo'] == null
          ? null
          : PaymentInfo.fromJson(json['paymentInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'shopId': instance.shopId,
      'customerId': instance.customerId,
      'amount': instance.amount,
      'type': instance.type,
      'status': instance.status,
      'method': instance.method,
      'note': instance.note,
      'dueDate': instance.dueDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'paymentInfo': instance.paymentInfo,
    };

_$PaymentInfoImpl _$$PaymentInfoImplFromJson(Map<String, dynamic> json) =>
    _$PaymentInfoImpl(
      upiTxnId: json['upiTxnId'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      paidBy: json['paidBy'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      reference: json['reference'] as String?,
    );

Map<String, dynamic> _$$PaymentInfoImplToJson(_$PaymentInfoImpl instance) =>
    <String, dynamic>{
      'upiTxnId': instance.upiTxnId,
      'paidAt': instance.paidAt?.toIso8601String(),
      'paidBy': instance.paidBy,
      'attachmentUrl': instance.attachmentUrl,
      'reference': instance.reference,
    };
