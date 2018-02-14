import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/EntryFormUtil.dart';
import 'package:myapp/src/screen/checkout_entry.dart' as checkout;
import 'package:myapp/src/screen/event_registration.dart' as reg;

var participantEntries;

class entry_summary extends StatefulWidget {
  @override
  _entry_summaryState createState() => new _entry_summaryState();
}

class _entry_summaryState extends State<entry_summary> {
  double _total = 0.0;
  /*Map<String, Map<String, double>> _entryForms = {
    'Showdance Solo': 100.0,
    'Future Celebrities Competition Kids': 20.0,
    'Group Dance Competition': 90.0,
    'Adult Showcase Single Dance': 25.0,
    'Amateur Competition': 25.0,
    'Adult Multi-Dance Competition': 100.0,
  };*/
  Map<String, Map<String, double>> _entryForms = {};

  @override
  void initState() {
    super.initState();

    _entryForms = {};
    if(reg.eventItem.formEntries != null) {
      var _formEntries = reg.eventItem.formEntries;
      _formEntries.forEach((_entry){
        Map<String, double> _priceMap = {};
        _entry.participants.forEach((_p){
          //print("${_entry.formName} ${_p.code} getPrice: ${_entry.getPriceFromList(_p.price).toJson()}");
          _priceMap.putIfAbsent(_p.code, () => _entry.getPriceFromList(_p.price));
        });
        //print("pricemap: $_priceMap");
        _entryForms.putIfAbsent(_entry.name, () => _priceMap);
      });
    }
    //print(_entryForms.length);
  }

  Widget generateContentItem(eventParticipant, Map entries){
    List<Widget> _children = [];
    entries.forEach((key, val){
      double _price = EntryFormUtil.getPriceFromForm(_entryForms[key], eventParticipant.user, eventParticipant.type);
      //print("price: $_price");
      _children.add(
          new Row(
            children: <Widget>[
              new Expanded(child: new Text(eventParticipant.name, style: new TextStyle(fontSize: 22.0))),
              new Text("Fee: \$${(_price).toStringAsFixed(2)}", style: new TextStyle(fontSize: 16.0))
            ],
          )
      );
      // add to total
      _total += _price;
      _children.add(new Text(key, style: new TextStyle(fontFamily: "Montserrat-Light")));
      _children.add(new Padding(padding: const EdgeInsets.only(bottom: 20.0)));
    });

    return new Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _total = 0.0;
    String _imgAsset = "mainframe_assets/images/add_via_email.png";
    List<Widget> _children = [];
    if(participantEntries != null){
      participantEntries.forEach((key, val){
        _children.add(generateContentItem(key, val));
      });
    }

    return new Scaffold(
      appBar: new MFAppBar("REGISTRATION SUMMARY", context),
      body: new ListView(
        children: _children
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
                child: new Text("Total Fees: \$${(_total).toStringAsFixed(2)}", style: new TextStyle(fontSize: 17.0)),
              ),
              new InkWell(
                onTap: (){
                  checkout.totalAmount = _total;
                  Navigator.of(context).pushNamed("/checkoutEntry");
                },
                child: new Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(image: new ExactAssetImage(_imgAsset)),
                  ),
                  width: 115.0,
                  height: 40.0,
                  child: new Center(child: new Text("Pay Fees", style: new TextStyle(fontSize: 17.0))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}