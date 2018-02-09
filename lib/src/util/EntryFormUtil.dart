import 'package:myapp/src/model/FormEntry.dart';
import 'package:myapp/src/enumeration/FormParticipantCode.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/enumeration/Gender.dart';
import 'package:myapp/src/enumeration/DanceCategory.dart';
import 'package:myapp/src/model/User.dart';

class EntryFormUtil {
  static bool isFormApplicable(FormEntry form, participant, type) {
    bool retVal = false;

    form.participants.forEach((FormParticipant p){
      FormParticipantCode code = getParticipantCodeFromString(p.code);
      // filter based on types
      FormParticipantType participantType;
      if(type is String)
        participantType = getParticipantTypeFromString(type.toString().toUpperCase());
      else if(type is FormParticipantType)
        participantType = type;

      //print("CODE: ${code} TYPE: $participantType");
      switch(participantType) {
        case FormParticipantType.SOLO: // FOR SOLO PARTICIPANTS
          if(code == FormParticipantCode.SOLO_GIRL ||
              code == FormParticipantCode.SOLO_GUY || code == FormParticipantCode.AMATEUR) {
            Gender gender = participant.gender;
            DanceCategory category = participant.category;

            // filter based on category
            if(code == FormParticipantCode.AMATEUR) {
              if (category == DanceCategory.AMATEUR) {
                retVal = true;
              }
            }
            // filter based on gender
            else if (code == FormParticipantCode.SOLO_GIRL){
              if(gender == Gender.WOMAN) {
                retVal = true;
              }
            }
            else if (code == FormParticipantCode.SOLO_GUY){
              if(gender == Gender.MAN) {
                retVal = true;
              }
            }
          }
          break;
        case FormParticipantType.COUPLE:
          if(code == FormParticipantCode.AM_AM ||
              code == FormParticipantCode.PROAM_GIRL || code == FormParticipantCode.PROAM_GUY) {
            Couple couple = participant as Couple;
            User user1 = couple.couple[0];
            User user2 = couple.couple[1];

            // filter based on category
            if(code == FormParticipantCode.AM_AM) {
              if(user1.category == DanceCategory.AMATEUR && user2.category == DanceCategory.AMATEUR) {
                retVal = true;
              }
            }
            else if(code == FormParticipantCode.PROAM_GIRL) {
              User _woman = getUserBasedOnGender(couple, Gender.WOMAN);
              if(_woman != null && _woman.category == DanceCategory.AMATEUR) {
                if(user1 == _woman && user2.category == DanceCategory.PROFESSIONAL) {
                  retVal = true;
                }
                else if(user2 == _woman && user1.category == DanceCategory.PROFESSIONAL) {
                  retVal = true;
                }
              }
            }
            else if(code == FormParticipantCode.PROAM_GUY) {
              User _man = getUserBasedOnGender(couple, Gender.MAN);
              if(_man != null && _man.category == DanceCategory.AMATEUR) {
                if(user1 == _man && user2.category == DanceCategory.PROFESSIONAL) {
                  retVal = true;
                }
                else if(user2 == _man && user1.category == DanceCategory.PROFESSIONAL) {
                  retVal = true;
                }
              }
            }
          }
          break;
        case FormParticipantType.GROUP:
          if(code == FormParticipantCode.GROUP) {
            retVal = true;
          }
          break;
        default:
          break;
      }
    });

    //print("returned value: $retVal");
    return retVal;
  }

  static User getUserBasedOnGender(Couple c, Gender g) {
    User user1 = c.couple[0];
    User user2 = c.couple[1];
    if(user1.gender == g) {
      return user1;
    }
    else if(user2.gender == g) {
      return user2;
    }
    else {
      return null;
    }
  }
}