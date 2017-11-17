import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/CompetitionForm.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/util/ScreenUtils.dart';

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => new _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  String categoryVal = "";

  void _handleCategoryChanged(String val) {
    setState((){
      categoryVal = val;
      //rightPanel = _buildRightPanel();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> levels = <String>[
      "Newcommer", "Pre-Bronze", "Int. Bronze",
      "Full Bronze", "Pre Silver", "Int. Silver",
      "Full Silver", "Pre Gold", "Int. Gold",
      "Full Gold", "Open Gold"
    ];
    
    List<Widget> _children = <Widget>[];
    List<Widget> _childrenAdd = <Widget>[];
    _children.add(new Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
            image: new ExactAssetImage("mainframe_assets/images/level_row_divider.png"),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter
        )
      ),
      alignment: Alignment.center,
      height: 50.0,
      child: new Text(
          "LEVEL",
          style: new TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
          )
      ),
    ));
    _childrenAdd.add(new Container(
      alignment: Alignment.center,
      height: 50.0,
      child: new Text(
          "AGE",
          style: new TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
          )
      ),
    ));

    for(String level in levels) {
      _children.add(new Container(
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new ExactAssetImage("mainframe_assets/images/level_row_divider.png"),
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter
            )
        ),
        padding: const EdgeInsets.all(5.0),
        height: 42.0,
        child: new Text(
          level,
            style: new TextStyle(
                fontSize: 18.0,
                fontFamily: "Montserrat-Light"
            )
        ),
      ));

      _childrenAdd.add(new Container(
        alignment: Alignment.center,
        //color: Colors.amber,
        height: 42.0,
        padding: const EdgeInsets.all(5.0),
        child: new MainFrameButton(
          imgAsset: "mainframe_assets/images/add_button.png",
          imgHeight: 32.0,
          fontSize: 16.0,
          onPressed: (){
            List<String> _selButtons = <String>[];
            showAgeCategoryDialog(context, _selButtons, () {
              //print("COMPLETED");
              //print(_selButtons);
            });
          },
          child: new Text("ADD", style: new TextStyle(color: const Color(0xff4e6686))),
        ),
      ));
    }

    return new Scaffold(
      appBar: new MFAppBar("ENTRY FORM", context),
      body: new CompetitionForm(
          maximizedLeftPanel: new Container(
            child: new ListView(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Container(
                          decoration: new BoxDecoration(
                              gradient: new LinearGradient(
                                begin: const Alignment(0.0, -1.0),
                                end: const Alignment(0.0, 2.0),
                                colors: <Color>[
                                  const Color(0xff1A7FA7),
                                  const Color(0x003E5A9B)
                                ],
                              )
                          ),
                          child: new Column(
                            children: _children,
                          ),
                        )
                    ),
                    new SizedBox(
                      width: 140.0,
                      child: new Container(
                        decoration: new BoxDecoration(
                            gradient: new LinearGradient(
                              begin: const Alignment(2.0, -1.0),
                              end: const Alignment(0.0, 2.0),
                              colors: <Color>[
                                const Color(0xff1468A7),
                                const Color(0x00463D91)
                              ],
                            )
                        ),
                        child: new Column(
                          children: _childrenAdd,
                        ),
                      ),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                )
              ],
            ),
          ), 
          minimizedLeftPanel: new Container(
            child: new Text("Minimized Left"),
          ),
          rightPanelTabs: <Widget>[
            new Container(
                color: new Color(0xff113E69),
                child: new ListView(
                  children: <Widget>[
                    new Center( child: new Text("SMOOTH")),
                    new Padding(padding: const EdgeInsets.only(top: 5.0)),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Text("W"),
                        new Text("T"),
                        new Text("F"),
                        new Text("W"),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Radio(value: "W1", groupValue: categoryVal, onChanged: _handleCategoryChanged),
                        new Radio(value: "T", groupValue: categoryVal, onChanged: _handleCategoryChanged),
                        new Radio(value: "F", groupValue: categoryVal, onChanged: _handleCategoryChanged),
                        new Radio(value: "W2", groupValue: categoryVal, onChanged: _handleCategoryChanged),
                      ],
                    )
                  ],
                )
            )
          ],
      ),
    );
  }
}