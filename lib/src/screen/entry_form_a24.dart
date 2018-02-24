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
import 'package:mframe_plugins/mframe_plugins.dart';

double subColumnTreshold = 40.0;
const double minMaxDiffRpanel = 185.0;

var formEntry;
var formParticipant;
var formData;
var formPushId;

class EntryFormExclude {
  String level;
  String age;
  String dance;
  String danceCategory;

  EntryFormExclude({this.level : "", this.age : "", this.dance : "", this.danceCategory : ""});

  bool operator ==(o) => o is EntryFormExclude && o.level == level && o.age == age && o.dance == dance && o.danceCategory == danceCategory;
  int get hashCode => hash2(level.hashCode, age.hashCode);

  toJson() {
    return {
      "level": level,
      "age": age,
      "dance": dance
    };
  }
}

class EntryForm extends StatefulWidget {
  @override
  _EntryFormState createState() => new _EntryFormState();
}

class _EntryFormState extends State<EntryForm> with WidgetsBindingObserver {
  HashMap<String, Map<String, FormAgeCat>> _levelMap = new HashMap<String, Map<String, FormAgeCat>>();
  HashMap<String, List<String>> _ageMap = new HashMap<String, List<String>>();
  ScrollController _minLeftScrollController = new ScrollController();
  ScrollController _rightScrollController = new ScrollController();
  Map<String, Map<String, String>> levelValMap = {};
  Map<String, Map<String, String>> levelValPaidMap = {};
  Set<EntryFormExclude> excludes = new Set<EntryFormExclude>();
  double rPanelWidth;
  List danceCategories = [];
  List danceLevels = [];
  String _titlePage = "ENTRY FORM";
  bool triggerCategory = false;
  bool isVerticalLvl = false;
  Map<String, int> subheadingIdx = {};
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

    // set landscape
    MframePlugins.setToLandscape();

    super.initState();
    if(formEntry != null && formEntry.name != null) {
      _titlePage = formEntry.name;
    }

    // check if form entry has levels as verticals
    List danceAges = [];
    if(formEntry?.structure?.verticals != null && formEntry.structure.verticals.length > 0) {
      for(var _vert in formEntry.structure.verticals) {
        if(_vert.link == "LEVELS") {
          isVerticalLvl = true;
          //print("${formEntry.formName} has LEVELS");
          var _formLookup = formEntry.getFormLookup(_vert.link);
          //print(_formLookup.toJson());
          for(var elem in _formLookup.elements) {
            EventLevel lvl = new EventLevel(level: elem.content, order: elem.order);
            danceLevels.add(lvl);
          }
          //print(danceLevels);
        }
        if(_vert.link == "DANCECAT") {
          triggerCategory = true;
        }
        if(_vert.link == "AGES") {
          var _formLookup = formEntry.getFormLookup(_vert.link);
          //print(_formLookup.toJson());
          for(var elem in _formLookup.elements) {
            EventLevel lvl = new EventLevel(level: elem.content, order: elem.order);
            danceAges.add(lvl);
          }
        }
      }
      // check if Levels is not on verticals
      if(!isVerticalLvl) {
        danceLevels.addAll(danceAges);
        // populate Age Map
        var _headLookup = formEntry.getFormLookup("LEVELS");
        for(var _danceLvl in danceLevels) {
          List<String> _headLvList = [];
          for(var elem2 in _headLookup.elements) {
            _headLvList.add(elem2.code);
            levelValMap.putIfAbsent((elem2.code).toString().toLowerCase() + "_" + _danceLvl.level, () => {});
          }
          _ageMap.putIfAbsent(_danceLvl.level, () => _headLvList);
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
          var _headLookup;
          if(isVerticalLvl)
            _headLookup = formEntry.getFormLookup("HEADERS");
          else
            _headLookup = formEntry.getFormLookup("LEVELS");

          bool _changeTreshold = false;

          for(var elem in _formLookup.elements) {
            DanceSubCategory subCategory = new DanceSubCategory(subCategory: elem.code, order: elem.order, code: elem.code, id: elem.id);
            if(subCategory.code.length > 4 && !_changeTreshold) {
              _changeTreshold = true;
            }

            for(var elem2 in _headLookup.elements) {
              if(elem2.id == elem.grouping) {
                if(danceCatMap[elem2.code].subCategories == null) {
                  danceCatMap[elem2.code].subCategories = [];
                }
                danceCatMap[elem2.code].subCategories.add(subCategory);
              }
            }
          }

          if(_changeTreshold) {
            setState((){subColumnTreshold = 60.0;});
          } else {
            setState((){subColumnTreshold = 40.0;});
          }
        }
      }

      if(danceCatMap != null) {
        danceCatMap.forEach((key, val) {
          //print("key: $key");
          //print(val.toJson());
          //print("sub length: ${val.subCategories.length}");

          if(!isVerticalLvl) {
            levelValMap.forEach((_key, _val) {
              String _lvl = _key.substring(0, _key.indexOf("_"));
              //print("_lvl: $_lvl");
              if(_lvl == ((key).toString().toLowerCase())) {
                for(var _subCat in val.subCategories) {
                  _val.putIfAbsent("${_subCat.subCategory}${_subCat.id}", () => "");
                }
              }
            });
          }

          danceCategories.add(val);
        });

        rPanelWidth = 0.0;
        danceCategories.forEach((danceCategory){
          rPanelWidth += danceCategory.subCategories.length;
        });
        rPanelWidth = rPanelWidth * subColumnTreshold;
      }
      //print(danceCategories.map((val) => val.toJson()));
      //danceCategories.forEach((val) => print(val.toJson()));
    }
    // build exclusions
    if(formEntry?.exclusions != null && formEntry.exclusions.length > 0) {
      formEntry.exclusions.forEach((val){
        //print(val.toJson());
        // compose the vertical exclusions
        String _age = "";
        String _level = "";
        String _danceCat = "";
        for(var _vert in val.vertical) {
          //print(_vert.toJson());
          var _formLookup = formEntry.getFormLookup(_vert.lookup);
          for(var elem in _formLookup.elements) {
            if(elem.id.toString() == _vert.content) {
              if(_vert.lookup.toLowerCase() == "levels") {
                _level = elem.content;
                break;
              }
              else if(_vert.lookup.toLowerCase() == "ages") {
                _age = elem.content;
                break;
              }
              else if(_vert.lookup.toLowerCase() == "dancecat") {
                _age = elem.code;
                break;
              }
            }
          }
        }
        //print("AGE: $_age");
        //print("LEVEL: $_level");
        // compose horizontal
        var _horizontal = val.horizontal;
        List<String> danceIds = _horizontal.content.split(",");
        if(danceIds != null && danceIds.length > 0) {
          for(String danceId in danceIds) {
            EntryFormExclude _exclude;
            if(!triggerCategory) {
              _exclude = new EntryFormExclude(level: _level.toLowerCase(), age: _age);
            }
            else {
              _exclude = new EntryFormExclude(level: _level.toLowerCase(), age: _age, danceCategory: _danceCat);
            }
            var _formLookup = formEntry.getFormLookup(_horizontal.lookup);
            for(var elem in _formLookup.elements) {
              if(elem.id.toString() == danceId) {
                _exclude.dance = elem.code+elem.id.toString();
                break;
              }
            }

            excludes.add(_exclude);
          }
        }
      });

      //excludes.forEach((val) => print(val.toJson()));
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
    //print("Data length: ${formData}");
    //print("pushId: ${formPushId}");
    // build data if formData is not null
    if(formData != null) {
      for(var _lvData in formData) {
        print(_lvData.toJson());
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

          if(!_lvAgeMap.containsKey(_subCat.ageCategory))
            _lvAgeMap.putIfAbsent(_subCat.ageCategory, () => _ageCat);
          else {
            //print("CONTAINS");
            var _tempAgeCat = _lvAgeMap[_subCat.ageCategory];
            if(_tempAgeCat.catOpen || _ageCat.catOpen)
              _tempAgeCat.catOpen = true;
            if(_tempAgeCat.catClosed || _ageCat.catClosed)
              _tempAgeCat.catClosed = true;
            //print(_lvAgeMap[_subCat.ageCategory].toJson());
          }
          if(_subCat.subCategoryMap != null) {
            Map<String, String> _lvValAgeMap = {};
            Map<String, String> _lvValPaidMap = {};
            _subCat.subCategoryMap.forEach((_k, _v){
              //print("$_k : $_v");
              if(_v["selected"]) {
                _lvValAgeMap.putIfAbsent(_k, () => _k);
              } else {
                _lvValAgeMap.putIfAbsent(_k, () => "");
              }
              if(_v["paid"]) {
                _lvValPaidMap.putIfAbsent(_k, () => _k);
              } else {
                _lvValPaidMap.putIfAbsent(_k, () => "");
              }
            });
            //print("lvValAgeMap: $_lvValAgeMap");
            String _catOpenClose = "";
            if(triggerCategory) {
              _catOpenClose = (_subCat.catOpen) ? "O" : "C";
            }
            //print(_lvValAgeMap);
            if(isVerticalLvl || !levelValMap.containsKey(_lvlName + "_" + _subCat.ageCategory + _catOpenClose)) {
              levelValMap.putIfAbsent(_lvlName + "_" + _subCat.ageCategory + _catOpenClose, () => _lvValAgeMap);
            } else {
              if(levelValMap.containsKey(_lvlName + "_" + _subCat.ageCategory + _catOpenClose)) {
                levelValMap[_lvlName + "_" + _subCat.ageCategory + _catOpenClose] = _lvValAgeMap;
              }
            }
            levelValPaidMap.putIfAbsent(_lvlName + "_" + _subCat.ageCategory + _catOpenClose, () => _lvValPaidMap);
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

  @override
  void dispose() {
    super.dispose();
    MframePlugins.setToPortrait();
  }

  Future _handleSaving() async {
    if(_levelMap.length > 0 || _ageMap.length > 0) {
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
        int paidEntries = 0;
        entry.levels = [];

        // for vertical levels
        if(isVerticalLvl) {
          _levelMap.forEach((key, values) {
            LevelEntry levelEntry = new LevelEntry();
            levelEntry.levelName = key;
            levelEntry.ageMap = [];
            values.forEach((key2, val) {
              //print("${key}_$key2 levelValMap: ${levelValMap[key+"_"+key2]}");

              if (triggerCategory) {
                [
                  {"op": "O", "catOC": val.catOpen},
                  {"op": "C", "catOC": val.catClosed}
                ].forEach((_categ) {
                  if (_categ["catOC"]) {
                    SubCategoryEntry subEntry = new SubCategoryEntry();
                    subEntry.ageCategory = key2;
                    subEntry.subCategoryMap = {};
                    if(_categ["op"] == "O")
                      subEntry.catOpen = _categ["catOC"];
                    else
                      subEntry.catClosed = _categ["catOC"];

                    levelValMap[key + "_" + key2 + _categ["op"]].forEach((key3,
                        value) {

                      bool isPaid = isPaidSubCategory(key + "_" + key2 + _categ["op"], key3);
                      if (value != null && !value.isEmpty) {
                        subEntry.subCategoryMap.putIfAbsent(key3, () => { "selected": true, "paid": isPaid });
                        danceEntries += 1;
                      } else {
                        subEntry.subCategoryMap.putIfAbsent(key3, () => { "selected": false, "paid": isPaid });
                      }

                      if(isPaid) {
                        paidEntries += 1;
                      }
                    });

                    print(subEntry.toJson());

                    if (subEntry.subCategoryMap.length > 0)
                      levelEntry.ageMap.add(subEntry);
                  }
                });
              }
              else {
                SubCategoryEntry subEntry = new SubCategoryEntry();
                subEntry.ageCategory = key2;
                subEntry.subCategoryMap = {};

                levelValMap[key + "_" + key2].forEach((key3, value) {
                  bool isPaid = isPaidSubCategory(key + "_" + key2, value);
                  if (value != null && !value.isEmpty) {
                    subEntry.subCategoryMap.putIfAbsent(key3, () => { "selected": true, "paid": isPaid });
                    danceEntries += 1;
                  } else {
                    subEntry.subCategoryMap.putIfAbsent(key3, () => { "selected": false, "paid": isPaid });
                  }

                  if(isPaid) {
                    paidEntries += 1;
                  }
                });

                if (subEntry.subCategoryMap.length > 0)
                  levelEntry.ageMap.add(subEntry);
              }

            });
            if (levelEntry.ageMap.length > 0)
              entry.levels.add(levelEntry);
          });
        }
        // for levels on horizontal
        else {
          _ageMap.forEach((key, values) {
            values.forEach((val) {
              LevelEntry levelEntry = new LevelEntry();
              levelEntry.levelName = val.toLowerCase();
              levelEntry.ageMap = [];
              SubCategoryEntry subEntry = new SubCategoryEntry();
              subEntry.ageCategory = key;
              subEntry.subCategoryMap = {};
              //print("${key}_$key2 levelValMap: ${levelValMap[key+"_"+key2]}");

              var _idx = "${val.toLowerCase()}_$key";
              bool _hasCategoryEntry = false;
              levelValMap[_idx].forEach((key3, value) {
                bool isPaid = isPaidSubCategory(_idx, value);
                if (value != null && !value.isEmpty) {
                  subEntry.subCategoryMap.putIfAbsent(key3, () => { "selected": true, "paid": isPaid });
                  danceEntries += 1;
                  _hasCategoryEntry = true;
                } else {
                  subEntry.subCategoryMap.putIfAbsent(key3, () => { "selected": false, "paid": isPaid });
                }

                if(isPaid) {
                  paidEntries += 1;
                }
              });

              if (subEntry.subCategoryMap.length > 0 && _hasCategoryEntry)
                levelEntry.ageMap.add(subEntry);

              if (levelEntry.ageMap.length > 0)
                entry.levels.add(levelEntry);
            });
          });
        }

        entry.danceEntries = danceEntries;
        entry.paidEntries = paidEntries;
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
              FormAgeCat _temp = new FormAgeCat(age: val.age, catOpen: val.catOpen, catClosed: val.catClosed);
              _selButtons.putIfAbsent(key, () => _temp);
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
    subheadingIdx = {};
    int idx = 0;
    int col = 0;
    return <Widget>[
      new Row(
        children: danceCategories.map((danceCategory){
          //print(col % 2);
          return new Container(
            color: (col++ % 2 == 1) ? const Color(0xff1e5484) : Colors.transparent,
            child: new Column(
              children: <Widget>[
                new Container(
                  //color: Colors.amber,
                  child: new Text(danceCategory.category.toUpperCase()),
                  alignment: Alignment.bottomCenter,
                  height: 30.0,
                ),
                new Row(
                  children: danceCategory.subCategories.map((sub){
                    //print("idx: $idx mod: "+(idx % 2).toString());
                    subheadingIdx.putIfAbsent("${danceCategory.code.toUpperCase()} ${sub.subCategory}${sub.id}", () => (col-1) % 2);
                    idx += 1;
                    Text _subText;
                    Color _contColor;
                    if(sub?.subCategory?.length > 6) {
                      _contColor = Colors.amber;
                      _subText = new Text(sub.subCategory, style: new TextStyle(fontSize: 12.0), textAlign: TextAlign.justify);
                    }
                    else {
                      _contColor = Colors.transparent;
                      _subText = new Text(sub.subCategory);
                    }
                    return new Container(
                      //color: (idx % 2) != 0 ? Colors.amber : Colors.cyanAccent,
                      width: subColumnTreshold,
                      //color: _contColor,
                      height: 20.0,
                      alignment: Alignment.center,
                      child: _subText,
                    );
                  }).toList(),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
          );
        }).toList(),
      )
    ];
  }

  bool isPaidSubCategory(idx, headingVal) {
    if(levelValPaidMap[idx] != null) {
      if (levelValPaidMap[idx][headingVal] != null &&
          levelValPaidMap[idx][headingVal].isNotEmpty) {
        //print("$idx ${levelValPaidMap[idx][headingVal]}");
        return true;
      }
    }
    return false;
  }

  Widget _generateRadioContainer(_lvlValMapIdx, headingVal, _exclude, _key) {
    if (levelValMap[_lvlValMapIdx] == null) {
      levelValMap[_lvlValMapIdx] = {};
    }
    levelValMap[_lvlValMapIdx].putIfAbsent(headingVal, () => "");

    Radio _rPanelRadio = new Radio(
        activeColor: isPaidSubCategory(_lvlValMapIdx, headingVal) ? new Color(0xff00e5ff) : Colors.white,
        value: headingVal,
        groupValue: levelValMap[_lvlValMapIdx][headingVal],
        onChanged: (String radioVal) {
          if(!excludes.contains(_exclude) && !isPaidSubCategory(_lvlValMapIdx, headingVal)) {
            setState(() {
              levelValMap[_lvlValMapIdx][headingVal] = radioVal;
            });
          }
        }
    );

    Widget _container = new Container(
        width: subColumnTreshold,
        color: subheadingIdx["${_key} ${headingVal}"] == 1 ? const Color(0xff1e5484) : Colors.transparent,
        child: new InkWell(
          onTap: () {
            if(!excludes.contains(_exclude)) {
              String catVal = levelValMap[_lvlValMapIdx][headingVal];
              if (!catVal.isEmpty && catVal == headingVal) {
                catVal = "";
              } else {
                catVal = headingVal;
              }
              _rPanelRadio.onChanged(catVal);
            }
          },
          child: new Container(
            alignment: Alignment.center,
            height: 42.0,
            child: new Container(
              alignment: Alignment.center,
              child: excludes.contains(_exclude) ? new Icon(Icons.highlight_off) : _rPanelRadio,
            ),
          ),
        )
    );

    return _container;
  }

  List<Widget> _buildRightPanelTabs(levels) {
    List<Widget> rightPanelTabs = <Widget>[];
    List<Widget> _rightPanelChildren = <Widget>[];
    //List<String> subHeadingValues = <String>[];
    Map<String, List<String>> subHeadingValues = {};
    List<Widget> _rightPanelTabColumns = <Widget>[];

    if(danceCategories != null) {
      _rightPanelTabColumns.addAll(_buildRightTable());

      danceCategories.forEach((danceCategory) {
        List<String> _subValues = [];
        danceCategory.subCategories.forEach((val) {
          _subValues.add(val.subCategory + val.id.toString());
          //subHeadingValues.add(val.subCategory + val.id.toString());
        });
        subHeadingValues.putIfAbsent(danceCategory.code.toUpperCase(), () => _subValues);
      });
    }

    //print(subheadingIdx);
    //print(subHeadingValues);

    for(var _lvl in levels) {
      if(isVerticalLvl) {
        _levelMap[_lvl]?.forEach((key2, val) {
          if (triggerCategory) {
            [
              {"op": "O", "catOC": val.catOpen},
              {"op": "C", "catOC": val.catClosed}
            ].forEach((_categ) {
              if (_categ["catOC"]) {
                List<Widget> _rPanelContainers = [];
                subHeadingValues.forEach((_key, subValues){
                  for(var headingVal in subValues) {
                    String _lvlValMapIdx = _lvl + "_" + key2 + _categ["op"];
                    EntryFormExclude _exclude = new EntryFormExclude(level: _lvl.toLowerCase(), age: key2, dance: headingVal, danceCategory: _categ["op"]);
                    _rPanelContainers.add(_generateRadioContainer(_lvlValMapIdx, headingVal, _exclude, _key));
                  }
                });
                _rightPanelChildren.add(new Row(children: _rPanelContainers));
              }
            });
          } else {
            List<Widget> _rPanelContainers = [];
            subHeadingValues.forEach((_key, subValues){
              for(var headingVal in subValues) {
                String _lvlValMapIdx = _lvl + "_" + key2;
                EntryFormExclude _exclude = new EntryFormExclude(level: _lvl.toLowerCase(), age: key2, dance: headingVal);
                _rPanelContainers.add(_generateRadioContainer(_lvlValMapIdx, headingVal, _exclude, _key));
              }
            });
            _rightPanelChildren.add(new Row(children: _rPanelContainers));
          }
        });
      } else {
        List<Widget> _rPanelContainers = [];
        subHeadingValues.forEach((_key, subValues){
          for(var headingVal in subValues) {
            //print(headingVal);
            for(var val in _ageMap[_lvl]) {
              var _idx = "${val.toLowerCase()}_$_lvl";
              if(!levelValMap[_idx].containsKey(headingVal)) {
                continue;
              }
              EntryFormExclude _exclude = new EntryFormExclude(level: "", age: _lvl, dance: headingVal);
              _rPanelContainers.add(_generateRadioContainer(_idx, headingVal, _exclude, _key));
            }
          }
        });
        _rightPanelChildren.add(new Row(children: _rPanelContainers));
      }
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
          isVerticalLvl ? "LEVEL" : "AGE",
          style: new TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold
          )
      ),
    ));
    if(isVerticalLvl) {
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
    }

    //print(levelValMap);
    //print("levelMap: $_levelMap");
    //print("paidMap: $levelValPaidMap");
    for(String level in levels) {
      if(!_levelMap.containsKey(level)) {
        _children.add(_buildLevelColumn(level));
        if(isVerticalLvl)
          _childrenAdd.add(_buildAgeColumn(level));
      } else {
        _levelMap[level].forEach((key, val) {
          //print("level: $level key: $key");
          List<String> ageValues = key.split(" ");
          if(triggerCategory && val.catOpen == true) {
            _children.add(_buildLevelColumn(level));
            if(isVerticalLvl)
              _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0] + " O"));
          }
          if(triggerCategory && val.catClosed == true) {
            _children.add(_buildLevelColumn(level));
            if(isVerticalLvl)
              _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0] + " C"));
          }
          if(!triggerCategory) {
            _children.add(_buildLevelColumn(level));
            if(isVerticalLvl)
              _childrenAdd.add(_buildAgeColumn(level, buttonTxt: ageValues[0]));
          }
        });
      }

      if(isVerticalLvl) {
        _levelMap[level]?.forEach((key2, val) {
          List<String> ageValues = key2.split(" ");
          if (triggerCategory) {
            [
              {"op": "O", "catOC": val.catOpen},
              {"op": "C", "catOC": val.catClosed}
            ].forEach((_categ) {
              if (_categ["catOC"]) {
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
                  level + " " + ageValues[0],
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
              level,
              style: new TextStyle(
                  fontSize: 15.0,
                  fontFamily: "Montserrat-Light"
              )
          ),
        ));
      }
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
                    width: isVerticalLvl ? 140.0 : 0.0,
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
                    isVerticalLvl ? "LEVEL - AGE" : "AGE",
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