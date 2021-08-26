import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_trip/helper/helper_functions.dart';
import 'package:social_trip/pages/authenticate_page.dart';
import 'package:social_trip/pages/chat_page.dart';
import 'package:social_trip/pages/notifications.dart';
import 'package:social_trip/pages/profile_page.dart';
import 'package:social_trip/pages/search_page.dart';
import 'package:social_trip/services/auth_service.dart';
import 'package:social_trip/services/database_service.dart';
import 'package:social_trip/widgets/group_tile.dart';

import 'drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // data
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream _groups;
  Stream pendinggroups;

  // initState
  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  // widgets
  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            usertype != 'Traveler'
                ? GestureDetector(
                    onTap: () {
                      _popupDialog(context);
                    },
                    child: Icon(Icons.add_circle,
                        color: Colors.grey[700], size: 75.0))
                : Container(),
            SizedBox(height: 20.0),
            Text(
              usertype == 'Traveler'
                  ? "You've not joined any group, tap on the 'Search' icon to Search the group"
                  : "You've not joined any group, tap on the 'add' icon to create a group or search for groups by tapping on the search button below.",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  Widget groupsList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.get('groups') != null) {
            // print(snapshot.data['groups'].length);
            if (snapshot.data.get('groups').length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data.get('groups').length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    int reqIndex =
                        snapshot.data.get('groups').length - index - 1;
                    return GroupTile(
                        usertype: usertype,
                        userName: snapshot.data.get('fullName'),
                    //  desc: descr,
                        groupId: _destructureId(
                            snapshot.data.get('groups')[reqIndex]),
                        groupName: _destructureName(
                            snapshot.data.get('groups')[reqIndex]));
                  });
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget pendinggroupsList() {
    return StreamBuilder(
      stream: pendinggroups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.docs != null) {
            // print(snapshot.data['groups'].length);
            if (snapshot.data.docs.length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    //   int reqIndex = snapshot.data.length - index - 1;
                    return GroupTile(
                        status: snapshot.data.docs[index]['status'],
                        usertype: usertype,
                        userName: snapshot.data.docs[index]['username'],
                        //  desc: snapshot.data['groupdescription'],
                        groupId: snapshot.data.docs[index]['groupid'],
                        groupName: snapshot.data.docs[index]['groupname']);
                  });
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  String usertype = '';
  String _groupdesc = '';
  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    DatabaseService(uid: _user.uid).getUserGroups().then((snapshots) {
      // print(snapshots);
      setState(() {
        _groups = snapshots;
      });
    });

    DatabaseService(uid: _user.uid).getpendingGroups().then((snapshots) {
      // print(snapshots);
      setState(() {
        pendinggroups = snapshots;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
    DatabaseService(uid: _user.uid).getUserdetails().then((value) {
      // print(snapshots);
      setState(() {
        usertype = value['usertype'];
        //groupdescription = value['description'];
      });
    });
  }

  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }

  TextEditingController groupdesc = new TextEditingController();
  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Create"),
      onPressed: () async {
        if (_groupName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid)
                .createGroup(val, _groupName, groupdesc.text);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Create a group"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: InputDecoration(hintText: 'Name of Group'),
                onChanged: (val) {
                  _groupName = val;
                },
                style:
                    TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
            TextField(
                controller: groupdesc,
                decoration: InputDecoration(hintText: 'description of group'),
                onChanged: (val) {
                  _groupdesc = val;
                },
                style:
                    TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
          ],
        ),
      ),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Building the HomePage widget
  @override
  Widget build(BuildContext context) {
    // _showNotification();
    print(usertype);
    return Scaffold(
      appBar: AppBar(
        title: Text('Group',
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xff1b6535),
        elevation: 0.0,
        actions: <Widget>[
          usertype != "Manager"
              ? IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  icon: Icon(Icons.search, color: Colors.white, size: 25.0),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SearchPage()));
                  })
              : Container()
        ],
      ),
      drawer: CustomDrawer(
        email: _email,
        username: _userName,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/background.jfif',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          groupsList(),
          Positioned(
              top: 100,
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: pendinggroupsList())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          usertype != 'Traveler'
              ? _popupDialog(context)
              : Fluttertoast.showToast(msg: 'You cannot create a group');
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.0),
        backgroundColor: Colors.grey[700],
        elevation: 0.0,
      ),
    );
  }
}
