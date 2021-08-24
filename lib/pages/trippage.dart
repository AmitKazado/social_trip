import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_trip/helper/helper_functions.dart';
import 'package:social_trip/models/tripdetails.dart';
import 'package:social_trip/pages/chat_page.dart';
import 'package:social_trip/pages/notifications.dart';
import 'package:social_trip/services/auth_service.dart';
import 'package:social_trip/services/database_service.dart';
import 'package:social_trip/widgets/group_tile.dart';

import 'addatrip.dart';
import 'grouprequests.dart';
import 'home_page.dart';

class TripPage extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;
  final String groupdescription;

  TripPage(
      {this.groupId, this.userName, this.groupName, this.groupdescription});
  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream trips;
  dynamic usertype;
  Stream travelertrips;
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });

    DatabaseService(uid: _user.uid).getUserdetails().then((value) {
      // print(snapshots);
      setState(() {
        usertype = value['usertype'];
        //groupdescription = value['description'];
      });
    });
    DatabaseService(uid: _user.uid).getUserTrip().then((snapshots) {
      // print(snapshots);
      setState(() {
        trips = snapshots;
      });
    });
    DatabaseService().gettrips2(widget.groupId).then((snapshots) {
      // print(snapshots);
      setState(() {
        travelertrips = snapshots;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
    // tripList();
    getstatus();
  }

  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  List listoftrips = ['Hunza', 'Chitrla', 'Skardu'];

  List<String> status = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];
  @override
  Widget build(BuildContext context) {
    print("the user dtype is $usertype");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1b6535),
        title: Text(widget.groupName == null ? "" : widget.groupName),
        centerTitle: true,
        actions: [
          usertype == "Manager"
              ? IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  icon: Icon(Icons.person,
                      color: Colors.white, size: 25.0),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Grouprequests(
                              groupId: widget.groupId,
                              groupName: widget.groupName,
                              userName: widget.userName,
                            )));
                  })
              : Container(),
          usertype == "Manager"
              ? IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  icon: Icon(Icons.notifications,
                      color: Colors.white, size: 25.0),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Notifications(
                              groupId: widget.groupId,
                              groupName: widget.groupName,
                              userName: widget.userName,
                            )));
                  })
              : Container(),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/background.jfif',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      //   height: 100,
                      width: 200,
                      child: Card(
                          elevation: 0.5,
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Welcome to",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                                Text(
                                  widget.groupName == null
                                      ? ""
                                      : widget.groupName,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(widget.groupdescription == null
                                    ? ""
                                    : widget.groupdescription),
                                usertype == "Manager"
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: InkWell(
                                          onTap: () {},
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Color(0xffa8c66c),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 5.0),
                                            child: Text('Edit',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Container(
                        //    height: 100,
                        width: MediaQuery.of(context).size.width - 30,
                        child: Card(
                            elevation: 0.5,
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "List of Trips",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18),
                                  ),
                                  //  travelertripList(),
                                  usertype == "Manager"
                                      ? managertripList()
                                      : travelertripList(),
                                  usertype == "Manager"
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddaTrip(
                                                          groupid:
                                                              widget.groupId,
                                                          groupname:
                                                              widget.groupName,
                                                          username:
                                                              widget.userName,
                                                        )));
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: InkWell(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Color(0xffa8c66c),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 5.0),
                                                child: Text('Add new Trip',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController groupname;
  TextEditingController groupdesc;
  void _popupDialog(BuildContext context) {
    groupname = TextEditingController(text: widget.groupName);
    groupdesc = TextEditingController(text: widget.groupdescription);

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
        child: Text("Update"),
        onPressed: () async {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid).updateGroup(
                oldgroupid:widget.groupId,
                oldgroupname:widget.groupName,
                userName: val,
                groupName: groupname.text,
                description: groupdesc.text,
                groupid: widget.groupId);
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });

    AlertDialog alert = AlertDialog(
      title: Text("Change Group Name and Description"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: groupname,
                decoration: InputDecoration(hintText: 'Name of Group'),
                style: TextStyle(
                    fontSize: 15.0, height: 2.0, color: Colors.black)),
            TextField(
                controller: groupdesc,
                decoration: InputDecoration(hintText: 'description of group'),
                onChanged: (val) {},
                style: TextStyle(
                    fontSize: 15.0, height: 2.0, color: Colors.black)),
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
  String _destructureId(String res) {
    // print(res.substring(0, res.indexOf('_')));
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    // print(res.substring(res.indexOf('_') + 1));
    return res.substring(res.indexOf('_') + 1);
  }

  List<TripModel> triplist = new List();

  TripModel tripmodel = new TripModel();
  dynamic i = 0;
  List<bool> isjoinedtrip = [
    false,
    false,
    false,
    false,
    false,
  ];
  Widget managertripList() {
    print("im here");
    return StreamBuilder(
      stream: travelertrips,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents != null) {
            // print(snapshot.data['groups'].length);
            if (snapshot.data.documents.length != 0) {
              return ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    snapshot.data.documents.forEach((doc) {
                      tripmodel = TripModel.fromMap(doc.data);
                      triplist.add(tripmodel);

                      print("im here${triplist[0].tripid}");
                      print(doc);
                    });

                    int reqIndex = snapshot.data.documents.length - index - 1;
                    return ListTile(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                        tripid: triplist[index].tripid,
                                        userName: _userName,
                                        groupId: triplist[index].groupid,
                                        groupName: triplist[index].tripname,
                                      )));
                        },
                        leading: CircleAvatar(
                          backgroundImage: triplist[index].image == null
                              ? NetworkImage(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/600px-No_image_available.svg.png")
                              : NetworkImage(triplist[index].image),
                        ),
                        title: Text(
                          _destructureName(triplist[index].tripname),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          snapshot.data.documents[index]['location'],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ));
                  });
            } else {
              return Container(
                child: Text('No Trips available'),
              );
            }
          } else {
            return Container(
              child: Text('No Trips available'),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  var data;
  var statuss;
  var pendingdata;
  var index;
  bool isloading = false;
  getstatus() async {
    isloading = true;

    print("the status are ${_user.uid}");

    await DatabaseService()
        .getpendingrequestsdoc2(widget.groupId, _user.uid)
        .then((value) {
      if (value.documents.length != 0) {
        print("the length is ${value.documents.length}");
        for (int i = 0; i < value.documents.length; i++) {
          print("the index is $i");
          setState(() {
            data = value.documents[i]['status'];
            if (data == 'pending') {
              print("im here first");
              statuss = 'pending';
              if (value.documents[i]['index'] - 1 < 0) {
                status.insert(value.documents[i]['index'], '2');
              } else if (i == 3 || i == 4 || i == 5) {
                status.insert(value.documents[i]['index'] - 1, '2');
              } else {
                status.insert(value.documents[i]['index'], '2');
              }

              print("the status are $status");
            } else if (data == 'joined') {
              statuss = 'Joined';
              if (value.documents[i]['index'] - 1 < 0) {
                //  status.insert(value.documents[i]['index'], '1');
              } else {
                status.insert(value.documents[i]['index'] - 1, '1');
              }
              print("the status are $status");
            } else {
              statuss = 'Join';
              if (value.documents[i]['index'] - 1 < 0) {
              } else {
                status.insert(value.documents[i]['index'] - 1, '0');
              }
              print("the status are $status");
            }
          });
        }
      }
    });
    setState(() {
      isloading = false;
    });
    print("the status are $status");
  }

  bool deleterequest = false;
  Widget travelertripList() {
    print("im here traveler");
    return StreamBuilder(
      stream: travelertrips,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents != null) {
            // print(snapshot.data['groups'].length);
            if (snapshot.data.documents.length != 0) {
              snapshot.data.documents.forEach((doc) {
                tripmodel = TripModel.fromMap(doc.data);
                triplist.add(tripmodel);

                print("im here${triplist[0].tripid}");
                print(doc);
              });
              return ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (i == 0) {
                      i++;
                      DatabaseService(uid: _user.uid)
                          .isUserJoinedTrip(triplist[index].tripid,
                              triplist[index].tripname, _userName)
                          .then((value) {
                        setState(() {
                          isjoinedtrip[index] = value;
                          i = 1;
                          print(isjoinedtrip);
                        });
                      });
                    }

                    int reqIndex = snapshot.data.documents.length - index - 1;
                    return isloading
                        ? Center(child: CircularProgressIndicator())
                        : ListTile(
                            onTap: () async {
                              await DatabaseService(uid: _user.uid)
                                  .isUserJoinedTrip(triplist[index].tripid,
                                      triplist[index].tripname, _userName)
                                  .then((value) {
                                setState(() {
                                  isjoinedtrip[index] = value;
                                  i = 1;
                                  print(isjoinedtrip);
                                });
                              });
                              isjoinedtrip[index]
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                                userName: _userName,
                                                groupId: triplist[index].tripid,
                                                groupName:
                                                    triplist[index].tripname,
                                              )))
                                  : Fluttertoast.showToast(
                                      msg: "Join the group first");
                            },
                            leading: CircleAvatar(
                              backgroundImage: triplist[index].image == null
                                  ? NetworkImage(
                                      "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/600px-No_image_available.svg.png")
                                  : NetworkImage(triplist[index].image),
                            ),

                            title: Text(
                              _destructureName(
                                  snapshot.data.documents[index]['tripname']),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            // subtitle: Text(
                            //     _destructureName(snapshot.data['trips'][reqIndex])),
                            trailing: status[index].isNotEmpty
                                ? InkWell(
                                    onTap: () async {
                                      print(
                                          "deleting ${widget.groupId + '_' + snapshot.data.documents[index]['tripId']}");
                                      await DatabaseService().deleterequests(
                                          triplist[index].tripid,
                                          widget.groupId,
                                          triplist[index].tripname,
                                          widget.userName,
                                          index,
                                          true,
                                          '');
                                      status = [];
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TripPage(
                                                    groupId: widget.groupId,
                                                    groupName: widget.groupName,
                                                    groupdescription:
                                                        widget.groupdescription,
                                                  )));

                                      // getstatus(
                                      //     snapshot.data.documents.length,
                                      //     snapshot.data.documents[index]
                                      //         ['tripId']);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.red,
                                          border: Border.all(
                                              color: Colors.white, width: 1.0)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 5.0),
                                      child: Text('Cancel',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ))
                                : InkWell(
                                    onTap: () async {
                                      await DatabaseService()
                                          .getpendingrequestsdoc(
                                        widget.groupId,
                                      )
                                          .then((value) {
                                        if (value.documents.length != 0) {}
                                      });
                                      print(
                                          "the id is ${triplist[index].tripid}");
                                      if (isjoinedtrip[index] == false) {
                                        print("im in pending");
                                        await DatabaseService(uid: _user.uid)
                                            .pendingrequests(
                                                triplist[index].tripid,
                                                widget.groupId,
                                                triplist[index].tripname,
                                                widget.userName,
                                                index,
                                                isjoinedtrip[index],
                                                _userName,
                                                widget.groupName);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => TripPage(
                                                      groupId: widget.groupId,
                                                      groupName:
                                                          widget.groupName,
                                                      groupdescription: widget
                                                          .groupdescription,
                                                    )));
                                        if (isjoinedtrip[index]) {
                                          // setState(() {
                                          //   isjoinedtrip[index] =
                                          ////       isjoinedtrip[index];
                                          //   deleterequest = false;
                                          //   i = 0;
                                          //   status.insert(index, '0');
                                          // });
                                          // } else {
                                          //   setState(() {
                                          //     status.insert(index, '2');
                                          //   });
                                        }
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Color(0xff1b6535),
                                          border: Border.all(
                                              color: Colors.white, width: 1.0)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 5.0),
                                      child: isjoinedtrip[index]
                                          ? Text("Joined",
                                              style: TextStyle(
                                                  color: Colors.white))
                                          : Text(
                                              '${status[index] == "2" ? "Pending" : status[index] == "1" ? "Joined" : 'Join'}',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                    )),
                          );
                  });
            } else {
              return Container(
                child: Text('No Trips available'),
              );
            }
          } else {
            return Container(
              child: Text('No Trips available'),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
