
import 'package:flutter/material.dart';

const String EMPTY = '';
const int ZERO = 0;
const double ZERO_DECIMAL = 0.0;
const bool FALSE = false;

extension NonNullString on String? {
  String orEmpty() {
    if (this == null) {
      return EMPTY;
    } else {
      return this!;
    }
  }
}

extension EmptyToNUll on String? {
  String? notEmptyOrNull() {
    if (this != null && this!.isNotEmpty) {
      return this!;
    } else {
      return null;
    }
  }

  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }

  bool isNotNullOrEmpty() {
    return !(this == null || this!.isEmpty);
  }

  String? parsePhoneWithoutCode(String phoneCode) {
    String? fullPhone = this;
    if (fullPhone.isNullOrEmpty()) {
      return null;
    }

    if (fullPhone!.isNotEmpty && fullPhone.startsWith(phoneCode)) {
      List<String> splits = [fullPhone.substring(0, phoneCode.length), fullPhone.substring(phoneCode.length)];


      if (splits.length > 1) {
        return splits[1];
      }
    }
    return null;
  }
}

extension ZeroToNUll on int? {
  int? notZeroOrNull() {
    if (this != null && this! > 0) {
      return this!;
    } else {
      return null;
    }
  }
}

extension NumZeroToNUll on num? {
  num? notZeroOrNull() {
    if (this != null && this! > 0) {
      return this!;
    } else {
      return null;
    }
  }
}

extension NonNullInteger on int? {
  int orZero() {
    if (this == null) {
      return ZERO;
    } else {
      return this!;
    }
  }
}

extension NonNullDouble on double? {
  double orZero() {
    if (this == null) {
      return ZERO_DECIMAL;
    } else {
      return this!;
    }
  }
}

extension NonNullNum on num? {
  num orZero() {
    if (this == null) {
      return ZERO_DECIMAL;
    } else {
      return this!;
    }
  }
}

extension NonNullBoolean on bool? {
  bool orFalse() {
    return this ?? FALSE;
  }
}

extension StringToInteger on String? {
  int toInt() {
    if (this == null) {
      return ZERO;
    } else {
      return int.parse(this!);
    }
  }
}

extension BoolParsing on String? {
  bool toBool() {
    if (this == null) return false;
    return this!.toLowerCase() == 'true';
  }
}

extension StringToNum on String? {
  num toNum() {
    try {
      if (this == null) {
        return 0.00;
      } else {
        return num.parse(this!);
      }
    } catch (e) {
      return 0.00;
    }
  }
}

extension COuntyrCodeToISOCOde on String {
  String toISO() {
    return '${this}N';
  }
}


extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension RemoveDotFromString on String {
  String removeDot() {
    return replaceAll('.', '');
  }

  String toWordCase() {
    if (isEmpty) return this;

    final words = split('_');
    final capitalizedWords = words.map((word) => word[0].toUpperCase() + word.substring(1));
    return capitalizedWords.join(' ');
  }

  String ellipse(int maxLength) {
    if (length <= maxLength) {
      return this;
    } else {
      return '${substring(0, maxLength)}...';
    }
  }

  String removeEmojis() {
    RegExp regExp = RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]|\ufe0f)');
    return replaceAll(regExp, '');
  }

  String withFallback(String fallback) {
    if (isNullOrEmpty()) {
      return fallback;
    } else {
      return this;
    }
  }
}



extension KeyboardFocus on BuildContext {
  FocusScopeNode get keyboardFocus => FocusScope.of(this);

  FocusNode? get focus => FocusManager.instance.primaryFocus;
}

extension ListOperation<T> on List<T> {
  void replaceAll(Iterable<T> iterable) {
    clear();
    addAll(iterable);
  }
}
