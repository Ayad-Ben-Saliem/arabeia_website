import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class Utils {
  Utils.pushPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static Set<int> uniqueSet = {};

  static int getUniqueTag() {
    int randomNumber;
    do {
      randomNumber = Random().nextInt(0x7FFFFFFF);
    } while (uniqueSet.contains(randomNumber));
    uniqueSet.add(randomNumber);
    return randomNumber;
  }

  static bool removeTag(Object object) {
    return uniqueSet.remove(object);
  }

  static bool isStartWithArabicChar(String text) {
    for (var char in text.characters) {
      if (RegExp('^[\u0621-\u064A]').hasMatch(char)) return true;
      if (RegExp('^[a-zA-Z]').hasMatch(char)) return false;
    }
    return false;
  }

  static E getEnumByString<E>(String value, List<E> values) {
    for (var val in values) {
      if (value == val.toString()) {
        return val;
      }
    }
    throw 'Enum $value not found in $values';
  }

  static void prettyPrint(Map<String, dynamic> json) {
    print(const JsonEncoder.withIndent('  ').convert(json));
  }

  static String getPrettyString(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  static String getReadableDate(DateTime dateTime) {
    var y = _fourDigits(dateTime.year);
    var m = _twoDigits(dateTime.month);
    var d = _twoDigits(dateTime.day);
    var h = _twoDigits(dateTime.hour);
    var min = _twoDigits(dateTime.minute);

    return '$y-$m-$d  $h:$min';
  }

  static String _fourDigits(int n) {
    var absN = n.abs();
    var sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  static bool boolean(Object? obj) {
    if (obj is bool) return obj;
    if (obj == null) return false;
    if (obj is num) return obj != 0;
    if (obj is Iterable) return obj.isNotEmpty;
    if (obj is String) return obj.isNotEmpty;

    return true;
  }

  static bool equalsNotNull(dynamic obj1, dynamic obj2) {
    return obj1 == null ||
        obj2 == null ||
        obj1 != null && obj2 != null && obj1 == obj2;
  }

  static void removeRepeatedObjects<T>(
      List<T> list1,
      List<T> list2,
      ) {
    for(var element in list1){
      if (list2.remove(element)) list1.remove(element);
    }
  }

  static Iterable<T> replace<T>(
      Iterable<T> iterable,
      T object,
      bool Function(T object) replaceCallback,
      ) {
    final list = iterable.toList();
    for (int i = 0; i < list.length; i++) {
      if (replaceCallback(list.elementAt(i))) {
        list.removeAt(i);
        list.insert(i, object);
      }
    }
    return list;
  }
}

abstract class Enum {
  final String str;

  const Enum(this.str);

  @override
  bool operator == (Object other) {
    if (other is String && other == str) return true;
    return super == other;
  }

  // List<T> get values<T extends Enum>;

  @override
  String toString() => str;

  @override
  int get hashCode => str.hashCode;
}

// typedef VarArgsCallback = dynamic Function(
//   List args,
//   Map<String, dynamic> kwargs,
// );
//
// Map<String, dynamic> map(Map<Symbol, dynamic> namedArguments) {
//   final _offset = 'Symbol("'.length;
//   return namedArguments.map(
//     (key, value) {
//       var _key = '$key';
//       _key = _key.substring(_offset, _key.length - 2);
//       return MapEntry(_key, value);
//     },
//   );
// }
//
// class VarargsFunction {
//   final VarArgsCallback callback;
//
//   VarargsFunction(this.callback);
//
//   @override
//   dynamic noSuchMethod(Invocation invocation) {
//     if (!invocation.isMethod || invocation.namedArguments.isNotEmpty)
//       super.noSuchMethod(invocation);
//     return callback(
//       invocation.positionalArguments,
//       map(invocation.namedArguments),
//     );
//   }
// }
//
// class ListenableFunction {
//   final callbacks = <VarArgsCallback>[];
//
//   final VarArgsCallback callback;
//
//   ListenableFunction(this.callback);
//
//   @override
//   dynamic noSuchMethod(Invocation invocation) {
//     if (invocation.isMethod) {
//       callbacks.forEach(
//         (callback) => callback(
//           invocation.positionalArguments,
//           map(invocation.namedArguments),
//         ),
//       );
//       return callback(
//         invocation.positionalArguments,
//         map(invocation.namedArguments),
//       );
//       ;
//     }
//     super.noSuchMethod(invocation);
//   }
//
//   void listen(VarArgsCallback callback) => callbacks.add(callback);
// }
//
// class Validation {
//   final bool valid;
//   final List<String>? errors;
//
//   Validation.valid()
//       : valid = true,
//         errors = null;
//
//   Validation.invalid([this.errors]) : valid = false;
//
//   @override
//   String toString() {
//     return valid ? 'valid' : 'invalid ${errors ?? ''}';
//   }
// }
//
// typedef ListenCallback<R, T> = R Function(T);
//
// class ValueListener<R, T> {
//   ListenCallback<R, T>? _callback;
//
//   ListenCallback<R, T>? get callback => _callback;
//
//   void listen(ListenCallback<R, T> callback) => _callback = callback;
// }