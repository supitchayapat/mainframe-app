import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/widget/MFAppBar.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'event_details.dart' as details;

class event_result extends StatefulWidget {
  @override
  _event_resultState createState() => new _event_resultState();
}

class _event_resultState extends State<event_result> {
  final Color headerBg= new Color(0xFF212D44);
  final TextStyle fontsize = new TextStyle(fontSize: 15.0);
  final formatterOut = new DateFormat("MMM d");
  String resultTitle;
  String eventTitle = "EVENT TITLE";
  String eventRange = "";
  var heatResult;

  @override
  void initState() {
    super.initState();
    resultTitle = "Event Results";

    if(details.selectedParticipant != null) {
      resultTitle = "${details.selectedParticipant.coupleName}";
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

    if(details.heatResult != null) {
      heatResult = details.heatResult;
    }

    //print("${details.selectedParticipant}");
  }

  List<Widget> generateResults() {
    List<Widget> _children = [];
    
    if(heatResult == null || heatResult?.heats?.length <= 0) {
      _children.add(new Container(child: new Text("No Results")));
    }
    else {
      int itemCount = 1;
      for(var heatItem in heatResult.heats) {
        List<Widget> _childrenTemp = [];
        List _headerTexts = [];
        List _markTexts = [];

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
                (details.selectedParticipant != null) ? new InkWell(
                  onTap: () {
                    showDialogResult(context, "Heat Result", headerItems: _headerTexts, markItems: _markTexts);
                  },
                  child: new Container(
                    child: new Icon(Icons.info),
                  ),
                ) : new Container()
              ],
            ),
          ),
        );

        if(heatItem.subHeats != null && heatItem.subHeats.length > 0) {
          for(var subHeatItem in heatItem.subHeats){
            if(subHeatItem.result != null && subHeatItem.result.marks != null
              && subHeatItem.result.marks.length > 0) {
              _headerTexts = [];
              _headerTexts.addAll(subHeatItem.result.scoreHeaders);

              for(var markItem in  subHeatItem.result.marks){
                var contestant = markItem.contestant;
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
                if(details.selectedParticipant != null
                    && details.selectedParticipant.key != contestant.coupleKey) {
                  continue;
                }
                else {
                  if(details.selectedParticipant != null && markItem.texts != null) {
                    _markTexts = [];
                    _markTexts.addAll(markItem.texts);
                  }
                  _children.addAll(_childrenTemp);
                }

              }
            }
          }
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
    _children.addAll(generateResults());

    return new Scaffold(
      appBar: new MFAppBar(resultTitle, context),
      body:new ListView(
        children: _children,
      ),
    );
  }
}