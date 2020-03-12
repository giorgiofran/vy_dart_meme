import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

class MemeHeader {
  final LanguageTag sourceLanguageTag;
  final List<LanguageTag> _originalTargetLanguageTags;
  final List<LanguageTag> _addedLanguageTags;

  MemeHeader(
      this.sourceLanguageTag, List<LanguageTag> originalTargetLanguageTags,
      {List<LanguageTag> addedLanguageTags})
      : _originalTargetLanguageTags = originalTargetLanguageTags,
        _addedLanguageTags = addedLanguageTags {
    if (sourceLanguageTag == null) {
      throw ArgumentError('The source language must be specified');
    } else if (originalTargetLanguageTags == null) {
      throw ArgumentError('The target languages list must be specified');
    }
  }

  factory MemeHeader.fromJson(Map<String, dynamic> jsonMap) => MemeHeader(
      LanguageTag.parse(jsonMap[keySourceLanguageTag]),
      [
        for (String tagString in jsonMap[keyOriginalTargetLanguageTags])
          LanguageTag.parse(tagString)
      ],
      addedLanguageTags: jsonMap[keyAddedLanguageTags] == null
          ? null
          : [
              for (String tagString in jsonMap[keyAddedLanguageTags])
                LanguageTag.parse(tagString)
            ]);

  List<LanguageTag> get targetLanguages => [
        ..._originalTargetLanguageTags,
        if (_addedLanguageTags != null) ..._addedLanguageTags
      ];

  List<LanguageTag> get originalTargetLanguageTags =>
      [..._originalTargetLanguageTags];

  List<LanguageTag> get addedLanguageTags =>
      [if (_addedLanguageTags != null) ..._addedLanguageTags];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      keySourceLanguageTag: sourceLanguageTag.toJson(),
      keyOriginalTargetLanguageTags: [
        for (LanguageTag languageTag in _originalTargetLanguageTags)
          languageTag.toJson()
      ],
      if (_addedLanguageTags != null)
        keyAddedLanguageTags: [
          for (LanguageTag languageTag in _addedLanguageTags)
            languageTag.toJson()
        ]
    };
  }
}
