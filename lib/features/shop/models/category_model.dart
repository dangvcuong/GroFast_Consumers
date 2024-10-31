import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CategoryModel {
  String id;
  String name;
  String image;

  CategoryModel({
    required this.id,
    required this.image,
    required this.name,
  });

  static CategoryModel empty() => CategoryModel(id: '', image: '', name: '');

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Image': image,
    };
  }

  factory CategoryModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return CategoryModel(
        id: document.id,
        image: data['Name'] ?? '',
        name: data['Image'] ?? '',
      );
    }
    return CategoryModel.empty();
  }
}

String displayUnit(String idHang) {
  switch (idHang) {
    case "-OAILvF-j4bmiGDvVuid":
      return "kg";
    case "-OAW4dwvRnrhTQHPwXrr":
      return "chai";
    case "-OAILiSWs97veFGxZRR0":
      return "chai/hộp";
    default:
      return "cái";
  }
}
