import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_dart_meme/src/parts/meme_header.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

class MemeTerm {
  final LanguageTag sourceLanguageTag;
  final String id;
  String relativeSourcePath;
  String description;
  List<String> exampleValues;
  // String locale (posix) - term
  Map<LanguageTag, String> _idTerms;

  MemeTerm(this.sourceLanguageTag, this.id, String sourceTerm) {
    if (sourceLanguageTag == null) {
      throw ArgumentError('Source language required in MemeTerm creation');
    } else if (id == null) {
      throw ArgumentError('Id required in MemeTerm creation');
    } else if (sourceTerm == null) {
      throw ArgumentError('Source term required in MemeTerm creation');
    }
    _idTerms = <LanguageTag, String>{sourceLanguageTag: sourceTerm};
  }

  factory MemeTerm.fromJson(Map<String, dynamic> jsonMap) {
    return MemeTerm(LanguageTag.fromJson(jsonMap[keySourceLanguage]),
        jsonMap[keyId], jsonMap[keyIdTerms][jsonMap[keySourceLanguage]])
      ..description = jsonMap[keyDescription]
      ..exampleValues = jsonMap[keyExampleValues]
      .._idTerms = <LanguageTag, String>{
        for (String key in jsonMap[keyIdTerms].keys ?? [])
          LanguageTag.fromJson(key): jsonMap[keyIdTerms][key]
      };
  }

  MemeTerm duplicate() =>
      MemeTerm(this.sourceLanguageTag, this.id, _idTerms[this.sourceLanguageTag])
        ..relativeSourcePath = this.relativeSourcePath
        ..description = this.description
        ..exampleValues = [if (exampleValues != null) ...this.exampleValues]
        .._idTerms = {...this._idTerms};

  removeTerm(LanguageTag languageTag) {
    if (languageTag == sourceLanguageTag) {
      throw ArgumentError('Cannot remove the default language term');
    }
    _idTerms.remove(languageTag);
  }

  String getTerm(LanguageTag languageTag) => _idTerms[languageTag];

  void insertTerm(LanguageTag languageTag, String term) {
    if (languageTag == sourceLanguageTag) {
      throw StateError(
          'The language $languageTag is set as default. The term cannot be changed');
    }
    _idTerms[languageTag] = term;
  }

  bool containsLanguageTerm(LanguageTag languageTag) =>
      _idTerms.containsKey(languageTag);

  Iterable<LanguageTag> get languageTags => _idTerms.keys;

  MemeTerm resetTerms(MemeHeader header) {
    if (!containsLanguageTerm(header.sourceLanguageTag)) {
      return null;
    }
    MemeTerm ret = MemeTerm(
        header.sourceLanguageTag, id, getTerm(header.sourceLanguageTag));
    List<LanguageTag> languageTags = header.targetLanguages;
    for (LanguageTag languageTag in languageTags) {
      if (containsLanguageTerm(languageTag)) {
        ret.insertTerm(languageTag, getTerm(languageTag));
      }
    }
    return ret;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        keySourceLanguage: sourceLanguageTag,
        keyId: id,
        if (relativeSourcePath != null)
          keyRelativeSourcePath: relativeSourcePath,
        if (description != null) keyDescription: description,
        if (exampleValues != null && exampleValues.isNotEmpty)
          keyExampleValues: exampleValues,
        if (_idTerms != null && _idTerms.isNotEmpty)
          keyIdTerms: {
            for (LanguageTag languageTag in _idTerms.keys)
              languageTag.toJson(): _idTerms[languageTag]
          },
      };
}
