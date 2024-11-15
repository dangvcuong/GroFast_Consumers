// ignore_for_file: file_names, camel_case_types

class valideteDK {
  static final valideteDK _instance = valideteDK._internal();

  // Private constructor
  valideteDK._internal();

  // Factory constructor to return the same instance
  factory valideteDK() {
    return _instance;
  }
  bool check = true;

  void clear() {
    errorMessageEmail = "";
    errorMessageName = "";
    errorMessagePass = "";
    errorMessagePassConfic = "";
    errorMessagePhone = "";
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

  String errorMessagePass = "";
  bool validatePassword(String password) {
    if (password.isEmpty) {
      errorMessagePass = "Mật khẩu không được để trống";
      check = false;
    } else if (password.length < 6) {
      errorMessagePass = "Mật khẩu phải có ít nhất 6 ký tự";
      check = false;
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      errorMessagePass = "Mật khẩu phải có ít nhất một chữ in hoa";
      check = false;
    } else if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      errorMessagePass = "Mật khẩu phải có ít nhất một chữ số";
      check = false;
    }
    // Kiểm tra chứa ít nhất một ký tự đặc biệt
    else if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(password)) {
      errorMessagePass = "Mật khẩu phải có ít nhất một ký tự đặc biệt";
      check = false;
    } else {
      errorMessagePass = ""; // Không có lỗi
    }
    // Bạn có thể thêm quy tắc khác nếu cần như yêu cầu ký tự đặc biệt
    return check;
  }

  String errorMessagePassConfic = "";
  bool validatePasswordConfic(String passwordConfic, String pass) {
    // Khởi tạo biến kiểm tra hợp lệ
    if (passwordConfic.isEmpty) {
      errorMessagePassConfic = "Nhập lại mật khẩu không được để trống";
      check = false;
    } else if (passwordConfic.length < 6) {
      errorMessagePassConfic = "Mật khẩu phải có ít nhất 6 ký tự";
      check = false;
    } else if (passwordConfic != pass) {
      errorMessagePassConfic = "Nhập lại mật khẩu không đúng";
      check = false;
    } else {
      errorMessagePassConfic = ""; // Không có lỗi
    }

    // Bạn có thể thêm quy tắc khác nếu cần như yêu cầu ký tự đặc biệt
    return check; // Trả về kết quả kiểm tra
  }

  String errorMessagePhone = "";
  bool validatePhone(String phone) {
    // Kiểm tra số điện thoại có đủ số lượng ký tự và chỉ chứa số không
    final RegExp phoneRegExp = RegExp(r'^[0-9]+$');
    if (phone.isEmpty) {
      errorMessagePhone = 'Số điện thoại không được để trống';
      check = false;
    } else if (phone.length < 10 || !phoneRegExp.hasMatch(phone)) {
      errorMessagePhone = 'Số điện thoại không hợp lệ';
      check = false;
    } else {
      errorMessagePhone = '';
    }
    return check; // trả về null nếu không có lỗi
  }

  String errorMessageName = "";
  bool validateName(String name) {
    if (name.isEmpty) {
      errorMessageName = 'Không được để trống';
      check = false;
    } else {
      errorMessageName = "";
    }
    return check; // trả về null nếu không có lỗi
  }
}
