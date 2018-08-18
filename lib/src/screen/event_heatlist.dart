import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'event_details.dart' as details;

class event_heatlist extends StatefulWidget {
  @override
  _event_heatlistState createState() => new _event_heatlistState();
}

class _event_heatlistState extends State<event_heatlist> {
  final Color headerBg= new Color(0xFF212D44);
  final TextStyle fontsize = new TextStyle(fontSize: 15.0);
  final formatterOut = new DateFormat("MMM d");
  String heatListTitle;
  String eventTitle = "EVENT TITLE";
  String eventRange = "";
  var heatList;

  @override
  void initState() {
    super.initState();
    heatListTitle = "Event Heats";

    if(details.selectedParticipant != null) {
      heatListTitle = "${details.selectedParticipant.coupleName}";
    }

    if(details.eventItem != null) {
      eventTitle = details.eventItem.eventTitle;
      //eventRange = eventItem.dateRange;
      if(details.eventItem.dateStart == details.eventItem.dateStop) {
        eventRange = "${formatterOut.format(details.eventItem.dateStart)}";
      } else {
        eventRange = "${formatterOut.format(details.eventItem.dateStart)} - ${formatterOut.format(details.eventItem.dateStop)}";
      }
    }

    if(details.heatList != null) {
      heatList = details.heatList;
    }

    //print("${details.selectedParticipant}");
  }

  List<Widget> generateHeatList() {
    List<Widget> _children = [];
    
    if(heatList == null || heatList?.heats?.length <= 0) {
      _children.add(new Container(child: new Text("No Heat List")));
    }
    else {
      int itemCount = 1;
      for(var heatItem in heatList.heats) {
        List<Widget> _childrenTemp = [];

        _childrenTemp.add(
          new Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            color: (itemCount % 2 > 0 || details.selectedParticipant == null) ? headerBg : Colors.transparent,
            constraints: new BoxConstraints(minHeight: 40.0),
            child: new Row(
              children: <Widget>[
                new Container(
                  child: new Text(heatItem.time, style: fontsize),
                ),
                new Text(" - ", style: new TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0)),
                new Flexible(
                    child: new Container(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: new Text(
                          "${heatItem.name}: ${heatItem.desc}",
                          style: fontsize, overflow: TextOverflow.fade),
                    )
                ),
                /*(details.selectedParticipant != null) ? new InkWell(
                  onTap: () {
                    showDialogResult(context, "Heat Result", headerItems: _headerTexts, markItems: _markTexts);
                  },
                  child: new Container(
                    child: new Icon(Icons.info),
                  ),
                ) : new Container()*/
              ],
            ),
          ),
        );

        if(heatItem?.subHeats != null && heatItem?.subHeats?.length > 0) {
          //print(heatItem.subHeats.length);
          heatItem.subHeats.forEach((subHeatItem){
            //print(subHeatItem.entries);
            if(subHeatItem.entries != null && subHeatItem.entries.length > 0) {

              //print(subHeatItem);
              for(var contestantItem in  subHeatItem.entries){
                var contestant = contestantItem.contestant;
                String contestantName = "";

                // if heat couple contestant
                if(contestant?.persons != null && contestant.persons.length > 0) {
                  contestant.persons.forEach((personItem){
                    if(!contestantName.isEmpty) {
                      contestantName += " - ${personItem.firstName} ${personItem.lastName}";
                    }
                    else {
                      contestantName = "${personItem.firstName} ${personItem.lastName}";
                    }
                  });

                  if(details.selectedParticipant == null) {
                    _childrenTemp.add(
                      new Container(
                          padding: const EdgeInsets.only(left: 40.0, top: 5.0, bottom: 5.0),
                          child: new Row(
                            children: <Widget>[
                              new Container(
                                width: 48.0,
                                padding: const EdgeInsets.only(right: 20.0),
                                child: new Text("", style: fontsize),
                              ),
                              new Flexible(child: new Text(contestantName, style: fontsize))
                            ],
                          )
                      ),
                    );
                  }
                }

                // check if has selected participant
                // check if selected participant is on display
                /*if(details.selectedParticipant != null
                    && details.selectedParticipant.key != contestant.coupleKey) {
                  continue;
                }
                else {
                  if(details.selectedParticipant != null && markItem.texts != null) {
                    _markTexts = [];
                    _markTexts.addAll(markItem.texts);
                  }
                  _children.addAll(_childrenTemp);
                }*/
                _children.addAll(_childrenTemp);

              }
            }
          });

          /*for(var subHeatItem in heatItem.subHeats){
          }*/
        }

        itemCount++;
      }
    }
    return _children;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [];
    _children.add(
      new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new ExactAssetImage("mainframe_assets/images/m7x5ba.jpg"),
              fit: BoxFit.cover,
            )
        ),
        child: new Container(
            alignment: Alignment.bottomLeft,
            width: 300.0,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Container(child: new Text(eventTitle, style: new TextStyle(fontSize: 22.0))),
                new Text("$eventRange ${details.eventItem.year}", style: new TextStyle(fontSize: 16.0, color: new Color(0xff00e5ff)))
              ],
            )
        ),
        height: 135.0,
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
      ),
    );
    _children.addAll(generateHeatList());

    return new Scaffold(
      appBar: new MFAppBar(heatListTitle, context),
      body:new ListView(
        children: _children,
      ),
    );
  }
}