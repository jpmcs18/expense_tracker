import 'app_localizations.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter(this.localizations);

  AppLocalizations localizations;

  String getVerboseDateTimeRepresentation(DateTime dateTime) {
    if (dateTime != null) {
      DateTime now = DateTime.now();
      DateTime justNow = now.subtract(Duration(minutes: 1));
      DateTime localDateTime = dateTime.toLocal();

      if (!localDateTime.difference(justNow).isNegative) {
        return localizations.translate('dateFormatter_just_now');
        //return 'Just now';
      }

      String roughTimeString = DateFormat('jm').format(dateTime);

      if (localDateTime.day == now.day &&
          localDateTime.month == now.month &&
          localDateTime.year == now.year) {
        return roughTimeString;
      }

      DateTime yesterday = now.subtract(Duration(days: 1));

      if (localDateTime.day == yesterday.day &&
          localDateTime.month == now.month &&
          localDateTime.year == now.year) {
        return localizations.translate('dateFormatter_yesterday');
        //return 'Yesterday, ' + roughTimeString;
      }

      if (now.difference(localDateTime).inDays < 4) {
        String weekday =
            DateFormat('EEEE', localizations.locale.toLanguageTag())
                .format(localDateTime);

        return '$weekday, $roughTimeString';
      }

      return '${DateFormat('yMd', localizations.locale.toLanguageTag()).format(dateTime)}, $roughTimeString';
      //return '${DateFormat('yMd').format(dateTime)}, $roughTimeString';
    }

    return '';
  }
}
