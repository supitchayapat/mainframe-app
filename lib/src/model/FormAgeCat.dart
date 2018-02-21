import 'package:quiver/core.dart';

class FormAgeCat {
  String age;
  bool catOpen;
  bool catClosed;

  FormAgeCat({this.age, this.catOpen : false, this.catClosed : false});

  bool operator ==(o) => o is FormAgeCat && o.age == age && o.catOpen == catOpen && o.catClosed == catClosed;
  int get hashCode => hash2(age.hashCode, catOpen.hashCode);

  toJson() {
    return {
      "age": age,
      "catOpen": catOpen,
      "catClosed": catClosed,
    };
  }
}