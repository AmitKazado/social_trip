class TripModel {
  dynamic tripid;
  dynamic groupid;
  dynamic tripname;
  dynamic username;
  dynamic userid;
  dynamic image;
  dynamic location;

  TripModel(
      {this.tripid,
      this.groupid,
      this.tripname,
      this.username,
      this.userid,
      this.image,
      this.location});

  TripModel.fromMap(Map<dynamic, dynamic> json) {
    tripid = json["tripId"];
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
