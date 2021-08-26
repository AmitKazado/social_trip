class PendingModel {
  dynamic tripid;
  dynamic groupid;
  dynamic tripname;
  dynamic username;
  dynamic userid;
  dynamic image;
  dynamic location;

  PendingModel(
      {this.tripid,
      this.groupid,
      this.tripname,
      this.username,
      this.userid,
      this.image,
      this.location});

  PendingModel.fromMap(Map<dynamic, dynamic> json) {
    tripid = json["tripid"];
    groupid = json["groupid"];
    tripname = json["tripname"];
    username = json["username"];
    userid = json["userid"];
    image = json["image"];
    location = json["location"];
  }
  // Map<String, dynamic> toJson() => {
  //       "tripid": tripid,
  //       "groupid": groupid,
  //       "tripname": tripname,
  //       "username": groupid,
  //     };
}
