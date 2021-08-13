
class Validator {

  String validateRequired(String value) {
    if (value.isEmpty) {
      return "This field is Required";
    }
    return null;
  }

  String validateName(String value) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "This field is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Name";
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "This field is Required";
    } else if(!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  String validateMobile(String value) {
    String pattern = r'^(?:[+0]9)?[0-9]{10}$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "This field is required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Mobile Number";
    } else {
      return null;
    }
  }

  String validateAlternateMobile(String value) {
    String pattern = r'^(?:[+0]9)?[0-9]{10}$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return null;
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Mobile Number";
    } else {
      return null;
    }
  }

  String validatePincode(String value) {
    if (value.isEmpty) {
      return "This field is Required";
    } else if (value.length != 6) {
      return "Invalid Pincode";
    }
    return null;
  }

  String validateQuantity(String value) {
    if (value.isEmpty) {
      return "This field is Required";
    } else if (value == '0' || value == '00' || value == '000' ||
        value == '0000' || value == '00000') {
      return "Invalid Quantity";
    }
    return null;
  }


}