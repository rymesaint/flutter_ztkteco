import 'package:flutter_zkteco/src/util.dart';

enum UserType { admin, user }

class UserInfo {
  final int? uid;
  final String? userId;
  final String? name;
  final UserType? role;
  final String? password;
  final int? cardNo;

  const UserInfo({
    this.uid,
    this.userId,
    this.name,
    this.role,
    this.password,
    this.cardNo,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        uid: json['uid'],
        userId: json['userid'],
        name: json['name'],
        role: json['role'] == Util.LEVEL_USER ? UserType.user : UserType.admin,
        password: json['password'],
        cardNo: json['cardno'],
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userid': userId,
        'name': name,
        'role': role == UserType.user ? Util.LEVEL_USER : Util.LEVEL_ADMIN,
        'password': password,
        'cardno': cardNo,
      };

  @override
  String toString() {
    return 'UserInfo(uid: $uid, userId: $userId, name: $name, role: $role, password: $password, cardNo: $cardNo)';
  }
}
