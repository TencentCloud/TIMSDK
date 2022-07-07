class OurSchoolMember {
  final String imId;
  final String name;
  final String avatar;
  final int uid;

  OurSchoolMember({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.imId,
  });
}

class OurSchoolChatProvider {
  final OurSchoolMember? Function(String? imId) getMemberByIMId;

  OurSchoolChatProvider({
    required this.getMemberByIMId,
  });
}
