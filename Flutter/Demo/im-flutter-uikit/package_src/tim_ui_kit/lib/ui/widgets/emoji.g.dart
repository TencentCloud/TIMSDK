// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emoji _$EmojiFromJson(Map<String, dynamic> json) {
  return Emoji(
    json['name'] as String,
    json['unicode'] as int,
  );
}

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
      'name': instance.name,
      'unicode': instance.unicode,
    };
