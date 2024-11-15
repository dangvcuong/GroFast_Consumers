// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CategoryMenu extends StatelessWidget {
  final String title;
  final String imagePath;

  const CategoryMenu({
    super.key,
    required this.title,
    required this.imagePath,
  });

  static List<CategoryMenu> getCategoryList() {
    return [
      CategoryMenu(
          title: "Trái cây", imagePath: "assets/images/category/vegetable.png"),
      CategoryMenu(
          title: "Hoa quả", imagePath: "assets/images/category/fruit.png"),
      CategoryMenu(
          title: "Thực phẩm", imagePath: "assets/images/category/basket.png"),
      CategoryMenu(title: "Bánh", imagePath: "assets/images/category/milk.png"),
      CategoryMenu(
          title: "Đồ uống", imagePath: "assets/images/category/milk.png"),
      CategoryMenu(
          title: "Rau củ", imagePath: "assets/images/category/vegetable.png"),
      CategoryMenu(
          title: "Đồ dùng", imagePath: "assets/images/category/fruit.png"),
      CategoryMenu(
          title: "Thịt", imagePath: "assets/images/category/basket.png"),
      CategoryMenu(
          title: "Trái cây", imagePath: "assets/images/category/vegetable.png"),
      CategoryMenu(
          title: "Hoa quả", imagePath: "assets/images/category/fruit.png"),
      CategoryMenu(
          title: "Thực phẩm", imagePath: "assets/images/category/basket.png"),
      CategoryMenu(title: "Bánh", imagePath: "assets/images/category/milk.png"),
      CategoryMenu(
          title: "Đồ uống", imagePath: "assets/images/category/milk.png"),
      CategoryMenu(
          title: "Rau củ", imagePath: "assets/images/category/vegetable.png"),
      CategoryMenu(
          title: "Đồ dùng", imagePath: "assets/images/category/fruit.png"),
      CategoryMenu(
          title: "Thịt", imagePath: "assets/images/category/basket.png"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
