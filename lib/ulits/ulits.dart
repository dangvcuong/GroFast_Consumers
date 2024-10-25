import 'package:get/get_common/get_reset.dart';
import 'package:get/state_manager.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grofast_consumers/constants/app_colors.dart';
import 'package:grofast_consumers/constants/app_sizes.dart';
import 'package:grofast_consumers/ulits/theme/app_style.dart';
import 'package:lottie/lottie.dart';
import 'package:toastification/toastification.dart';

class HAppUtils {
  // Định dạng chuỗi thời gian
  static String formatTimeAgo(DateTime datetime) {
    final Duration difference = DateTime.now().difference(datetime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Ngay bây giờ';
    }
  }

  // Xử lý số
  static int roundValue(int value) {
    int lastThreeDigits = value % 1000;
    if (lastThreeDigits >= 500) {
      return value + (1000 - lastThreeDigits);
    } else {
      return value - lastThreeDigits;
    }
  }

  // Ẩn tên
  static String maskName(String name) {
    if (name.length <= 1) {
      return name;
    }
    String firstChar = name[0];
    String maskedChars = '*' * (name.length - 1);
    return '$firstChar$maskedChars';
  }

  // Tiêu đề phương thức thanh toán
  static String getTitlePaymentMethod(String value) {
    switch (value) {
      case 'tien_mat':
        return 'Tiền mặt';
      case 'momo_vn':
        return 'Ví điện tử MoMo';
      case 'tin_dung':
        return 'Thanh toán bằng thẻ';
      default:
        return 'Không biết';
    }
  }

  // Trạng thái đặt hàng
  static String orderStatus(int status) {
    switch (status) {
      case 0:
        return 'Đơn đặt hàng thành công';
      case 1:
        return 'Cửa hàng tạp hóa xác nhận';
      case 2:
        return 'Người giao hàng xác nhận';
      case 3:
        return 'Người giao hàng đã lấy hàng';
      case 4:
        return 'Đơn giao tới nơi';
      default:
        return 'Trạng thái không xác định';
    }
  }

  // Định dạng tiền VND
  static String vietnamCurrencyFormatting(int amount) {
    return '${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}₫';
  }

  // Đổi từ m sang km
  static String metersToKilometers(double distanceInMeters) {
    double distanceInKilometers = distanceInMeters / 1000;
    return distanceInKilometers.toStringAsFixed(2);
  }

  // Hiển thị thông báo mất kết nối
  static void showLostMobileDataConnection(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(EvaIcons.wifiOffOutline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: HAppColor.hRedColor.shade400,
      borderRadius: 10,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      colorText: Colors.white,
      duration: const Duration(days: 1),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Hiển thị thông báo kết nối lại
  static void showConnectedToMobileData(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(EvaIcons.wifi, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: HAppColor.hBluePrimaryColor,
      borderRadius: 10,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Hiển thị SnackBar cảnh báo
  static void showSnackBarWarning(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(EneftyIcons.warning_2_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: HAppColor.hOrangeColor,
      borderRadius: 10,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Hiển thị SnackBar thành công
  static void showSnackBarSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(EneftyIcons.check_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: HAppColor.hBluePrimaryColor,
      borderRadius: 10,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Hiển thị SnackBar lỗi
  static void showSnackBarError(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(EneftyIcons.warning_2_outline, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: HAppColor.hRedColor.shade400,
      borderRadius: 10,
      margin: const EdgeInsets.all(hAppDefaultPadding),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Hiển thị Toast thông báo thành công
  static void showToastSuccess(
      Widget title,
      Widget description,
      int seconds,
      BuildContext context,
      ToastificationCallbacks callbacks,
      ) {
    toastification.show(
      context: context,
      callbacks: callbacks,
      progressBarTheme: const ProgressIndicatorThemeData(
        color: HAppColor.hBluePrimaryColor,
      ),
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: Duration(seconds: seconds),
      title: title,
      description: description,
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.check, color: HAppColor.hBluePrimaryColor),
      backgroundColor: HAppColor.hBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  // Hiển thị Toast thông báo lỗi
  static void showToastError(
      Widget title,
      Widget description,
      int seconds,
      BuildContext context,
      ToastificationCallbacks callbacks,
      ) {
    toastification.show(
      context: context,
      callbacks: callbacks,
      progressBarTheme: const ProgressIndicatorThemeData(
        color: HAppColor.hRedColor,
      ),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: Duration(seconds: seconds),
      title: title,
      description: description,
      alignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 300),
      icon: const Icon(Icons.close, color: HAppColor.hRedColor),
      backgroundColor: HAppColor.hBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  // Xác thực trường trống
  static String? validateEmptyField(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName chưa được điền.';
    }
    return null;
  }

  // Xác thực email
  static String? validateEmail(String? value) {
    validateEmptyField('Email', value);

    final emailRegExp = RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailRegExp.hasMatch(value!)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Xác thực mật khẩu
  static String? validatePassword(String? value) {
    validateEmptyField('Mật khẩu', value);

    if (value!.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất một số';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất một chữ cái thường';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất một chữ cái hoa';
    }

    return null;
  }

  // Hiển thị thông báo Lottie
  static void showLottieSuccessMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset(
            'assets/animations/success.json',
            repeat: false,
            width: 150,
            height: 150,
          ),
        );
      },
    );
  }
}
