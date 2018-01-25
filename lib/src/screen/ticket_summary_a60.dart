import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'main_drawer.dart';
import 'package:myapp/src/util/ScreenUtils.dart';

class ticket_summary_a60 extends StatefulWidget {
  @override
  _ticket_summary_a60State createState() => new _ticket_summary_a60State();
}

class _ticket_summary_a60State extends State<ticket_summary_a60> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _dropValue = "SUMMARY";

  void _handleView() {
    if(_dropValue == "SUMMARY") {
      showSummaryDialog(context);
    }
    else {
      showTicketDialog(context, _dropValue);
    }
  }

  Widget _generateCard(String _txtContent, {Color legend}) {
    Widget _expanded;
    _expanded = new Container(
      decoration: new BoxDecoration(
          border: const Border(
              top: const BorderSide(width: 1.0, color: Colors.grey),
              right: const BorderSide(width: 1.0, color: Colors.grey)
          )
      ),
      //color: const Color(0xffffffff),
      child: new Container(
        color: const Color(0xffffffff),
        height: 70.0,
        width: 75.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Center(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          border: new Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          )
                      ),
                      width: 45.0,
                      height: 45.0,
                      child: new MaterialButton(
                        padding: new EdgeInsets.all(0.0),
                        minWidth: 5.0, height: 5.0,
                        color: const Color(0xffffffff),
                        onPressed: () {},
                        child: new Text(_txtContent,
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legend == null) ? Colors.white : legend)
          ],
        ),
      ),
    );

    return _expanded;
  }

  Widget _generateExpandedCard(String _txtContent, {Color legend}) {
    Widget _expanded;
    _expanded = new Container(
      decoration: new BoxDecoration(
          border: const Border(
              top: const BorderSide(width: 1.0, color: Colors.grey)
          )
      ),
      //color: const Color(0xffffffff),
      child: new Container(
        color: const Color(0xffffffff),
        height: 70.0,
        width: 150.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Center(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          border: new Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          )
                      ),
                      width: 45.0,
                      height: 45.0,
                      child: new MaterialButton(
                        padding: new EdgeInsets.all(0.0),
                        minWidth: 5.0, height: 5.0,
                        color: const Color(0xffffffff),
                        onPressed: () {},
                        child: new Text(_txtContent,
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legend == null) ? Colors.white : legend)
          ],
        ),
      ),
    );

    return _expanded;
  }

  List<Widget> _generateTwoCards(List<String> _numbers, {List<Color> legends}) {
    List<Widget> _cards = [];

    _cards.add(new Container(
      decoration: new BoxDecoration(
          border: const Border(
              right: const BorderSide(width: 1.0, color: Colors.grey)
          )
      ),
      //color: const Color(0xffffffff),
      child: new Container(
        color: const Color(0xffffffff),
        height: 70.0,
        width: 75.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Expanded(
                child: new Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Center(
                    child: new Container(
                      decoration: new BoxDecoration(
                          borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                          border: new Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                          )
                      ),
                      width: 45.0,
                      height: 45.0,
                      child: new MaterialButton(
                        padding: new EdgeInsets.all(0.0),
                        minWidth: 5.0, height: 5.0,
                        color: const Color(0xffffffff),
                        onPressed: () {},
                        child: new Text(_numbers[0],
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ),
            new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legends.isEmpty) ? Colors.white : legends[0])
          ],
        ),
      ),
    ));

    // 2nd card
    _cards.add(new Container(
      color: const Color(0xffffffff),
      height: 70.0,
      width: 75.0,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Expanded(
              child: new Container(
                //color: Colors.amber,
                padding: const EdgeInsets.only(top: 15.0),
                child: new Center(
                  child: new Container(
                    decoration: new BoxDecoration(
                      borderRadius: const BorderRadius.all(const Radius.circular(4.0)),
                      border: new Border.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                      )
                    ),
                    width: 45.0,
                    height: 45.0,
                    child: new MaterialButton(
                      padding: new EdgeInsets.all(0.0),
                      minWidth: 5.0, height: 5.0,
                      color: const Color(0xffffffff),
                      onPressed: () {},
                      child: new Text(_numbers[1],
                        style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ),
              )
          ),
          new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: (legends.isEmpty) ? Colors.white : legends[1])
        ],
      ),
    ));

    return _cards;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Tickets - SUMMARY",
          style: new TextStyle(
              fontFamily: "Montserrat-Light",
              fontSize: 17.0,
              fontWeight: FontWeight.w100
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          new PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                  value: "",
                  child: const Text('Buy ticket(s)')
              ),
              const PopupMenuItem<String>(
                  value: "",
                  child: const Text('Clear')
              ),
            ],
          )
        ],
      ),
      body: new DropdownButtonHideUnderline(
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                decoration: new BoxDecoration(
                  border: const Border(
                      top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                      //bottom: const BorderSide(width: 1.0, color: Colors.black)
                  ),
                ),
                child: new Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                  decoration: new BoxDecoration(
                    border: const Border(
                        top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                        //bottom: const BorderSide(width: 1.0, color: Colors.white)
                    ),
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Container(
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: const BorderSide(color: const Color(0xFFD5D4D9))
                                )
                            ),
                            width: 100.0,
                            height: 48.0,
                            child: new MaterialButton(
                              padding: new EdgeInsets.all(0.0),
                              minWidth: 5.0, height: 5.0,
                              color: const Color(0xFFF4EEF6),
                              onPressed: _handleView,
                              child: new Text("VIEW",
                                style: new TextStyle(
                                    fontSize: 18.0,
                                    color: const Color(0xFF287399)
                                ),
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Theme(
                                  data: new ThemeData(
                                      brightness: Brightness.light
                                  ),
                                  child: new Container(
                                      padding: const EdgeInsets.only(left: 20.0),
                                      color: Colors.white,
                                      child: new DropdownButton(
                                          iconSize: 30.0,
                                          value: _dropValue,
                                          items: <String>['SUMMARY', 'John Doe', 'Jane Smith', 'Georgette Sumpter'].map((String value) {
                                            return new DropdownMenuItem<String>(
                                                value: value,
                                                child: new Text(value));
                                          }).toList(),
                                          onChanged: (val){
                                            setState(() {
                                              if (val != null)
                                                _dropValue = val;
                                            });
                                          }
                                      )
                                  )
                              )
                          )
                        ],
                      ),
                      new Padding(padding: const EdgeInsets.only(top: 20.0)),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Container(
                            child: new Text("DAY"),
                          ),
                          new Padding(
                              padding: const EdgeInsets.only(right: 45.0)
                          ),
                          new Container(
                            child: new Text("EVE"),
                          ),
                          new Padding(
                              padding: const EdgeInsets.only(right: 35.0)
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              new Flexible(
                  child: new ListView(
                    children: <Widget>[
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                              top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("TUESDAY", style: const TextStyle(fontSize: 18.0)),
                                  new Text("July 18, 2017", style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                                ],
                              ),
                              new Expanded(
                                  child: new Container(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    //color: Colors.amber,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: _generateTwoCards(["0", "0"], legends: [Colors.white, const Color(0xFF4AD778)]),
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                            //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("WEDNESDAY", style: const TextStyle(fontSize: 18.0)),
                                  new Text("July 19, 2017", style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                                ],
                              ),
                              new Expanded(
                                  child: new Container(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    //color: Colors.amber,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: _generateTwoCards(["0", "0"], legends: [Colors.white, const Color(0xFFFD7333)]),
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                            //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("THURSDAY", style: const TextStyle(fontSize: 18.0)),
                                  new Text("July 20, 2017", style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                                ],
                              ),
                              new Expanded(
                                  child: new Container(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    //color: Colors.amber,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[_generateExpandedCard("0")],
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                            //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("FRIDAY", style: const TextStyle(fontSize: 18.0)),
                                  new Text("July 21, 2017", style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                                ],
                              ),
                              new Expanded(
                                  child: new Container(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    //color: Colors.amber,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: _generateTwoCards(["24", "0"], legends: [Colors.white, const Color(0xFF4AD778)]),
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      // Saturday
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                            //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("SATURDAY", style: const TextStyle(fontSize: 18.0)),
                                  new Text("July 22, 2017", style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                                ],
                              ),
                              new Expanded(
                                  child: new Container(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      //color: Colors.amber,
                                      child: new Column(
                                        children: <Widget>[
                                          // 1st row
                                          new Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: _generateTwoCards(["0", "0"], legends: [Colors.white, const Color(0xFF4AD778)]),
                                          ),
                                          // 2nd row
                                          new Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[_generateExpandedCard("0", legend: const Color(0xFF4AD778))],
                                          ),
                                          // 3rd row
                                          new Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[_generateCard("0", legend: const Color(0xFFFD7333))],
                                          ),
                                        ],
                                      )
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      // Sunday
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                            //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("SUNDAY", style: const TextStyle(fontSize: 18.0)),
                                  new Text("July 23, 2017", style: const TextStyle(fontSize: 14.0, color: const Color(0xFF6482BF)))
                                ],
                              ),
                              new Expanded(
                                  child: new Container(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    //color: Colors.amber,
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[_generateExpandedCard("0")],
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                      // Legend
                      new Container(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        decoration: new BoxDecoration(
                          border: const Border(
                            top: const BorderSide(width: 2.0, color: const Color(0xFF212D44)),
                            //bottom: const BorderSide(width: 1.0, color: Colors.white)
                          ),
                        ),
                        child: new Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
                          decoration: new BoxDecoration(
                            border: const Border(
                              top: const BorderSide(width: 1.0, color: const Color(0xFF53617C)),
                              //bottom: const BorderSide(width: 1.0, color: Colors.white)
                            ),
                          ),
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text("LEGEND", style: const TextStyle(fontSize: 18.0, color: const Color(0xFF6482BF))),
                              new Padding(padding: const EdgeInsets.only(right: 10.0)),
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: const Color(0xFF4AD778)),
                                      new Padding(padding: const EdgeInsets.only(right: 5.0)),
                                      new Text("Dinner Included"),
                                    ],
                                  ),
                                  new Padding(padding: const EdgeInsets.only(top: 10.0)),
                                  new Row(
                                    children: <Widget>[
                                      new Icon(Icons.signal_cellular_4_bar, size: 18.0, color: const Color(0xFFFD7333)),
                                      new Padding(padding: const EdgeInsets.only(right: 5.0)),
                                      new Text("No Dinner Included"),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              )
            ],
          )
      ),
      drawer: new MainFrameDrawer(_scaffoldKey),
    );
  }
}