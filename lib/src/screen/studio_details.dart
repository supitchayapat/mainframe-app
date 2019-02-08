import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/util/ScreenUtils.dart';

TextEditingController studioCtrl;
TextEditingController addressCtrl;
TextEditingController phoneCtrl;
TextEditingController emailCtrl;

class studio_details extends StatefulWidget {
  @override
  _studio_detailsState createState() => new _studio_detailsState();
}

class _studio_detailsState extends State<studio_details> {
  var user;

  @override
  void initState() {
    super.initState();
    studioCtrl = new TextEditingController();
    addressCtrl = new TextEditingController();
    phoneCtrl = new TextEditingController();
    emailCtrl = new TextEditingController();

    // get current user
    getCurrentUserProfile().then((_user){
      user = _user;
      setState((){
        if(_user.invoiceAddress != null)
          addressCtrl.text = _user.invoiceAddress;
        if(_user.studioName != null)
          studioCtrl.text = _user.studioName;
        if(_user.studioPhoneNumber != null)
          phoneCtrl.text = _user.studioPhoneNumber;
        if(_user.studioEmail != null) {
          emailCtrl.text = _user.studioEmail;
        } else if(_user.studioEmail == null && _user.email != null) {
          emailCtrl.text = _user.email;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/add_via_email.png";

    Widget _cardContainer = new Column(
      children: <Widget>[
        new Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: new TextField(
            decoration: new InputDecoration(
              labelText: "Studio Name",
            ),
            style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
            keyboardType: TextInputType.text,
            controller: studioCtrl,
          ),
        ),
        new Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: new TextField(
            decoration: new InputDecoration(
              labelText: "Address",
            ),
            style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
            keyboardType: TextInputType.text,
            controller: addressCtrl,
          ),
        ),
        new Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: new TextField(
            decoration: new InputDecoration(
              labelText: "Phone Number",
            ),
            style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
            keyboardType: TextInputType.text,
            controller: phoneCtrl,
          ),
        ),
        new Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          child: new TextField(
            decoration: new InputDecoration(
              labelText: "Email",
            ),
            style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
            keyboardType: TextInputType.text,
            controller: emailCtrl,
          ),
        ),
      ],
    );

    return new Scaffold(
      appBar: new MFAppBar("STUDIO DETAILS", context),
      body: new ListView(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        children: <Widget>[
          _cardContainer
        ],
      ),
      bottomNavigationBar: new Container(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: new BoxDecoration(
          border: const Border(
            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
          ),
        ),
        child: new Container(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
          decoration: new BoxDecoration(
            border: const Border(
              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
            ),
          ),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                child: new Wrap(),
              ),
              new InkWell(
                onTap: (){
                  if(studioCtrl.text.isEmpty || addressCtrl.text.isEmpty || addressCtrl.text.isEmpty) {
                    showMainFrameDialog(context, "Missing Info", "Please Input Studio Name, Email and Address");
                  } else {
                    // save studio details
                    user.studioName = studioCtrl.text;
                    user.invoiceAddress = addressCtrl.text;
                    user.studioPhoneNumber = phoneCtrl.text;
                    user.studioEmail = phoneCtrl.text;
                    saveUser(user);
                    Navigator.of(context).pushNamed("/registrationSummary");
                  }
                },
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
                  ),
                  width: 115.0,
                  height: 40.0,
                  child: new Center(child: new Text("Next", style: new TextStyle(fontSize: 17.0))),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}