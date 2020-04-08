import 'package:intl/intl.dart';
import 'package:plunes/res/StringsFile.dart';

class DateUtil {
  static String getTimeWithAmAndPmFormat(DateTime date) {
    if (date == null) return PlunesStrings.NA;
    var _dateFormat = DateFormat.jm();
    try {
      return _dateFormat.format(date);
    } catch (e) {
      return PlunesStrings.NA;
    }
  }

  static String getDayAsString(DateTime date) {
    if (date == null) return PlunesStrings.NA;
    var _dateFormat = DateFormat.E();
    try {
      return _dateFormat.format(date);
    } catch (e) {
      return PlunesStrings.NA;
    }
  }
}
