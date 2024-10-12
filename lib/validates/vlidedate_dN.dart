// ignore_for_file: file_names, camel_case_types

class validete {
  static final validete _instance = validete._internal();

  // Private constructor
  validete._internal();

  // Factory constructor to return the same instance
  factory validete() {
    return _instance;
  }
  bool check = true;

  void clear() {
    errorMessageEmail = "";
    errorMessagePass = "";
  }

  String errorMessageEmail = "";
  bool? validateEmail(String email) {
    // Biểu thức chính quy để kiểm tra định dạng email
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    if (email.isEmpty) {
      errorMessageEmail = "Email không được để trống";
      check = false;
    } else if (!regExp.hasMatch(email)) {
      errorMessageEmail = "Email không hợp lệ";
      check = false;
    } else {
      errorMessageEmail = "";
    }

    return check;
  }

//   // Hàm validate mật khẩu
  String errorMessagePass = "";
  bool validatePassword(String password) {
    if (password.isEmpty) {
      errorMessagePass = "Mật khẩu không được để trống";
      check = false;
    } else if (password.length < 6) {
      errorMessagePass = "Mật khẩu phải có ít nhất 6 ký tự";
      check = false;
    } else {
      errorMessagePass = "";
    }
    // Bạn có thể thêm quy tắc khác nếu cần như yêu cầu ký tự đặc biệt
    return check;
  }
}
