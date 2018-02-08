import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/util/CreditCardFormatter.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/dao/PaymentDao.dart';
import 'package:myapp/src/screen/event_details.dart' as event_details;
import 'package:myapp/src/screen/entry_summary.dart' as summary;

var totalAmount;

class checkout_entry extends StatefulWidget {
  @override
  _checkout_entryState createState() => new _checkout_entryState();
}

class _checkout_entryState extends State<checkout_entry> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _cardCtrl = new TextEditingController();
  TextEditingController _expDateCtrl = new TextEditingController();
  TextEditingController _cvvCtrl = new TextEditingController();
  TextEditingController _holderNameCtrl = new TextEditingController();
  bool saveToken = true;
  bool setDefault = true;

  void _handlePayment() {
    if(_cardCtrl.text.isEmpty || _expDateCtrl.text.isEmpty
      || _cvvCtrl.text.isEmpty || _holderNameCtrl.text.isEmpty) {
      showInSnackBar(_scaffoldKey, "Please Input Card Number, Exp. date, CVV and Holder's Name");
    } else {
      PaymentDao.createToken(
          _cardCtrl.text,
          _expDateCtrl.text,
          _cvvCtrl.text,
          _holderNameCtrl.text,
          setDefault,
          saveToken, (tokenId) {
            print("The token: $tokenId");
          }
      );
      //MainFrameLoadingIndicator.showLoading(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/button_mds.png";
    var _totalEntries = 0;
    summary.participantEntries.forEach((key, val){
      _totalEntries += val.length;
    });

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new MFAppBar("PAYMENT", context),
      body: new ListView(
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(event_details.eventItem.eventTitle, style: new TextStyle(fontSize: 22.0, color: new Color(0xff00e5ff))),
                  new Padding(padding: const EdgeInsets.only(top: 10.0)),
                  new Row(
                    children: <Widget>[
                      new Expanded(child: new Text("Total Entries", style: new TextStyle(fontSize: 20.0))),
                      new Text("${_totalEntries}", style: new TextStyle(fontSize: 20.0))
                    ],
                  ),
                  new Padding(padding: const EdgeInsets.only(top: 10.0)),
                  new Row(
                    children: <Widget>[
                      new Expanded(child: new Text("Total Amount", style: new TextStyle(fontSize: 20.0))),
                      new Text("\$${(totalAmount).toStringAsFixed(2)}", style: new TextStyle(fontSize: 20.0))
                    ],
                  ),
                ],
              )
          ),
          new Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: new TextField(
              decoration: new InputDecoration(
                labelText: "Card Number",
                //labelStyle: new TextStyle(color: Colors.black),
                //hideDivider: true,
                //hintText: "Card Number",
                //hintStyle: new TextStyle(color: Colors.black),
              ),
              inputFormatters: <TextInputFormatter>[
                new LengthLimitingTextInputFormatter(23),
                new CreditCardTextInputFormatter(),
              ],
              style: new TextStyle(fontSize: 22.0, fontFamily: "Montserrat-Regular"),
              keyboardType: TextInputType.number,
              controller: _cardCtrl,
            ),
          ),
          new Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      decoration: new InputDecoration(
                          labelText: "Exp. Date",
                          hintText: "00/00"
                      ),
                      style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
                      inputFormatters: <TextInputFormatter>[
                        new ExpDateTextInputFormatter(),
                        new LengthLimitingTextInputFormatter(6),
                      ],
                      keyboardType: TextInputType.number,
                      controller: _expDateCtrl,
                    ),
                  ),
                  new Padding(padding: const EdgeInsets.only(left: 10.0)),
                  new Expanded(
                    child: new TextField(
                      decoration: new InputDecoration(
                        labelText: "CVV",
                      ),
                      inputFormatters: <TextInputFormatter>[
                        new LengthLimitingTextInputFormatter(3),
                      ],
                      style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
                      keyboardType: TextInputType.number,
                      controller: _cvvCtrl,
                    ),
                  )
                ],
              )
          ),
          new Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: new TextField(
              decoration: new InputDecoration(
                labelText: "Card Holder Name",
              ),
              style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
              keyboardType: TextInputType.text,
              controller: _holderNameCtrl,
            ),
          ),
          new Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: new Row(
                children: <Widget>[
                  new Checkbox(activeColor: const Color(0xFF324261),value: saveToken,
                      onChanged: (bool val){
                        setState((){saveToken=val;});
                      }),
                  new Text("Save this card", style: new TextStyle(fontSize: 16.0, fontFamily: "Montserrat-Light"))
                ],
              )
          ),
          new Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: new Row(
                children: <Widget>[
                  new Checkbox(activeColor: const Color(0xFF324261),value: setDefault,
                      onChanged: (bool val){
                        setState((){setDefault=val;});
                      }),
                  new Text("Set default", style: new TextStyle(fontSize: 16.0, fontFamily: "Montserrat-Light"))
                ],
              )
          ),
          new Row(
            children: <Widget>[
              new Expanded(
                  child: new Container(
                    margin: const EdgeInsets.only(bottom: 15.0),
                    child: new InkWell(
                      onTap: (){
                        _handlePayment();
                      },
                      child: new Container(
                        decoration: new BoxDecoration(
                          image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
                        ),
                        height: 56.0,
                        child: new Center(child: new Text("PAY ENTRIES", style: new TextStyle(fontSize: 18.0, fontFamily: "Montserrat-Light"))),
                      ),
                    ),
                  )
              )
            ],
          )
        ],
      ),
    );
  }
}