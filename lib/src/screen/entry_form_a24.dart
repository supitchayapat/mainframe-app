import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/CompetitionForm.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:myapp/src/model/EventDanceCategory.dart';

const int subColumnTreshold = 12;

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => new _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  HashMap<String, List<String>> levelMap = new HashMap<String, List<String>>();
  ScrollController _minLeftScrollController = new ScrollController();
  ScrollController _rightScrollController = new ScrollController();
  Map<String, Map<String, String>> levelValMap = {};
  CompetitionForm form;
  String categoryVal = "";
  List<String> smoothHeadings = <String>[
    "W", "T", "F", "W"
  ];
  List<String> smoothValues = <String>[
    "W1", "T", "F", "W2"
  ];
  List danceCategories;
  List danceLevels;
  Map<String, Color> smoothBgs = {
    "SMOOTH": Colors.amber,
    "RHYTHM": Colors.lightBlueAccent,
    "F": Colors.indigo,
    "W2": Colors.cyanAccent,
  };

  @override
  void initState() {
    super.initState();
    EventDao.getEvents().then((events){
      events.forEach((event) {
        if(event.danceCategories != null) {
          danceCategories = event.danceCategories;
          danceLevels = event.levels;
        }
      });
    });
  }

  void _scrollListener(notification, ScrollController from, ScrollController to) {
    if(notification is ScrollEndNotification) {
      to.jumpTo(from.offset);
    }
  }

  double get _rPanelWidth {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double rPanelWidth = 205.0;
    if(mediaQueryData.orientation == Orientation.landscape) {
      rPanelWidth = (mediaQueryData.size.width - 250.0) + 135;
    }
    return rPanelWidth;
  }

  Widget _buildLevelColumn(String levelTxt) {
    return new Container(
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
          levelTxt,
          style: new TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat-Light"
          )
      ),
    );
  }

  Widget _buildAgeColumn(String levelTxt, {String buttonTxt : "ADD"}) {
    String _imgAsset = "mainframe_assets/images/add_button.png";
    if(buttonTxt != "ADD") {
      _imgAsset = "mainframe_assets/images/add_highlight.png";
    }
    return new Container(
      alignment: Alignment.center,
      //color: Colors.amber,
      height: 42.0,
      padding: const EdgeInsets.all(5.0),
      child: new MainFrameButton(
        imgAsset: _imgAsset,
        imgHeight: 32.0,
        fontSize: 16.0,
        onPressed: (){
          List<String> _selButtons = <String>[];
          if(levelMap.containsKey(levelTxt)) {
            _selButtons = levelMap[levelTxt];
          }
          showAgeCategoryDialog(context, _selButtons, () {
            //print("COMPLETED");
            //levelMap.putIfAbsent(levelTxt, () => _selButtons);
            levelMap[levelTxt] = _selButtons;
            levelMap.forEach((key, values) { 
              values.forEach((val) => levelValMap.putIfAbsent(key+"_"+val, () => {}));
            });
            if(_selButtons.length < 1) {
              levelMap.remove(levelTxt);
            }
          });
        },
        child: new Text(buttonTxt, style: new TextStyle(color: buttonTxt == "ADD" ? const Color(0xff4e6686) : Colors.white)),
      ),
    );
  }

  List<Widget> _buildRightTable(String tableHeader, List<String> subHeadings, List<int> divisions) {
    List<String> headings = tableHeader.split("||");
    double subheadingWidth = _rPanelWidth / 12;
    int idx = 0;

    return <Widget>[
      new Row(
        children: headings.map((heading){
          double headingWidth = (divisions[idx] == subColumnTreshold) ? 0.0 : subheadingWidth * divisions[idx];
          idx++;
          Widget _headContainer = new Container(
            //color: smoothBgs[heading],
            alignment: Alignment.bottomCenter,
            child: new Container(
              alignment: Alignment.bottomCenter,
              height: 30.0,
              child: new Text(heading),
            ),
          );

          if(headings.length > 1 && headingWidth != 0.0) {
            _headContainer = new Container(
              //color: smoothBgs[heading],
              alignment: Alignment.bottomCenter,
              width: headingWidth,
              child: new Container(
                alignment: Alignment.bottomCenter,
                height: 30.0,
                child: new Text(heading),
              ),
            );
            return _headContainer;
          }
          else {
            return new Expanded(
                child: _headContainer
            );
          }

        }).toList(),
      ),
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: subHeadings.map((heading) {
          return new Expanded(
              child: new Container(
                //color: smoothBgs[heading],
                alignment: Alignment.center,
                child: new Container(
                  alignment: Alignment.center,
                  //color: Colors.amber,
                  //width: 30.0,
                  height: 20.0,
                  child: new Text(heading),
                ),
              )
          );
        }).toList(),
      )
    ];
  }

  List<Widget> _buildRightPanelTabs() {
    List<Widget> rightPanelTabs = <Widget>[];

    if(danceCategories != null) {
      String headings = "";
      Map<String, List<String>> subHeadings = {};
      List<String> subHead = <String>[];
      List<int> divisions = <int>[];
      int bucket = 0;
      // assess groupings
      danceCategories.forEach((danceCategory){
        if(headings.isEmpty) {
          headings += danceCategory.category;
        }
        else {
          headings += "||" + danceCategory.category;
        }
        danceCategory.subCategories.forEach((val) {
          if (bucket < subColumnTreshold) {
            subHead.add(val.subCategory);
            bucket++;
          } else {
            //print(subHead);
            subHeadings.putIfAbsent(headings, () => subHead);
            subHead = <String>[];
            subHead.add(val.subCategory);
            divisions.add(bucket);
            headings = danceCategory.category;
            bucket = 0;
          }
        });
        // record division
        divisions.add(bucket);
      });

      if(subHead.length > 0) {
        subHeadings.putIfAbsent(headings, () => subHead);
      }

      subHeadings.forEach((danceCategory, subDanceCategories) {
        List<Widget> _rightPanelChildren = <Widget>[];
        List<String> subHeadings = <String>[];
        List<String> subHeadingValues = <String>[];
        int idx = 0;
        subDanceCategories.forEach((val) {
          idx++;
          subHeadings.add(val);
          subHeadingValues.add(val+idx.toString());
        });
        //_rightPanelChildren.addAll(_buildRightTable(danceCategory.toUpperCase(), subHeadings, divisions));

        levelMap.forEach((key, values) {
          values.forEach((val) {
            _rightPanelChildren.add(new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: subHeadingValues.map((headingVal) {
                levelValMap[key + "_" + val].putIfAbsent(headingVal, () => "");
                //print(levelValMap[key+"_"+val]);
                Radio radioElement = new Radio(
                    value: headingVal,
                    groupValue: levelValMap[key + "_" + val][headingVal],
                    onChanged: (String radioVal) {
                      //print(radioVal);
                      setState(() {
                        levelValMap[key + "_" + val][headingVal] = radioVal;
                      });
                      //print(levelValMap[key+"_"+val][headingVal]);
                    }
                );

                return new Expanded(
                    child: new InkWell(
                      onTap: () {
                        String catVal = levelValMap[key + "_" +
                            val][headingVal];
                        if (!catVal.isEmpty && catVal == headingVal) {
                          catVal = "";
                        } else {
                          catVal = headingVal;
                        }
                        radioElement.onChanged(catVal);
                      },
                      child: new Container(
                        //color: smoothBgs[headingVal],
                        alignment: Alignment.center,
                        height: 42.0,
                        child: new Container(
                          alignment: Alignment.center,
                          child: radioElement,
                        ),
                      ),
                    )
                );
              }).toList(),
            ));
          });
        });

        List<Widget> _rightPanelTabColumns = <Widget>[];
        _rightPanelTabColumns.addAll(_buildRightTable(danceCategory.toUpperCase(), subHeadings, divisions));
        _rightPanelTabColumns.add(new Flexible(
            child: new NotificationListener(
                onNotification: (notification) { _scrollListener(notification, _rightScrollController, _minLeftScrollController); },
                child: new ListView(
                  controller: _rightScrollController,
                  children: _rightPanelChildren,
                )
            )
        ));

        rightPanelTabs.add(new Container(
            color: new Color(0xff113E69),
            child: new Column(
              children: _rightPanelTabColumns,
            )
        ));
      });
    }
    return rightPanelTabs;
  }

  @override
  Widget build(BuildContext context) {
    List<String> levels = <String>[
      "Newcommer", "Pre-Bronze", "Int. Bronze",
      "Full Bronze", "Pre Silver", "Int. Silver",
      "Full Silver", "Pre Gold", "Int. Gold",
      "Full Gold", "Open Gold"
    ];

    if(danceLevels != null) {
      levels = <String>[];
      danceLevels.forEach((val) {
        levels.add(val.level);
      });
    }

    List<Widget> _children = <Widget>[];
    List<Widget> _childrenAdd = <Widget>[];
    List<Widget> _minLPanelChildren = <Widget>[];

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
      if(!levelMap.containsKey(level)) {
        _children.add(_buildLevelColumn(level));
        _childrenAdd.add(_buildAgeColumn(level));
      } else {
        levelMap[level].forEach((val) {
          List<String> ageValues = val.split(" ");
          _children.add(_buildLevelColumn(level));
          _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0]));
        });
      }
    }

    // minimized left panel children
    //_minLPanelChildren.add();

    //_rightPanelChildren.addAll(_buildRightTable("SMOOTH", smoothHeadings));

    levelMap.forEach((key, values){
      values.forEach((val){
        List<String> ageValues = val.split(" ");
        _minLPanelChildren.add(new Container(
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
              key+" - "+ageValues[0],
              style: new TextStyle(
                  fontSize: 15.0,
                  fontFamily: "Montserrat-Light"
              )
          ),
        ));
      });
    });

    // right panel table
    List<Widget> rightPanelTabs = _buildRightPanelTabs();

    form = new CompetitionForm(
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
          children: <Widget>[
            new Container(
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
                  "LEVEL - AGE",
                  style: new TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold
                  )
              ),
            ),
            new Flexible(
                child: new NotificationListener(
                    onNotification: (notification) { _scrollListener(notification, _minLeftScrollController, _rightScrollController); },
                    child: new ListView(
                      children: _minLPanelChildren,
                      controller: _minLeftScrollController,
                    )
                )
            )
          ],
        ),
      ),
      rightPanelTabs: rightPanelTabs,
    );

    return new Scaffold(
      appBar: new MFAppBar("ENTRY FORM", context),
      body: form,
    );
  }
}