import 'dart:collection';
import 'dart:async';
import 'package:quiver/core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/widget/CompetitionForm.dart';
import 'package:myapp/src/widget/MFButton.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/src/dao/EventDao.dart';
import 'package:myapp/src/model/EventDanceCategory.dart';
import 'package:myapp/src/model/EventEntry.dart';
import 'package:myapp/src/dao/EventEntryDao.dart';
import 'package:myapp/src/model/EventDanceCategory.dart';
import 'package:myapp/src/model/EventLevel.dart';
import 'package:myapp/src/model/FormAgeCat.dart';
import 'package:myapp/src/screen/event_registration.dart' as registration;

const double subColumnTreshold = 40.0;
const double minMaxDiffRpanel = 185.0;

var formEntry;
var formParticipant;
var formData;
var formPushId;

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => new _EntryFormState();
}

class _EntryFormState extends State<EntryForm> with WidgetsBindingObserver {
  HashMap<String, Map<String, FormAgeCat>> _levelMap = new HashMap<String, Map<String, FormAgeCat>>();
  //HashMap<String, List<String>> levelMap = new HashMap<String, List<String>>();
  ScrollController _minLeftScrollController = new ScrollController();
  ScrollController _rightScrollController = new ScrollController();
  Map<String, Map<String, String>> levelValMap = {};
  double rPanelWidth;
  List danceCategories = [];
  List danceLevels = [];
  String _titlePage = "ENTRY FORM";
  bool triggerCategory = false;
  Map<String, Color> smoothBgs = {
    "SMOOTH": Colors.amber,
    "RHYTHM": Colors.lightBlueAccent,
    "F": Colors.indigo,
    "W2": Colors.cyanAccent,
  };

  @override
  void initState() {
    danceCategories = [];
    danceLevels = [];

    super.initState();
    if(formEntry != null && formEntry.name != null) {
      _titlePage = formEntry.name;
    }

    // check if form entry has levels as verticals
    if(formEntry?.structure?.verticals != null && formEntry.structure.verticals.length > 0) {
      for(var _vert in formEntry.structure.verticals) {
        if(_vert.link == "LEVELS") {
          //print("${formEntry.formName} has LEVELS");
          var _formLookup = formEntry.getFormLookup(_vert.link);
          //print(_formLookup.toJson());

          //danceCategories = event.danceCategories;
          //rPanelWidth = 0.0;
          /*danceCategories.forEach((danceCategory){
            rPanelWidth += danceCategory.subCategories.length;
          });*/
          //print("$rPanelWidth first init");
          //rPanelWidth = rPanelWidth * subColumnTreshold;
          //print("$rPanelWidth last init");
          for(var elem in _formLookup.elements) {
            EventLevel lvl = new EventLevel(level: elem.content, order: elem.order);
            danceLevels.add(lvl);
          }
          //print(danceLevels);
        }
        if(_vert.link == "DANCECAT") {
          triggerCategory = true;
        }
      }
    }
    // build horizontals
    if(formEntry?.structure?.horizontals != null && formEntry.structure.horizontals.length > 0) {
      Map<String, EventDanceCategory> danceCatMap = {};
      for(var _horizon in formEntry.structure.horizontals) {
        if(_horizon.position == "header") {
          var _formLookup = formEntry.getFormLookup(_horizon.link);
          //print(_formLookup.toJson());
          for(var elem in _formLookup.elements) {
            EventDanceCategory category = new EventDanceCategory(category: elem.content, order: elem.order, code: elem.code);
            danceCatMap.putIfAbsent(elem.code, () => category);
          }
        }
        if(_horizon.position == "subheader") {
          var _formLookup = formEntry.getFormLookup(_horizon.link);
          //print(_formLookup.toJson());
          var _headLookup = formEntry.getFormLookup("HEADERS");
          for(var elem in _formLookup.elements) {
            DanceSubCategory subCategory = new DanceSubCategory(subCategory: elem.code, order: elem.order, code: elem.code);
            for(var elem2 in _headLookup.elements) {
              if(elem2.id == elem.grouping) {
                if(danceCatMap[elem2.code].subCategories == null) {
                  danceCatMap[elem2.code].subCategories = [];
                }
                danceCatMap[elem2.code].subCategories.add(subCategory);
              }
            }
          }
        }
      }

      if(danceCatMap != null) {
        danceCatMap.forEach((key, val) {
          //print(val.toJson());
          //print("sub length: ${val.subCategories.length}");
          danceCategories.add(val);
        });

        rPanelWidth = 0.0;
        danceCategories.forEach((danceCategory){
          rPanelWidth += danceCategory.subCategories.length;
        });
        rPanelWidth = rPanelWidth * subColumnTreshold;
      }
      //print(danceCategories.map((val) => val.toJson()));
    }
    /*EventDao.getEvents().then((events){
      events.forEach((event) {
        if(event.danceCategories != null) {
          danceCategories = event.danceCategories;
          rPanelWidth = 0.0;
          danceCategories.forEach((danceCategory){
            rPanelWidth += danceCategory.subCategories.length;
          });
          //print("$rPanelWidth first init");
          rPanelWidth = rPanelWidth * subColumnTreshold;
          //print("$rPanelWidth last init");
          danceLevels = event.levels;
        }
      });
    });*/
    //print("Data length: ${formData?.length}");
    //print("pushId: ${formPushId}");
    // build data if formData is not null
    if(formData != null) {
      for(var _lvData in formData) {
        String _lvlName = _lvData.levelName;
        Map<String, FormAgeCat> _lvAgeMap = {};
        for(var _subCat in _lvData.ageMap) {
          //print("age: ${_subCat.ageCategory}");
          //print("categoryMap: ${_subCat.subCategoryMap}");
          FormAgeCat _ageCat = new FormAgeCat(
              age: _subCat.ageCategory,
              catOpen: _subCat.catOpen,
              catClosed: _subCat.catClosed
          );
          _lvAgeMap.putIfAbsent(_subCat.ageCategory, () => _ageCat);
          if(_subCat.subCategoryMap != null) {
            Map<String, String> _lvValAgeMap = {};
            _subCat.subCategoryMap.forEach((_k, _v){
              if(_v) {
                _lvValAgeMap.putIfAbsent(_k, () => _k);
              } else {
                _lvValAgeMap.putIfAbsent(_k, () => "");
              }
            });
            String _catOpenClose = "";
            if(triggerCategory) {
              _catOpenClose = (_subCat.catOpen) ? "O" : "C";
            }
            levelValMap.putIfAbsent(_lvlName+"_"+_subCat.ageCategory+_catOpenClose, () => _lvValAgeMap);
          }
        }
        _levelMap.putIfAbsent(_lvlName, () => _lvAgeMap);
      }
    }
  }

  @override
  Future<Null> handlePopRoute() async {
    print("pop handled");
  }

  Future _handleSaving() async {
    if(_levelMap.length > 0) {
      var val = await showMainFrameDialogWithCancel(
          context, "Entry Changed", "Save Changes on ${formEntry.name}?");
      if (val == "OK") {
        //print("Saving changes");
        EventEntry entry = new EventEntry(
          formEntry: formEntry,
          event: registration.eventItem,
          participant: formParticipant,
        );
        int danceEntries = 0;
        entry.levels = [];
        _levelMap.forEach((key, values) {
          LevelEntry levelEntry = new LevelEntry();
          levelEntry.levelName = key;
          levelEntry.ageMap = [];
          values.forEach((key2, val) {
            SubCategoryEntry subEntry = new SubCategoryEntry();
            subEntry.ageCategory = key2;
            subEntry.subCategoryMap = {};
            //print("${key}_$key2 levelValMap: ${levelValMap[key+"_"+key2]}");

            if (triggerCategory) {
              subEntry.catOpen = val.catOpen;
              subEntry.catClosed = val.catClosed;
              [
                {"op": "O", "catOC": val.catOpen},
                {"op": "C", "catOC": val.catClosed}
              ].forEach((_categ) {
                if (_categ["catOC"]) {
                  levelValMap[key + "_" + key2 + _categ["op"]].forEach((key3,
                      value) {
                    if (value != null && !value.isEmpty) {
                      subEntry.subCategoryMap.putIfAbsent(key3, () => true);
                      danceEntries += 1;
                    } else {
                      subEntry.subCategoryMap.putIfAbsent(key3, () => false);
                    }
                  });
                }
              });
            }
            else {
              levelValMap[key + "_" + key2].forEach((key3, value) {
                if (value != null && !value.isEmpty) {
                  subEntry.subCategoryMap.putIfAbsent(key3, () => true);
                  danceEntries += 1;
                } else {
                  subEntry.subCategoryMap.putIfAbsent(key3, () => false);
                }
              });
            }

            if (subEntry.subCategoryMap.length > 0)
              levelEntry.ageMap.add(subEntry);
          });
          if (levelEntry.ageMap.length > 0)
            entry.levels.add(levelEntry);
        });

        entry.danceEntries = danceEntries;
        //print(entry.toJson());
        if (entry.levels.length > 0) {
          if(formPushId != null) {
            EventEntryDao.updateEventEntry(formPushId, entry);
          } else {
            EventEntryDao.saveEventEntry(entry);
          }
        }
        Navigator.of(context).maybePop();
      }
      else {
        Navigator.of(context).maybePop();
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _scrollListener(notification, ScrollController from, ScrollController to) {
    if(notification is ScrollEndNotification) { // change to ScrollEndNotification to prevent exception
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

    // build ages text
    List<String> agesText = [];
    if(formEntry?.structure?.verticals != null && formEntry.structure.verticals.length > 0) {
      for (var _vert in formEntry.structure.verticals) {
        if (_vert.link == "AGES") {
          var _formLookup = formEntry.getFormLookup(_vert.link);
          if(_formLookup?.elements != null && _formLookup.elements.length > 0) {
            _formLookup.elements.forEach((_elem){
              //print(_elem.toJson());
              agesText.add(_elem.content);
            });
          }
        }
      }
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
          //print(_levelMap[levelTxt]);
          Map<String, FormAgeCat> _selButtons = {};
          if(_levelMap.containsKey(levelTxt)) {
            //_selButtons.addAll(levelMap[levelTxt]);
            /*for(var _lm in _levelMap[levelTxt]) {
              _selButtons.putIfAbsent(_lm, () => new FormAgeCat());
            }*/
            _levelMap[levelTxt].forEach((key,val){
              _selButtons.putIfAbsent(key, () => val);
            });
          }
          showAgeCategoryDialog(context, triggerCategory, agesText, _selButtons, () {
            //print("COMPLETED");
            //print("_levelMap[levelTxt] = ${_levelMap[levelTxt]}");
            //print("_selButtons = ${_selButtons}");
            List<String> _selBtnList = [];
            _selButtons.forEach((key, val){
              _selBtnList.add(key);
            });
            //levelMap.putIfAbsent(levelTxt, () => _selButtons);
            _levelMap[levelTxt] = _selButtons;
            _levelMap.forEach((key, values) {
              if(triggerCategory) {
                values.forEach((key2, val) {
                  if(val.catOpen)
                    levelValMap.putIfAbsent(key+"_"+key2+"O", () => {});
                  if(val.catClosed)
                    levelValMap.putIfAbsent(key+"_"+key2+"C", () => {});
                });
              }
              else {
                values.forEach((key2, val) =>
                    levelValMap.putIfAbsent(key + "_" + key2, () => {}));
              }
            });
            if(_selButtons.length < 1) {
              _levelMap.remove(levelTxt);
            }
          });
        },
        child: new Text(buttonTxt, style: new TextStyle(color: buttonTxt == "ADD" ? const Color(0xff4e6686) : Colors.white)),
      ),
    );
  }

  List<Widget> _buildRightTable() {
    int idx = 0;
    return <Widget>[
      new Row(
        children: danceCategories.map((danceCategory){
          return new Column(
            children: <Widget>[
              new Container(
                child: new Text(danceCategory.category.toUpperCase()),
                alignment: Alignment.bottomCenter,
                height: 30.0,
              ),
              new Row(
                children: danceCategory.subCategories.map((sub){
                  //print("idx: $idx mod: "+(idx % 2).toString());
                  idx += 1;
                  return new Container(
                    //color: (idx % 2) != 0 ? Colors.amber : Colors.cyanAccent,
                    width: subColumnTreshold,
                    height: 20.0,
                    alignment: Alignment.center,
                    child: new Text(sub.subCategory),
                  );
                }).toList(),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
          );
        }).toList(),
      )
    ];
  }

  List<Widget> _buildRightPanelTabs(levels) {
    List<Widget> rightPanelTabs = <Widget>[];
    List<Widget> _rightPanelChildren = <Widget>[];
    List<String> subHeadingValues = <String>[];
    List<Widget> _rightPanelTabColumns = <Widget>[];

    if(danceCategories != null) {
      _rightPanelTabColumns.addAll(_buildRightTable());

      danceCategories.forEach((danceCategory) {
        danceCategory.subCategories.forEach((val) {
          subHeadingValues.add(val.subCategory + val.order.toString());
        });
      });
    }

    for(var _lvl in levels) {
      _levelMap[_lvl]?.forEach((key2, val) {
        if(triggerCategory) {
          [{"op": "O", "catOC": val.catOpen},{"op": "C", "catOC": val.catClosed}].forEach((_categ){
            if(_categ["catOC"]) {
              _rightPanelChildren.add(new Row(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: subHeadingValues.map((headingVal) {
                  if(levelValMap[_lvl + "_" + key2 + _categ["op"]] == null) {
                    levelValMap[_lvl + "_" + key2 + _categ["op"]] = {};
                  }
                  levelValMap[_lvl + "_" + key2 + _categ["op"]].putIfAbsent(
                      headingVal, () => "");
                  //print("[$key $val] $headingVal -- ${levelValMap[key+"_"+val]}");
                  Radio radioElement = new Radio(
                      value: headingVal,
                      groupValue: levelValMap[_lvl + "_" + key2 + _categ["op"]][headingVal],
                      onChanged: (String radioVal) {
                        //print(radioVal);
                        setState(() {
                          levelValMap[_lvl + "_" + key2 + _categ["op"]][headingVal] = radioVal;
                        });
                        //print(levelValMap[key+"_"+val][headingVal]);
                      }
                  );

                  return new Container(
                      width: subColumnTreshold,
                      //color: Colors.amber,
                      child: new InkWell(
                        onTap: () {
                          String catVal = levelValMap[_lvl + "_" +
                              key2 + _categ["op"]][headingVal];
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
            }
          });
        } else {
          _rightPanelChildren.add(new Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: subHeadingValues.map((headingVal) {
              levelValMap[_lvl + "_" + key2].putIfAbsent(headingVal, () => "");
              //print("[$key $val] $headingVal -- ${levelValMap[key+"_"+val]}");
              Radio radioElement = new Radio(
                  value: headingVal,
                  groupValue: levelValMap[_lvl + "_" + key2][headingVal],
                  onChanged: (String radioVal) {
                    //print(radioVal);
                    setState(() {
                      levelValMap[_lvl + "_" + key2][headingVal] = radioVal;
                    });
                    //print(levelValMap[key+"_"+val][headingVal]);
                  }
              );

              return new Container(
                  width: subColumnTreshold,
                  //color: Colors.amber,
                  child: new InkWell(
                    onTap: () {
                      String catVal = levelValMap[_lvl + "_" +
                          key2][headingVal];
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
        }
      });
    }

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
    double scrn_width = MediaQuery.of(context).size.width;
    double allowableRPanel = (scrn_width - 300.0) + minMaxDiffRpanel;

    if(rPanelWidth < allowableRPanel) {
      rPanelWidth = allowableRPanel;
    }
    //print("rpanelwidth: $rPanelWidth");
    //print("screen: ${MediaQuery.of(context).size.width}");

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
          ),
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
          triggerCategory ? "AGE/CAT" : "AGE",
          style: new TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
          )
      ),
    ));

    //print(levelValMap);
    //print("levelMap: $_levelMap");
    for(String level in levels) {
      if(!_levelMap.containsKey(level)) {
        _children.add(_buildLevelColumn(level));
        _childrenAdd.add(_buildAgeColumn(level));
      } else {
        _levelMap[level].forEach((key, val) {
          //print("level: $level key: $key");
          List<String> ageValues = key.split(" ");
          if(triggerCategory && val.catOpen == true) {
            _children.add(_buildLevelColumn(level));
            _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0] + " O"));
          }
          if(triggerCategory && val.catClosed == true) {
            _children.add(_buildLevelColumn(level));
            _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0] + " C"));
          }
          if(!triggerCategory) {
            _children.add(_buildLevelColumn(level));
            _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0]));
          }
        });
      }

      _levelMap[level]?.forEach((key2, val){
        List<String> ageValues = key2.split(" ");
        if(triggerCategory) {
          [
            {"op": "O", "catOC": val.catOpen},
            {"op": "C", "catOC": val.catClosed}
          ].forEach((_categ) {
            if(_categ["catOC"]) {
              _minLPanelChildren.add(new Container(
                alignment: Alignment.center,
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new ExactAssetImage(
                            "mainframe_assets/images/level_row_divider.png"),
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter
                    ),
                    color: const Color(0xff1983A8)
                ),
                padding: const EdgeInsets.all(5.0),
                height: 42.0,
                child: new Text(
                    level + " " + ageValues[0] + " " + _categ["op"],
                    style: new TextStyle(
                        fontSize: 15.0,
                        fontFamily: "Montserrat-Light"
                    )
                ),
              ));
            }
          });
        } else {
          _minLPanelChildren.add(new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new ExactAssetImage("mainframe_assets/images/level_row_divider.png"),
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter
                ),
                color: const Color(0xff1983A8)
            ),
            padding: const EdgeInsets.all(5.0),
            height: 42.0,
            child: new Text(
                level+" "+ageValues[0],
                style: new TextStyle(
                    fontSize: 15.0,
                    fontFamily: "Montserrat-Light"
                )
            ),
          ));
        }
      });
    }

    // minimized left panel children
    //_minLPanelChildren.add();

    //_rightPanelChildren.addAll(_buildRightTable("SMOOTH", smoothHeadings));

    /*_levelMap.forEach((key, values){

    });*/

    // right panel table
    List<Widget> rightPanelTabs = _buildRightPanelTabs(levels);

    return new Scaffold(
      appBar: new MFAppBar(_titlePage, context, backButtonFunc: _handleSaving),
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
                        image: new ExactAssetImage("mainframe_assets/images/level_row_divider.png", scale: 1.0),
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter
                    ),
                    color: const Color(0xff1983A8)
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
        rPanelWidth: rPanelWidth,
      ),
    );
  }
}