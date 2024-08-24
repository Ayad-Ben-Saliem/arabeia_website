import 'dart:html' as html;

import 'package:flutter/widgets.dart';

typedef JsonMap = Map<String, dynamic>;

String get baseUrl => html.window.location.origin;

String readableMoney(double money, {int fractionDigits = 3}) {
  return double2String(money, fractionDigits: fractionDigits);
}

String readableDouble(double number, {int fractionDigits = 3}) {
  return double2String(number, fractionDigits: fractionDigits);
}

String double2String(double number, {int fractionDigits = 20}) {
  var result = number.toStringAsFixed(fractionDigits);
  var lastIndex = result.length - 1;
  while (result.contains('.')) {
    if (result[lastIndex] == '0' || result[lastIndex] == '.') {
      result = result.substring(0, lastIndex);
      lastIndex--;
    } else {
      break;
    }
  }
  return result;
}


class DeviceType {
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 900;
  }

  static bool isPC(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
}
