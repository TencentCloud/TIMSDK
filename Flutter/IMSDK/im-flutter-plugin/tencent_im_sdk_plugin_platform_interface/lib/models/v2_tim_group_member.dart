class V2TimGroupMember {
  late String userID;
  late int role;
  V2TimGroupMember({required this.userID, required this.role});
  fromJson(String userID, int role) {
    this.userID = userID;
    this.role = role;
  }

  Map<dynamic, dynamic> toJson() {
    return {"userID": userID, "role": role};
  }
}
