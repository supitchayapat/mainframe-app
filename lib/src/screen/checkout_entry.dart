import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/util/CreditCardFormatter.dart';
import 'package:myapp/src/util/LoadingIndicator.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/dao/PaymentDao.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'package:myapp/src/dao/UserDao.dart';
import 'package:myapp/src/dao/TicketDao.dart';
import 'package:myapp/src/screen/event_details.dart' as event_details;
import 'package:myapp/src/screen/entry_summary.dart' as summary;
import 'package:stripe_plugin/stripe_plugin.dart';
import 'package:myapp/src/model/InvoiceInfo.dart';
import 'package:myapp/src/model/User.dart';
import 'package:myapp/src/util/EntryFormUtil.dart';
import 'package:myapp/src/enumeration/FormParticipantType.dart';
import 'package:myapp/src/enumeration/FormType.dart';

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
  TextEditingController _studioCtrl = new TextEditingController();
  TextEditingController _addressCtrl = new TextEditingController();
  double financeCharge = 0.0;
  String financeText = "";
  String defaultCardholder = "";
  bool saveToken = true;
  bool setDefault = true;
  User user;
  var listener;
  var token;

  @override
  void initState() {
    super.initState();

    /*Timer periodic = new Timer.periodic(new Duration(seconds: 5), (timer){
      print(timer);
    });*/

    // get finance charge
    if(event_details.eventItem?.finance != null) {
      financeText = event_details.eventItem.finance.description;
      financeCharge = event_details.eventItem?.finance.surcharge / 100;
    }

    // get current user
    getCurrentUserProfile().then((_user){
      user = _user;
      defaultCardholder = _user.first_name + " " + _user.last_name;
      setState((){
        if(defaultCardholder != null && defaultCardholder.isNotEmpty)
          _holderNameCtrl.text = defaultCardholder;
        if(_user.invoiceAddress != null)
          _addressCtrl.text = _user.invoiceAddress;
        if(_user.studioName != null)
          _studioCtrl.text = _user.studioName;
      });
    });

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

    PaymentDao.stripePaymentListener((data, pushId){
      print("PAYMENT DONE");
      
      // check if error
      if(!(data is StripeCard)) {
        print(data["message"]);
        if (MainFrameLoadingIndicator.isOpened) {
          MainFrameLoadingIndicator.hideLoading(context);
        }
        showMainFrameDialog(context, "Transaction Failed", "Unable to process payment. Please contact application support.");
      }
      else {
        double _sumAmount = (totalAmount.toDouble() * financeCharge) + totalAmount.toDouble();
        Surcharge surcharge = new Surcharge.fromFinance(event_details.eventItem.finance);
        surcharge.amount = (totalAmount.toDouble() * financeCharge);
        // create new invoice info
        InvoiceInfo info = new InvoiceInfo(
          event: event_details.eventItem,
          totalAmount: _sumAmount,
          surcharge: surcharge,
        );
        info.entries = [];
        info.tickets = [];
        info.billingInfo = new BillingInfo(name: _studioCtrl.text, address: _addressCtrl.text);
        // save user details with info
        user.studioName = _studioCtrl.text;
        user.invoiceAddress = _addressCtrl.text;
        saveUser(user);

        // update event entry
        summary.eventEntries?.forEach((key, val) {
          //print(key);
          //print(val.toJson());
          if (val?.payment == null) {
            bool isInvoice = val.paidEntries != val?.danceEntries;
            print("${val.paidEntries} != ${val.danceEntries}");
            // pay this entry
            val.paidEntries = val?.danceEntries;
            val.payment = data;
            // new Invoice Participants
            InvoiceParticipants invParticipants = new InvoiceParticipants(formName: val?.formEntry?.name);
            invParticipants.participants = [];
            invParticipants.participantEntries = [];
            FormParticipantType fType;
            if(val?.participant != null) {
              if(val.participant is Couple) {
                invParticipants.participants.addAll(val.participant.couple);
                fType = FormParticipantType.COUPLE;
              } else if(val.participant is Group) {
                invParticipants.participants.addAll(val.participant.members);
                fType = FormParticipantType.GROUP;
              } else if(val.participant is User){
                invParticipants.participants.add(val.participant);
                fType = FormParticipantType.SOLO;
              }

            }

            double _price = EntryFormUtil.getPriceFromForm(summary.entryForms[val?.formEntry?.name], val.participant, fType);
            if (val?.levels != null) {
              for (var _lvl in val.levels) {
                for (var _ageMap in _lvl.ageMap) {
                  _ageMap.subCategoryMap.forEach((_k, _v) {
                    if (_v["selected"]) {
                      //print("key: $_k paid: ${_v["paid"]}");
                      if(!_v["paid"]) {
                        String _content = EntryFormUtil.getLookupDescription(val.formEntry, _k, "DANCES");
                        ParticipantEntry _pEntry = new ParticipantEntry(name: "${_ageMap.ageCategory} ${_lvl.levelName.toUpperCase()} $_content", price: _price);
                        //print(_pEntry.toJson());
                        invParticipants.participantEntries.add(_pEntry);
                      }

                      _v["paid"] = true;
                    }
                  });
                }
              }
            }
            else if(val?.freeForm != null) {
              // free form GROUP
              if(val.formEntry.type == FormType.GROUP || val.formEntry.type == FormType.SOLO) {
                String _entryName = "";
                if(val.formEntry.type == FormType.GROUP)
                  _entryName = "${val.freeForm["age"]} ${val.freeForm["dance"]} ${val.freeForm["event_type"]}";
                if(val.formEntry.type == FormType.SOLO)
                  _entryName = val.freeForm.dance;

                ParticipantEntry _pEntry = new ParticipantEntry(
                    name: _entryName, price: _price);
                invParticipants.participantEntries.add(_pEntry);
              }
            }

            if(isInvoice) {
              //print("INV PARTICIPANTS");
              //print(invParticipants.toJson());
              info.entries.add(invParticipants);
            }
            EventEntryDao.updateEventEntry(key, val);
          }
        });

        // save tickets
        summary.participantTickets.forEach((_participant, _ticketMap) {
          //_saveTickets(pushId, info, _participant, _ticketMap);
          info.tickets.add(_ticketMap);
          TicketDao.saveTicket(_participant, _ticketMap, event_details.eventItem, isPaid: true);
        });

        //print("SOURCE: ${data["charge"]["source"]}");
        //print("INVOICE INFO");
        //print(info.toJson());
        PaymentDao.savePaymentInvoiceInfo(pushId, info);


        if (MainFrameLoadingIndicator.isOpened) {
          MainFrameLoadingIndicator.hideLoading(context);
        }

        Navigator.of(context).pushNamed("/paymentSuccess");
      }
    }).then((val){ listener = val; });
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void _handlePayment() {
    if(_studioCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      showMainFrameDialog(context, "Missing Info", "Please Input Studio Name and Address");
    } else {
      if (token == null && (_cardCtrl.text.isEmpty || _expDateCtrl.text.isEmpty
          || _cvvCtrl.text.isEmpty || _holderNameCtrl.text.isEmpty)) {
        showMainFrameDialog(context, "Missing Card Info", "Please Input Card Number, Exp. date, CVV and Holder's Name");
      } else {
        MainFrameLoadingIndicator.showLoading(context);
        if (token == null) {
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
            double _sumAmount = (totalAmount.toDouble() * financeCharge) +
                totalAmount.toDouble();
            double _total = (_sumAmount * 100);
            if (_total <= 50.0)
              _total = 50.00;
            PaymentDao.submitPayment(tokenId.tokenId, _total.round());
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
  }

  @override
  Widget build(BuildContext context) {
    String _imgAsset = "mainframe_assets/images/button_mds.png";
    var _totalEntries = 0;
    summary.participantEntries.forEach((key1, val){
      if(val.length > 0) {
        val.forEach((key2, _entCount){
          //print("$key1 PREV: ${_entCount}");
          for(var _entry in summary.eventEntries.values) {
            if(_entry?.formEntry?.name == key2 && key1?.user == _entry?.participant) {
              if(_entry?.paidEntries != null && _entry?.paidEntries > 0) {
                _entCount -= _entry.paidEntries;
              }
            }
          }
          //print("ENTCOUNT: ${_entCount}");
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
              labelText: "Studio Name",
            ),
            style: new TextStyle(fontSize: 20.0, fontFamily: "Montserrat-Regular"),
            keyboardType: TextInputType.text,
            controller: _studioCtrl,
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
            controller: _addressCtrl,
          ),
        ),
        new Container(
          //color: Colors.blueAccent,
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
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0, top: 10.0),
            child: new Wrap(
              children: <Widget>[
                new Text("We dont save your credit card details for your own security", style: new TextStyle(fontSize: 14.0, fontFamily: "Montserrat-Light", fontStyle: FontStyle.italic))
              ],
            )
        ),
        /*new Container(
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
        ),*/
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
              //color: Colors.amber,
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
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
                      new Expanded(child: new Text("$financeText", style: new TextStyle(fontSize: 20.0))),
                      new Text("\$${(totalAmount * financeCharge).toStringAsFixed(2)}", style: new TextStyle(fontSize: 20.0))
                    ],
                  ),
                  new Padding(padding: const EdgeInsets.only(top: 10.0)),
                  new Row(
                    children: <Widget>[
                      new Expanded(child: new Text("Total Amount", style: new TextStyle(fontSize: 20.0))),
                      new Text("\$${(totalAmount * financeCharge + totalAmount).toStringAsFixed(2)}", style: new TextStyle(fontSize: 20.0))
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