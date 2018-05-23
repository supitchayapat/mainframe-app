import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreditCardTextInputFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // TODO: implement formatEditUpdate
    int threshold = 5;
    int current = 1;
    String s = newValue.text;
    s = s.replaceAll(" ", "");
    String retVal = "";
    for(int i=0; i<s.length; i++) {
      var char = s[i];
      if(current == threshold) {
        retVal += " ${char}";
        current = 1;
      } else {
        retVal += char;
      }
      current++;
    }
    //print(retVal);

    final TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: retVal.length,
      extentOffset: retVal.length,
    );

    return new TextEditingValue(
      text: retVal,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}

class ExpDateTextInputFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // TODO: implement formatEditUpdate
    // 00/00
    String s = newValue.text;
    int _offset = newValue.text.runes.length;
    String retVal = "";
    int month = 0;
    int year = 0;
    List<String> expDate = s.contains("/") ? s.split("/") : [];

    if(expDate.length > 0) {
      String mm = expDate[0], yy = expDate[1];
      month = int.parse(mm);
      year = !yy.isEmpty ? int.parse(yy) : 0;

      if(month > 0 && year <= 0) {
        _offset = 2;
        if(month > 12) {
          var _pre = mm;
          mm = _pre.substring(0, 2);
          month = int.parse(mm);
          yy = _pre.substring(2, 3);
          year = int.parse(yy);
          _offset = 4;
        }
      } else {
        if(year > 100) {
          year = (year / 10).floor();
        }
      }

      if(month > 100) {
        // return retVal as usual from old value
        retVal = oldValue.text;
      } else {
        retVal += month.toString().padLeft(2, "0");
        retVal += "/";
        retVal += year != 0 ? year.toString() : year.toString().padRight(2, "0");
      }
    } else if(s.length > 0 && s != "00/00") {
      month = int.parse(s);
      retVal += month.toString().padLeft(2, "0");
      retVal += "/00";
    }

    if(retVal == "00/00" || (month == 0 && year ==0)) {
      retVal = "";
    }

    final TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: _offset,
      extentOffset: _offset,
    );

    return new TextEditingValue(
      text: retVal,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}