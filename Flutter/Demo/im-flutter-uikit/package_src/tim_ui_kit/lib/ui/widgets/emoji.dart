import 'package:json_annotation/json_annotation.dart';

part 'emoji.g.dart';

@JsonSerializable()
class Emoji extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'unicode')
  int unicode;

  Emoji(
    this.name,
    this.unicode,
  );

  factory Emoji.fromJson(Map<String, dynamic> srcJson) =>
      _$EmojiFromJson(srcJson);

  Map<String, dynamic> toJson() => _$EmojiToJson(this);
}
