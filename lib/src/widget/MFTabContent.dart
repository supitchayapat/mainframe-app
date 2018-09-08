import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/src/util/AnalyticsUtil.dart';
import 'package:myapp/src/util/ScreenUtils.dart';
import 'package:myapp/MFGlobals.dart' as global;

class MFTabContent extends StatefulWidget {
  List contentItems;
  Map<String, dynamic> imgs;

  MFTabContent({this.contentItems, this.imgs});

  @override
  _MFTabContentState createState() => new _MFTabContentState();
}

class _MFTabContentState extends State<MFTabContent> {

  Future _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //throw 'Could not launch $url';
      showMainFrameDialog(context, "Website URL", "Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    double _hotelImgWidth = mediaQueryData.size.width;
    List<Widget> _hotelChildren = [];

    widget.contentItems.forEach((itm){
      //print("hotel img: ${itm.imgFilename}");
      _hotelChildren.add(
          new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              (itm?.imgFilename != null && widget.imgs.containsKey(itm.imgFilename)) ? new Container(
                alignment: Alignment.center,
                /*decoration: new BoxDecoration(
                    image: new DecorationImage(
                        //image: new ExactAssetImage("mainframe_assets/images/hotel_thumbnail.png"),
                        fit: BoxFit.fitHeight
                    ),
                    //color: Colors.amber
                ),*/
                width: _hotelImgWidth,
                height: 140.0,
                child: widget.imgs[itm.imgFilename],
              ) : Container(),
              (itm?.description != null) ? new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Wrap(
                        children: <Widget>[
                          new Text(itm?.description, style: new TextStyle(fontSize: 16.0))
                        ],
                      ),
                      (itm?.url != null && itm.url != "") ? new Wrap(
                        children: <Widget>[
                          new InkWell(
                            onTap: (){
                              global.messageLogs.add("Hotel Website link tapped. Navigate to ${itm?.url}");
                              AnalyticsUtil.sendAnalyticsEvent("navigate_web", params: {
                                'screen': 'event_details'
                              });
                              if(itm?.url != null) {
                                if((itm?.url).contains("http") || (itm?.url).contains("https"))
                                  _launchUrl(itm?.url);
                                else
                                  _launchUrl("http://${itm?.url}");
                              }
                            },
                            child: new Text("${itm?.url}", style: new TextStyle(fontSize: 14.0, color: new Color(0xff00e5ff), decoration: TextDecoration.underline)),
                          ),
                        ],
                      ) : new Container()
                    ],
                  )
              ) : new Container()
            ],
          )
      );
      _hotelChildren.add(new Padding(padding: const EdgeInsets.only(top: 20.0)));
    });

    return new Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _hotelChildren,
      ),
    );
  }
}