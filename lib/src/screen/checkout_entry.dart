import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/util/CreditCardFormatter.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/dao/PaymentDao.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'package:myapp/src/dao/TicketDao.dart';
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
  var listener;
  var token;

  @override
  void initState() {
    super.initState();

    // save tickets
    summary.participantTickets.forEach((_participant, _ticketMap){
      TicketDao.saveTicket(_participant, _ticketMap, event_details.eventItem);
    });

    /*PaymentDao.getExistingCard().then((cardData){
      print("token: "+cardData["token"]);
      setState((){
        //token = cardData;
      });
    });*/

    PaymentDao.stripePaymentListener((data){
      print("PAYMENT DONE");

      summary.eventEntries?.forEach((key, val){
        //print(key);
        print(val.toJson());
        if(val?.payment == null) {
          // pay this entry
          val.payment = data;
          val.paidEntries = val?.danceEntries;
          if(val?.levels != null) {
            for(var _lvl in val.levels) {
              for(var _ageMap in _lvl.ageMap) {
                _ageMap.subCategoryMap.forEach((_k, _v){
                  if(_v["selected"]) {
                    _v["paid"] = true;
                  }
                });
              }
            }
          }
          EventEntryDao.updateEventEntry(key, val);
        }
      });

      // save tickets
      summary.participantTickets.forEach((_participant, _ticketMap){
        TicketDao.saveTicket(_participant, _ticketMap, event_details.eventItem,isPaid: true);
      });

      //print("SOURCE: ${data["charge"]["source"]}");


      if(MainFrameLoadingIndicator.isOpened) {
        MainFrameLoadingIndicator.hideLoading(context);
      }

      Navigator.of(context).pushNamed("/paymentSuccess");
    }).then((val){ listener = val; });
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void _handlePayment() {
    if(token == null && (_cardCtrl.text.isEmpty || _expDateCtrl.text.isEmpty
      || _cvvCtrl.text.isEmpty || _holderNameCtrl.text.isEmpty)) {
      showInSnackBar(_scaffoldKey, "Please Input Card Number, Exp. date, CVV and Holder's Name");
    } else {
      MainFrameLoadingIndicator.showLoading(context);
      if(token == null) {
        PaymentDao.createToken(
            _cardCtrl.text,
            _expDateCtrl.text,
            _cvvCtrl.text,
            _holderNameCtrl.text,
            setDefault,
            saveToken, (tokenId) {
          print("The token: ${tokenId?.toJson()}");
          // amount must be converted to dollar since it is in cents
          // lowest amount would be 50 and is equivalent to $0.50
          // https://stripe.com/docs/currencies#minimum-and-maximum-charge-amounts
          // total amount * 100
          double _total = (totalAmount.toDouble() * 100);
          if(_total <= 50.0)
            _total = 50.00;
          PaymentDao.submitPayment(tokenId.tokenId, _total);
        }
        ).catchError((err) {
          print('PAYMENT ERROR.... $err');
          MainFrameLoadingIndicator.hideLoading(context);
          showMainFrameDialog(context, "Payment Error", "${err.message}");
        });
      }
      else {
        PaymentDao.submitPayment(token["token"], totalAmount.toDouble());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/button_mds.png";
    var _totalEntries = 0;
    summary.participantEntries.forEach((key1, val){
      if(val.length > 0) {
        val.forEach((key2, _entCount){
          for(var _entry in summary.eventEntries.values) {
            if(_entry?.formEntry?.name == key2) {
              if(_entry?.paidEntries != null) {
                _entCount -= _entry.paidEntries;
              }
            }
          }
          _totalEntries += _entCount;
        });
      }
    });

    Widget _cardContainer = new Column(
      children: <Widget>[
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
      ],
    );

    if(token != null) {
      _cardContainer = new Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        margin: const EdgeInsets.only(bottom: 20.0),
        child: new Text("${token["brand"]} x-${token["last_digits"]}", style: new TextStyle(fontSize: 20.0)),
      );
    }

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
          _cardContainer,
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