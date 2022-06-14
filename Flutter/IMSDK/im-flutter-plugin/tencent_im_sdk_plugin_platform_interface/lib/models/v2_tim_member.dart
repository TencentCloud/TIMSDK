/// V2TimMember
///
/// {@category Models}
///
class V2TimMember {
  late String userId;
  late String role;

  V2TimMember({
    required this.userId,
    required this.role,
  });

  V2TimMember.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['role'] = role;
    return data;
  }
}

// {
//   "userId":"",
//   "role":""
// }
