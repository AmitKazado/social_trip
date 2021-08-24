import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_trip/models/locationmodel.dart';
import 'package:social_trip/services/database_service.dart';
import 'package:social_trip/widgets/message_tile.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class ChatPage extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;
  final String tripid;

  ChatPage({this.groupId, this.userName, this.groupName, this.tripid});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot> _chats;
  TextEditingController messageEditingController = new TextEditingController();
  dynamic usertype;
  getusertype() async {
    var _user = await FirebaseAuth.instance.currentUser;

    await DatabaseService(uid: _user.uid).getUserdetails().then((value) {
      // print(snapshots);
      setState(() {
        usertype = value['usertype'];
        //groupdescription = value['description'];
      });
    });
    getuser(widget.tripid);
    if (usertype == "Manager") {
      DatabaseService().getChats(widget.tripid).then((val) {
        // print(val);
        setState(() {
          _chats = val;
        });
      });
    } else {
      DatabaseService().getChats(widget.groupId).then((val) {
        // print(val);
        setState(() {
          _chats = val;
        });
      });
    }
  }

  bool blocking = false;
  blockuser(tripid) async {
    setState(() {
      blocking = true;
    });
    await getuser(tripid);
    if (tripid == blockeduser) {
      jobskill_query.documents.forEach((element) {
        element.reference.delete();
      });
      Fluttertoast.showToast(msg: "Everyone can chat now");
      setState(() {
        blocking = false;
        mutetext = 'Mute';
        blockeduser = '';
      });
    } else {
      await FirebaseFirestore.instance
          .collection('blockedusers')
          .add({"tripid": tripid});

      Fluttertoast.showToast(msg: "Only admin can chat");
      setState(() {
        blocking = false;
        mutetext = 'Muted';
      });
    }
    // await Firestore.instance
    //     .collection('blockedusers')
    //     .where("name", isEqualTo: sender)
    //     .getDocuments()
    //     .then((value) {
    //   if (value.documents[index]['name'] == sender) {
    //   } else {
    //     Firestore.instance.collection('blockedusers').add({"name": sender});
    //   }
    // });
  }

  var jobskill_query;
  dynamic blockeduser;
  dynamic mutetext = 'Mute';
  getuser(tripid) async {
    jobskill_query = await FirebaseFirestore.instance
        .collection('blockedusers')
        .where("tripid", isEqualTo: tripid)
        .get();

    setState(() {
      if (jobskill_query.documents.length == 0) {
        print("nulll");
        mutetext = 'Mute';
      } else {
        blockeduser = jobskill_query.documents[0]['tripid'];
        print(blockeduser);
        mutetext = 'Muted';
      }
      i = 1;
    });
  }

  int i = 0;
  Widget _chatMessages() {
    print("theuser ane is ${widget.userName}");
    return StreamBuilder(
      stream: _chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.only(bottom: 68.0),
                child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      i == 0 ? getuser(widget.groupId) : print("haha");
                      return InkWell(
                        onTap: () {
                          // usertype == "Manager"
                          //     ? _popupDialog(
                          //         context,
                          //         snapshot.data.documents[index].data["sender"],
                          //         index,
                          //         widget.groupId)
                          //     : print("you cant");
                        },
                        child: MessageTile(
                          message:
                              snapshot.data.documents[index].data["message"],
                          sender: snapshot.data.documents[index].data["sender"],
                          sentByMe: widget.userName ==
                              snapshot.data.documents[index].data["sender"],
                        ),
                      );
                    }),
              )
            : Container();
      },
    );
  }

  _sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(
          usertype == "Manager" ? widget.tripid : widget.groupId,
          chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  _sendMessage2(message) {
    Map<String, dynamic> chatMessageMap = {
      "message": message,
      "sender": widget.userName,
      'time': DateTime.now().millisecondsSinceEpoch,
    };

    DatabaseService().sendMessage(widget.groupId, chatMessageMap);

    setState(() {
      messageEditingController.text = "";
    });
  }

  @override
  void initState() {
    super.initState();

    getusertype();
  }

  var address;
  Location _locationTracker = Location();
  bool isfetching = false;
  LocationModel locmodel = new LocationModel();
  getlocation() async {
    if (usertype == "Manager") {
      _sendMessage();
    } else {
      setState(() {
        isfetching = true;
      });
      var location = await _locationTracker.getLocation();

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          location.latitude, location.longitude);
      print(placemarks[0].name);

      setState(() {
        address = "${placemarks[0].name} ${placemarks[0].subLocality} ";
        isfetching = false;
      });
      _sendMessage2("Help me, My location is: $address");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xff1b6535),
        elevation: 0.0,
        actions: [
          usertype == "Manager"
              ? InkWell(
                  onTap: () {
                    blockuser(widget.tripid);
                  },
                  child: Chip(
                      label: blocking ? Text('Plz Wait') : Text('$mutetext')))
              : Container()
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Image.asset(
              'assets/background.jfif',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
            _chatMessages(),
            // Container(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                color: Colors.grey[700],
                child: Row(
                  children: <Widget>[
                    blockeduser != widget.groupId || usertype == "Manager"
                        ? Expanded(
                            child: TextField(
                              controller: messageEditingController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText: "Send a message ...",
                                  hintStyle: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none),
                            ),
                          )
                        : Expanded(
                            child: TextField(
                              controller: messageEditingController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText:
                                      "Only admin can send message You can only send SOS",
                                  hintStyle: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 1,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                    SizedBox(width: 12.0),
                    GestureDetector(
                        onTap: () {
                          blockeduser != widget.groupId
                              ? _sendMessage()
                              : getlocation();
                        },
                        child: blockeduser != widget.groupId ||
                                usertype == "Manager"
                            ? Container(
                                height: 50.0,
                                width: 50.0,
                                decoration: BoxDecoration(
                                    color: Color(0xffa8c66c),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Center(
                                    child:
                                        Icon(Icons.send, color: Colors.white)),
                              )
                            : Container(
                                height: 50.0,
                                width: 50.0,
                                decoration: BoxDecoration(
                                    color: Color(0xffa8c66c),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Center(
                                    child: isfetching
                                        ? CircularProgressIndicator(
                                            backgroundColor: Colors.orange)
                                        : Image.asset(
                                            'assets/sosalert.png',
                                            fit: BoxFit.fill,
                                          )),
                              ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _popupDialog(BuildContext context, sender, index, groupid) {
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Yes"),
      onPressed: () async {
        blockuser(widget.groupId);
        print("yes");
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Are you Sure?"),
      content: Text('You want to block user'),
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
}
