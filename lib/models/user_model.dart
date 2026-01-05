import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:songkhoe/core/constants/enums.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final Gender gender;
  final DateTime? dob;
  final double? height;
  final double? weight;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.gender = Gender.other,
    this.dob,
    this.height,
    this.weight,
    this.avatarUrl,
  });

  int get age {
    if (dob == null) return 0;
    final now = DateTime.now();
    int a = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      a--;
    }
    return a;
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception("Data is null");

    return UserModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      address: data['address'],
      gender: Gender.fromJson(data['gender']),
      dob: (data['dob'] as Timestamp?)?.toDate(),
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      avatarUrl: data['avatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender.toJson(),
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'height': height,
      'weight': weight,
      'avatarUrl': avatarUrl,
    };
  }
}
