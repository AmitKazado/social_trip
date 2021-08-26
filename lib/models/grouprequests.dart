class GroupPendingModel {
  dynamic groupname;
  dynamic groupid;
  dynamic status;
  dynamic username;
  dynamic userid;

  GroupPendingModel({
    this.groupid,
    this.username,
    this.userid,
    this.status,
    this.groupname,
  });

  GroupPendingModel.fromMap(Map<dynamic, dynamic> json) {
    groupid = json["groupid"];
    username = json["username"];
    userid = json["userid"];
    groupname = json["groupname"];
    status = json["status"];
  }
  // Map<String, dynamic> toJson() => {
  //       "tripid": tripid,
  //       "groupid": groupid,
  //       "tripname": tripname,
  //       "username": groupid,
  //     };
}
