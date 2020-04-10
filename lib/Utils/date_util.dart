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

  static String getDuration(int timeStamp) {
    var currTime = new DateTime.now().millisecondsSinceEpoch;
    int timeDiff = currTime.round() - timeStamp;
    Duration fastestMarathon = new Duration(milliseconds: timeDiff);
    String s = "";
    int minutes = fastestMarathon.inMinutes;
    int hours = fastestMarathon.inHours;
    int days = fastestMarathon.inDays;
    int seconds = fastestMarathon.inSeconds;
//    print(timeDiff);
    if (days < 30) {
      s = days.toString() + " days ago";

      if (hours < 24) {
        s = hours.toString() + "h ago";

        if (minutes < 60) {
          s = minutes.toString() + "m ago";

          if (seconds < 60) {
            if (seconds < 0) {
              s = "0 sec ago";
            } else {
              s = seconds.toString() + " sec ago";
            }
          }
        }
      }
    } else {
      s = "month ago";
    }
    return s;
  }
}
