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

  /// if null, ok, otherwise it means that the message is in a
  /// language and must be translated;
  LanguageTag defaultToBeTranslatedFromLanguage;

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
      ..defaultToBeTranslatedFromLanguage =
          jsonMap[keyDefaultToBeTranslatedFromLanguage]
      ..description = jsonMap[keyDescription]
      ..exampleValues = jsonMap[keyExampleValues]
      ..relativeSourcePath = jsonMap[keyRelativeSourcePath]
      .._idTerms = <LanguageTag, String>{
        for (String key in jsonMap[keyIdTerms].keys ?? [])
          LanguageTag.fromJson(key): jsonMap[keyIdTerms][key]
      };
  }

  bool get defaultMustBeTranslated => defaultToBeTranslatedFromLanguage != null;

  MemeTerm duplicate() =>
      MemeTerm(sourceLanguageTag, id, _idTerms[sourceLanguageTag])
        ..defaultToBeTranslatedFromLanguage = defaultToBeTranslatedFromLanguage
        ..relativeSourcePath = relativeSourcePath
        ..description = description
        ..exampleValues = [if (exampleValues != null) ...exampleValues]
        .._idTerms = {..._idTerms};

  /// Remove the translation for a certain language
  /// Throws error if it is the default language (it cannot be changed...)
  void removeLanguageTerm(LanguageTag languageTag) {
    if (languageTag == sourceLanguageTag) {
      throw ArgumentError('Cannot remove the default language term');
    }
    _idTerms.remove(languageTag);
  }

  /// Return a translation for a certain term or null if missing
  String getLanguageTerm(LanguageTag languageTag) => _idTerms[languageTag];

  /// Insert a term for a certain language.
  /// Throws error if it is the default language (it cannot be translated..)
  /// unless it is waiting to be translated from another language
  /// If a translation for the required language is already present it
  /// overwritten.
  void insertLanguageTerm(LanguageTag languageTag, String term) {
    if (languageTag == sourceLanguageTag && !defaultMustBeTranslated) {
      throw StateError(
          'The language $languageTag is set as default. The term cannot be changed');
    }
    // We cannot know if it has been translated from the correct language...
    defaultToBeTranslatedFromLanguage = null;
    _idTerms[languageTag] = term;
  }

  /// Verifies if the translation exists for a certain language tag.
  bool containsLanguageTerm(LanguageTag languageTag) =>
      _idTerms.containsKey(languageTag);

  /// Returns the language tags of the translations that exists for this term
  /// (default language included)
  Iterable<LanguageTag> get languageTags => _idTerms.keys;

  /// This method is used in case of change of the default and/or target
  /// languages (in the header/parameters vy_translation.yaml)
  /// If a translation exists for the new default message (if is the same
  /// as before nothing changes), this one is used as new default,
  /// otherwise a flag is set that it must be translated and from which
  /// language. In this case temporarily the default message will
  /// remain in the original language. If the preserve term if default is
  /// missing is set to false, the above logic is not applied and a null value
  /// is returned;
  /// If a language is no more present into the target ones, it is not
  /// preserved.
  MemeTerm resetTerms(MemeHeader header,
      {bool preserveTermIfDefaultIsMissing}) {
    preserveTermIfDefaultIsMissing ??= true;
    if (!preserveTermIfDefaultIsMissing &&
        !containsLanguageTerm(header.sourceLanguageTag)) {
      return null;
    }
    var ret = MemeTerm(
        header.sourceLanguageTag, id, getLanguageTerm(header.sourceLanguageTag))
      ..description = description
      ..relativeSourcePath = relativeSourcePath
      ..exampleValues = exampleValues;
    var languageTags = header.targetLanguages;
    for (var languageTag in languageTags) {
      if (containsLanguageTerm(languageTag)) {
        ret.insertLanguageTerm(languageTag, getLanguageTerm(languageTag));
      }
    }
    return ret;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        keySourceLanguage: sourceLanguageTag,
        keyId: id,
        if (defaultToBeTranslatedFromLanguage != null)
          keyDefaultToBeTranslatedFromLanguage:
              defaultToBeTranslatedFromLanguage,
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
