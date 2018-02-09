import 'package:myapp/src/model/FormEntry.dart';
import 'package:myapp/src/enumeration/FormParticipantCode.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/model/User.dart';

class EntryFormUtil {

  static double getPriceFromForm(priceMap, participant, type) {
    FormParticipantCode userCode = _getParticipantCodeOnUser(participant, type);
    var _price = priceMap[(userCode.toString().replaceAll("FormParticipantCode.", "")).replaceAll("_", "-")];
    return (_price.content).toDouble();
  }

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
    retVal = _participants.contains(userCode);
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
        if(participant.gender == Gender.MAN && participant.category == DanceCategory.AMATEUR) {
          retVal = FormParticipantCode.SOLO_GUY;
        }
        else if(participant.gender == Gender.WOMAN && participant.category == DanceCategory.AMATEUR) {
          retVal = FormParticipantCode.SOLO_GIRL;
        }
        else if(participant.gender == Gender.MAN && participant.category == DanceCategory.PROFESSIONAL) {
          retVal = FormParticipantCode.POLO_GUY;
        }
        else if(participant.gender == Gender.WOMAN && participant.category == DanceCategory.PROFESSIONAL) {
          retVal = FormParticipantCode.POLO_GIRL;
        }
        break;
      case FormParticipantType.COUPLE: // FOR COUPLE PARTICIPANTS
        Couple couple = participant as Couple;
        User c1 = couple.couple[0];
        User c2 = couple.couple[1];
        String user1 = _getUserParticipantCode(couple.couple[0]);
        String user2 = _getUserParticipantCode(couple.couple[1]);

        if(user1.contains("AMATEUR") && user2.contains("AMATEUR")) {
          if(c1.gender == Gender.WOMAN && c2.gender == Gender.WOMAN) {
            retVal = FormParticipantCode.AM_GIRL;
          }
          else if(c1.gender == Gender.MAN && c2.gender == Gender.MAN) {
            retVal = FormParticipantCode.AM_GUY;
          } else {
            retVal = FormParticipantCode.AM;
          }
        }
        else if(user1.contains("PROFESSIONAL") && user2.contains("PROFESSIONAL")) {
          if(c1.gender == Gender.WOMAN && c2.gender == Gender.WOMAN) {
            retVal = FormParticipantCode.PRO_GIRL;
          }
          else if(c1.gender == Gender.MAN && c2.gender == Gender.MAN) {
            retVal = FormParticipantCode.PRO_GUY;
          } else {
            retVal = FormParticipantCode.PRO;
          }
        }
        else if(user1.contains("AMATEUR")) {
          retVal = getParticipantCodeFromString("PRO"+user1.replaceAll("ATEUR", ""));
        }
        else if(user2.contains("AMATEUR")){
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