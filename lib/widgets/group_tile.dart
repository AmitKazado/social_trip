import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_trip/pages/chat_page.dart';
import 'package:social_trip/pages/home_page.dart';
import 'package:social_trip/pages/trippage.dart';
import 'package:social_trip/services/database_service.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  final String desc;
  final String usertype;
  final String status;

  GroupTile(
      {this.userName,
      this.groupId,
      this.groupName,
      this.desc,
      this.usertype,
      this.status});

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  void _popupDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Yes"),
      onPressed: () async {
        dynamic _user = await FirebaseAuth.instance.currentUser;

        print(widget.groupId);
        await DatabaseService(uid: _user.uid)
            .deletergroup(widget.groupId, widget.groupName, widget.usertype);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Are you Sure?"),
      content: Text('You want to leave group'),
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

  String groupdescription;

  getgroupdescriptionandname() async {
    await DatabaseService().getdescription(widget.groupId).then((value) {
      print(value['groupdescription']);
      setState(() {
        groupdescription = value['groupdescription'];
      });
      print("the desc is ${value['groupdescription']}");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getgroupdescriptionandname();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.status);
    return GestureDetector(
      onLongPress: () async {
        _popupDialog(context);
      },
      onTap: () {
        widget.status == "pending"
            ? Fluttertoast.showToast(
                msg: "Wait for admin to approve your request")
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TripPage(
                          groupId: widget.groupId,
                          userName: widget.userName,
                          groupName: widget.groupName,
                          groupdescription: groupdescription,
                        )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Color(0xffa8c66c),
              child: Text(widget.groupName.substring(0, 1).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ),
            title: Text(widget.groupName,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text("Join the conversation as ${widget.userName}",
                style: TextStyle(fontSize: 13.0, color: Colors.white)),
            trailing: widget.status == "pending"
                ? Chip(
                    backgroundColor: Colors.green,
                    label: Text("Pending"),
                  )
                : Chip(
                    backgroundColor: Colors.green,
                    label: Text("Joined"),
                  )),
      ),
    );
  }
}
