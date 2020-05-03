import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

class MemeHeader {
  final LanguageTag originalLanguageTag;
  final List<LanguageTag> _targetLanguageTags;
  //final List<LanguageTag> _addedLanguageTags;

  MemeHeader(this.originalLanguageTag, List<LanguageTag> targetLanguageTags)
      : _targetLanguageTags = targetLanguageTags {
    if (originalLanguageTag == null) {
      throw ArgumentError('The source language must be specified');
    } else if (targetLanguageTags == null) {
      throw ArgumentError('The target languages list must be specified');
    }
  }

  factory MemeHeader.fromJson(Map<String, dynamic> jsonMap) =>
      MemeHeader(LanguageTag.parse(jsonMap[keySourceLanguageTag]), [
        for (String tagString in jsonMap[keyOriginalTargetLanguageTags])
          LanguageTag.parse(tagString)
      ]);

  List<LanguageTag> get managedLanguages => [
        originalLanguageTag,
        ..._targetLanguageTags,
      ];

  List<LanguageTag> get targetLanguages => [
        ..._targetLanguageTags,
      ];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      keySourceLanguageTag: originalLanguageTag.toJson(),
      keyOriginalTargetLanguageTags: [
        for (LanguageTag languageTag in _targetLanguageTags)
          languageTag.toJson()
      ]
    };
  }
}
