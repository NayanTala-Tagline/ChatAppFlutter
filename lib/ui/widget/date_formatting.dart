import 'package:intl/intl.dart';

var usingDeviceTime = true;

DateTime currentSystemDateTime() {
  if (usingDeviceTime) {
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
  } else {
    // Example: 25th Dec 2021, 17:23:45
    return DateTime(2021, 12, 25, 17, 23, 45);
  }
}

extension DateFormatting on DateTime {
  String? get simpleDateFormat {
    if (this == null) return null;
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(toLocal());
  }

  String? get dayMonthYearFormat {
    if (this == null) return null;
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(toLocal());
  }

  String? get simpleTimeFormat {
    if (this == null) return null;
    final formatter = DateFormat('hh:mm aa');
    return formatter.format(toLocal());
  }

  String? get dayOnly {
    if (this == null) return null;
    final formatter = DateFormat('dd');
    return formatter.format(toLocal());
  }

  String? get monthOnly {
    if (this == null) return null;
    final formatter = DateFormat('MMMM');
    return formatter.format(toLocal());
  }

  String? get monthOnlyShort {
    if (this == null) return null;
    final formatter = DateFormat('MMM');
    return formatter.format(toLocal());
  }

  String? get dayOfTheWeek {
    if (this == null) return null;
    final formatter = DateFormat('EE');
    return formatter.format(toLocal());
  }

  String? get weekdayAndDate {
    if (this == null) return null;
    final formatter = DateFormat('EEEE dd MMM');
    return formatter.format(toLocal());
  }

  String? get weekdayAndMonth {
    if (this == null) return null;
    final formatter = DateFormat('EEE dd MMMM');
    return formatter.format(toLocal());
  }
}

extension DateTimeComparison on DateTime {
  // Returns if the current date is the same local date as another (ie. ignoring hh, mm, ss)
  bool isSameDayMonthYear(DateTime other) {
    final localThis = toLocal();
    final localOther = other.toLocal();
    return localThis.year == localOther.year &&
        localThis.month == localOther.month &&
        localThis.day == localOther.day;
  }
}
