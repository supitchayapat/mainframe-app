import 'package:myapp/src/model/FormEntry.dart';
import 'package:myapp/src/enumeration/FormParticipantCode.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/model/User.dart';

class EntryFormUtil {
  static bool isFormApplicable(FormEntry form, participant, type) {
    bool retVal = false;
    FormParticipantCode userCode = _getParticipantCodeOnUser(participant, type);
    //print("USER: ${userCode}");
    List<FormParticipantCode> _participants = [];

    form.participants.forEach((val) {
      //print(getParticipantCodeFromString(val.code));
      _participants.add(getParticipantCodeFromString(val.code));
    });
    //print(_participants.contains(_getParticipantCodeOnUser(participant, type)));
    if(userCode != FormParticipantCode.AM_AM) {
      retVal = _participants.contains(userCode);
    }
    else {
      retVal = (_participants.contains(FormParticipantCode.AM_AM) || _participants.contains(FormParticipantCode.AMATEUR));
    }
    //print("returned value: $retVal");
    return retVal;
  }

  static FormParticipantCode _getParticipantCodeOnUser(participant, type) {
    FormParticipantCode retVal;
    FormParticipantType participantType;
    if(type is String)
      participantType = getParticipantTypeFromString(type.toString().toUpperCase());
    else if(type is FormParticipantType)
      participantType = type;

    switch(participantType) {
      case FormParticipantType.SOLO: // FOR SOLO PARTICIPANTS
        if(participant.gender == Gender.MAN) {
          retVal = FormParticipantCode.SOLO_GUY;
        }
        else {
          retVal = FormParticipantCode.SOLO_GIRL;
        }
        break;
      case FormParticipantType.COUPLE: // FOR COUPLE PARTICIPANTS
        Couple couple = participant as Couple;
        String user1 = _getUserParticipantCode(couple.couple[0]);
        String user2 = _getUserParticipantCode(couple.couple[1]);

        if(user1.contains("AMATEUR") && user2.contains("AMATEUR")) {
          retVal = FormParticipantCode.AM_AM;
        }
        else if(user1.contains("AMATEUR")) {
          retVal = getParticipantCodeFromString("PRO"+user1.replaceAll("ATEUR", ""));
        }
        else {
          retVal = getParticipantCodeFromString("PRO"+user2.replaceAll("ATEUR", ""));
        }
        break;
      case FormParticipantType.GROUP: // FOR GROUP PARTICIPANTS
        retVal = FormParticipantCode.GROUP;
        break;
      default:
        break;
    }

    return retVal;
  }

  static String _getUserParticipantCode(User u) {
    String retVal = u.category.toString().replaceAll("DanceCategory.", "");
    if(u.gender == Gender.WOMAN) {
      retVal += "_GIRL";
    }
    else {
      retVal += "_GUY";
    }
    return retVal;
  }
}