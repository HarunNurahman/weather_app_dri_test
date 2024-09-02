import 'package:intl/intl.dart';

class AppFormat {
  String formatTime(String datetime) {
    try {
      if (datetime.length == 12) {
        String datePart = datetime.substring(0, 8);
        String timePart = datetime.substring(8, 12);

        DateTime parsedDatetime = DateTime.parse('${datePart}T$timePart');
        return DateFormat('HH:mm').format(parsedDatetime);
      } else {
        print('Unexpected datetime length: ${datetime.length}');
        return "Invalid Time";
      }
    } catch (e) {
      print('Error parsing datetime: $e');
      return "Invalid Time";
    }
  }
}
