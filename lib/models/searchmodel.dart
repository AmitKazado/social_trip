class SearchModel {
  dynamic admin;
  dynamic groupid;
  dynamic groupName;
  dynamic username;
  dynamic userid;
  dynamic image;
  dynamic location;

  SearchModel(
      {this.admin,
      this.groupid,
      this.groupName,
      this.username,
      this.userid,
      this.image,
      this.location});

  SearchModel.fromMap(Map<dynamic, dynamic> json) {
    admin = json["admin"];
    groupid = json["groupId"];
    groupName = json["groupName"];
    username = json["username"];
    userid = json["userid"];
    image = json["image"];
    location = json["location"];
  }

}
