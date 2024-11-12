import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grofast_consumers/features/shop/models/product_model.dart';

class SearchProductController extends GetxController {
  static SearchProductController get instance => Get.find();

  final TextEditingController controller = TextEditingController();
  var historySearch = [].obs;

  var showSuffixIcon = [].obs;
  var showFilter = false.obs;

  removeHistorySearch(int index) {
    historySearch.removeAt(index);
    update();
  }

  removeAllHistory() {
    historySearch.clear();
    update();
  }

  addHistorySearch() {
    if (controller.text.isNotEmpty) {
      historySearch.add(controller.text);
    }
    update();
  }

  // Danh sách các sản phẩm phù hợp với từ khóa tìm kiếm
  var resultProduct = <Product>[].obs;

  var productInSearch = <String, List<Product>>{}.obs;

  addListProductInSearch(List<Product> list) {
    resultProduct.value = list
        .where((product) =>
            product.name.toLowerCase().contains(controller.text.toLowerCase()))
        .toList();
    update();
  }

  addMapInSearch() {
    productInSearch.clear();
    for (var product in resultProduct) {
      if (!productInSearch.containsKey(product.idHang)) {
        productInSearch.addAll({
          product.idHang: List.from(resultProduct
              .where((productIsInSearch) =>
                  productIsInSearch.idHang == product.idHang)
              .toList())
        });
      } else {
        productInSearch.update(
            product.idHang,
            (value) => List.from(resultProduct
                .where((productIsInSearch) =>
                    productIsInSearch.idHang == product.idHang)
                .toList()));
      }
      update();
    }
    update();
  }
}
