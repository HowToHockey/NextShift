import 'dart:js_util';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nextshift/Request.dart';
import 'package:nextshift/models/RequestType.dart';
import 'models/Item.dart';
import 'widgets/ListItem.dart';
import 'widgets/Heading.dart';
import 'Login.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // Static variables
  final user = FirebaseAuth.instance.currentUser;

  // State variables
  bool speedDialOpen = false;
  bool initialized = false;
  RequestType typeFilter;
  String platformFilter;
  bool showCompleted = false;

  @override
  void initState() {
    setState(() {
      initialized = true;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMobile();
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      appBar: AppBar(
        centerTitle: true,
        leading: Container(
          padding: EdgeInsets.all(5),
          child: Image(
            height: 40,
            image: AssetImage(
              'assets/images/logos/hth_logo_red.png',
            ),
          ),
        ),
        title: Heading(
          text: "Next Shift",
          size: 30,
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(10),
            child: Image(
              height: 30,
              image: AssetImage(
                'assets/images/logos/thepond_white_rgb.png',
              ),
            ),
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(top: 15),
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        padding: EdgeInsets.all(0.0),
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        color: Colors.transparent,
                        child: IconButton(
                          alignment: Alignment.center,
                          tooltip: "View Completed",
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              showCompleted = !showCompleted;
                            });
                          },
                          icon: Icon(
                            Icons.history,
                            color: showCompleted ? Colors.green : Colors.black54,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.end,
                        children: [
                          typeFilter != null || platformFilter != null
                              ? Container(
                                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                  child: Icon(
                                    Icons.filter_list,
                                    size: 14,
                                    color: Colors.black45,
                                  ),
                                )
                              : Column(),
                          typeFilter != null
                              ? Container(
                                  margin: EdgeInsets.only(right: 10, bottom: 5),
                                  padding: EdgeInsets.only(left: 10),
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${typeFilter.descriptor}",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ClipOval(
                                        child: Container(
                                          color: Colors.transparent,
                                          child: IconButton(
                                            tooltip: "Remove filter",
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            onPressed: () {
                                              setState(() {
                                                typeFilter = null;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Theme.of(context).accentColor,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(),
                          platformFilter != null
                              ? Container(
                                  margin: EdgeInsets.only(right: 10, bottom: 5),
                                  padding: EdgeInsets.only(left: 10),
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "$platformFilter",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ClipOval(
                                        child: Container(
                                          color: Colors.transparent,
                                          child: IconButton(
                                            tooltip: "Remove filter",
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            onPressed: () {
                                              setState(() {
                                                platformFilter = null;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Theme.of(context).accentColor,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildItems(context)
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: initialized ? _buildSpeedDial() : null,
    );
  }

  // Build the list of items
  Widget _buildItems(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').orderBy('votes', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return _buildItemList(context, snapshot.data.docs);
        });
  }

  Widget _buildItemList(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<ListItem> items = snapshot
        .map((data) => ListItem(
              item: Item.fromSnapshot(data),
              filterBy: filterBy,
            ))
        .toList();

    // Put the items that are up next first
    items = items.where((element) => element.item.upNext).toList() + items.where((e) => !e.item.upNext).toList();

    items = items.where((element) => element.item.complete == showCompleted).toList();

    if (typeFilter != null) {
      items = items.where((element) => element.item.type.name == typeFilter.name).toList();
    }

    if (platformFilter != null) {
      items = items.where((element) => element.item.platform == platformFilter).toList();
    }

    return items.length > 0
        ? Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 20.0),
              children: items,
            ),
          )
        : Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 160,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "There are no items to display",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                (showCompleted || typeFilter != null || platformFilter != null)
                    ? Container(
                        margin: EdgeInsets.only(top: 15),
                        child: FlatButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () => setState(() {
                            showCompleted = false;
                            typeFilter = null;
                            platformFilter = null;
                          }),
                          child: Text("Clear Filters"),
                        ),
                      )
                    : Container(),
              ],
            ),
          );
  }

  SpeedDial _buildSpeedDial() {
    return SpeedDial(
      backgroundColor: !speedDialOpen ? Theme.of(context).accentColor : Theme.of(context).primaryColor,
      child: !speedDialOpen
          ? Icon(Icons.add)
          : Icon(
              Icons.arrow_drop_down,
              size: 34,
            ),
      onOpen: () {
        setState(() {
          speedDialOpen = !speedDialOpen;
        });
      },
      onClose: () {
        setState(() {
          speedDialOpen = !speedDialOpen;
        });
      },
      visible: true,
      curve: Curves.easeInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.bug_report, color: Colors.white),
          backgroundColor: Theme.of(context).accentColor,
          foregroundColor: Theme.of(context).accentColor,
          onTap: () {
            newRequest("Bug");
          },
          label: 'Report a bug',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 18,
          ),
          labelBackgroundColor: Colors.white,
        ),
        SpeedDialChild(
          child: Icon(Icons.lightbulb, color: Colors.white),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.orange,
          onTap: () {
            newRequest("Idea");
          },
          label: 'I have an idea',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 18,
          ),
          labelBackgroundColor: Colors.white,
        ),
        SpeedDialChild(
          child: Icon(Icons.movie, color: Colors.white),
          backgroundColor: Colors.green,
          foregroundColor: Colors.green,
          onTap: () {
            newRequest("Content Request");
          },
          label: 'I would like to learn more about..',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 18,
          ),
          labelBackgroundColor: Colors.white,
        ),
        SpeedDialChild(
          child: Icon(Icons.list_alt, color: Colors.white),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.blue,
          onTap: () {
            newRequest("Feature Request");
          },
          label: 'I would like to be able to..',
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 18,
          ),
          labelBackgroundColor: Colors.white,
        ),
      ],
    );
  }

  void newRequest(String type) {
    if (user == null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Login();
            },
          ),
        );
      });
    } else {
      RequestType requestType = RequestType(name: type);

      if (type == "Bug") {
        requestType.color = Theme.of(context).accentColor;
        requestType.descriptor = "Report a bug";
        requestType.icon = Icons.bug_report;
      } else if (type == "Idea") {
        requestType.color = Colors.orange;
        requestType.descriptor = "I have an idea";
        requestType.icon = Icons.lightbulb;
      } else if (type == "Content Request") {
        requestType.color = Colors.green;
        requestType.descriptor = "I would like to learn about..";
        requestType.icon = Icons.movie;
      } else if (type == "Feature Request") {
        requestType.color = Colors.blue;
        requestType.descriptor = "I would like to be able to..";
        requestType.icon = Icons.list_alt;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return Request(type: requestType);
          },
        ),
      );
    }
  }

  void filterBy(RequestType type, String platform) {
    setState(() {
      if (type != null) {
        typeFilter = type;
      }

      if (platform != null) {
        platformFilter = platform;
      }
    });
  }

  bool includeType(RequestType type) {
    return (type == null || type.name == typeFilter.name);
  }
}
