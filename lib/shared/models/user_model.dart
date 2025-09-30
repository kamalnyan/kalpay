import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String phoneNumber,
    required String role, // 'shopkeeper' or 'customer'
    String? shopName,
    String? upiId,
    String? gstNumber,
    String? address,
    @Default(false) bool isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? settings,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.shopkeeper({
    required String uid,
    required String phoneNumber,
    required String shopName,
    String? upiId,
  }) =>
      UserModel(
        uid: uid,
        phoneNumber: phoneNumber,
        role: 'shopkeeper',
        shopName: shopName,
        upiId: upiId,
        createdAt: DateTime.now(),
      );

  factory UserModel.customer({
    required String uid,
    required String phoneNumber,
  }) =>
      UserModel(
        uid: uid,
        phoneNumber: phoneNumber,
        role: 'customer',
        createdAt: DateTime.now(),
      );
}
