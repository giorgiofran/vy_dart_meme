import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_dart_meme/src/element/flavor_collection.dart';
import 'package:vy_dart_meme/src/parts/meme_header.dart';
import 'package:vy_language_tag/vy_language_tag.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

void _checkValidFlavorKey(
    List<FlavorCollection> flavorCollections, Map<String, String> flavorTerms) {
  if (flavorCollections == null || flavorCollections.isEmpty) {
    if (flavorTerms == null || flavorTerms.isEmpty) {
      return;
    }
    throw ArgumentError(
        'Cannot specify flavor values without the flavor collections');
  } else if (flavorTerms == null || flavorTerms.isEmpty) {
    return;
  }
  for (var flavorKey in flavorTerms?.keys ?? <String>[]) {
    var parts = flavorKey.split(FlavorCollection.keySeparator);
    if (parts.length != flavorCollections.length) {
      throw ArgumentError(
          'The flavor key "$flavorKey" contains ${parts.length} '
          'elements that does not correspond to the specified flavor '
          'collection(s) number (${flavorCollections.length})');
    }
    for (var idx = 0; idx < parts.length; idx++) {
      if (!flavorCollections[idx].collectionFlavors.contains(parts[idx])) {
        throw ArgumentError(
            'The flavor "${parts[idx]}" is not a valid value for '
            'the flavor collection "${flavorCollections[idx].name}"');
      }
    }
  }
}

class MemeTerm {
  final LanguageTag sourceLanguageTag;
  final String id;
  String relativeSourcePath;
  String description;
  List<String> exampleValues;
  final List<FlavorCollection> flavorCollections;
  // String locale (posix) - term
  Map<LanguageTag, String> _idTerms;
  // Language tag : {flavor key (ex. male%plural): term}
  Map<LanguageTag, Map<String, String>> _flavorTerms;

  /// if null, ok, otherwise it means that the message is in a
  /// language and must be translated;
  LanguageTag defaultToBeTranslatedFromLanguage;

  MemeTerm(this.sourceLanguageTag, this.id, String sourceTerm,
      {this.flavorCollections, Map<String, String> sourceFlavorTerms}) {
    if (sourceLanguageTag == null) {
      throw ArgumentError('Source language required in MemeTerm creation');
    } else if (id == null) {
      throw ArgumentError('Id required in MemeTerm creation');
    } else if (sourceTerm == null) {
      throw ArgumentError('Source term required in MemeTerm creation');
    } else if (sourceFlavorTerms != null && sourceFlavorTerms.isNotEmpty) {
      _checkValidFlavorKey(flavorCollections, sourceFlavorTerms);
      /*    if (flavorCollections == null || flavorCollections.isEmpty) {
        throw ArgumentError(
            'Cannot specify flavor values without the flavor collections');
      }*/
    }
    _idTerms = <LanguageTag, String>{sourceLanguageTag: sourceTerm};
    _flavorTerms = <LanguageTag, Map<String, String>>{
      if (sourceFlavorTerms != null && sourceFlavorTerms.isNotEmpty)
        sourceLanguageTag: sourceFlavorTerms
    };
  }

  factory MemeTerm.fromJson(Map<String, dynamic> jsonMap) {
    return MemeTerm(LanguageTag.fromJson(jsonMap[keySourceLanguage]),
        jsonMap[keyId], jsonMap[keyIdTerms][jsonMap[keySourceLanguage]],
        flavorCollections: <FlavorCollection>[
          for (var key in jsonMap[keyFlavorCollections]?.keys ?? [])
            FlavorCollection.fromJson({
              key: <String>[
                for (var flavor in jsonMap[keyFlavorCollections][key]) flavor
              ]
            })
        ])
      ..defaultToBeTranslatedFromLanguage =
          jsonMap[keyDefaultToBeTranslatedFromLanguage]
      ..description = jsonMap[keyDescription]
      ..exampleValues = <String>[
        if (jsonMap[keyExampleValues] != null) ...jsonMap[keyExampleValues]
      ]
      ..relativeSourcePath = jsonMap[keyRelativeSourcePath]
      .._idTerms = <LanguageTag, String>{
        for (String key in jsonMap[keyIdTerms].keys ?? [])
          LanguageTag.fromJson(key): jsonMap[keyIdTerms][key]
      }
      .._flavorTerms = <LanguageTag, Map<String, String>>{
        for (var key in jsonMap[keyFlavorTerms]?.keys ?? [])
          LanguageTag.fromJson(key): {
            for (var flavorKey in jsonMap[keyFlavorTerms][key]?.keys ?? [])
              flavorKey: jsonMap[keyFlavorTerms][key][flavorKey]
          }
      };
  }

  bool get defaultMustBeTranslated => defaultToBeTranslatedFromLanguage != null;

  MemeTerm duplicate() =>
      MemeTerm(sourceLanguageTag, id, _idTerms[sourceLanguageTag],
          flavorCollections: flavorCollections)
        ..defaultToBeTranslatedFromLanguage = defaultToBeTranslatedFromLanguage
        ..relativeSourcePath = relativeSourcePath
        ..description = description
        ..exampleValues = [if (exampleValues != null) ...exampleValues]
        .._idTerms = {..._idTerms}
        .._flavorTerms = {..._flavorTerms};

  /// Remove the translation for a certain language
  /// Throws error if it is the default language (it cannot be changed...)
  void removeLanguageTerm(LanguageTag languageTag) {
    if (languageTag == sourceLanguageTag) {
      throw ArgumentError('Cannot remove the default language term');
    }
    _idTerms.remove(languageTag);
    removeLanguageFlavors(languageTag);
  }

  /// Remove the translation flavors for a certain language
  /// Throws error if it is the default language (it cannot be changed...)
  void removeLanguageFlavors(LanguageTag languageTag) {
    if (languageTag == sourceLanguageTag) {
      throw ArgumentError('Cannot remove the default language term');
    }
    _flavorTerms.remove(languageTag);
  }

  /// Remove one translation flavor for a certain language
  /// Throws error if it is the default language (it cannot be changed...)
  void removeLanguageFlavorTerm(LanguageTag languageTag, String flavorKey) {
    if (languageTag == sourceLanguageTag) {
      throw ArgumentError('Cannot remove the default language term');
    }
    var flavors = getLanguageFlavorTerms(languageTag);
    flavors.remove(flavorKey);
  }

  /// Return a translation for a certain term or null if missing
  String getLanguageTerm(LanguageTag languageTag) => _idTerms[languageTag];

  /// Return all flavors for a certain language
  Map<String, String> getLanguageFlavorTerms(LanguageTag languageTag) =>
      _flavorTerms[languageTag] ?? <String, String>{};

  /// Return a translation for a certain flavor key or the default if missing
  String getLanguageFlavorTerm(LanguageTag languageTag, String flavorKey) =>
      (_flavorTerms[languageTag] == null
          ? null
          : _flavorTerms[languageTag][flavorKey]) ??
      _idTerms[languageTag];

  /// Insert a term for a certain language.
  /// Throws error if it is the default language (it cannot be translated..)
  /// unless it is waiting to be translated from another language
  /// If a translation for the required language is already present it is
  /// overwritten.
  /// Flavor terms are overwritten too.
  void insertLanguageTerm(LanguageTag languageTag, String term,
      {Map<String, String> flavorTerms}) {
    if (languageTag == sourceLanguageTag && !defaultMustBeTranslated) {
      throw StateError('The language $languageTag is set as default. '
          'The term cannot be changed');
    }
    // We cannot know if it has been translated from the correct language...
    defaultToBeTranslatedFromLanguage = null;
    _idTerms[languageTag] = term;

    if (flavorTerms != null) {
      if (flavorTerms.isNotEmpty &&
          (flavorCollections == null || flavorCollections.isEmpty)) {
        throw StateError('Cannot insert flavor terms if the flavor '
            'collections has not been specified.');
      }
      if (flavorTerms.isEmpty) {
        _flavorTerms.remove(languageTag);
      } else {
        _checkValidFlavorKey(flavorCollections, flavorTerms);
        _flavorTerms[languageTag] = flavorTerms;
      }
    }
  }

  void insertLanguageFlavorTerm(
      LanguageTag languageTag, String flavorKey, String flavorTerm) {
    if (languageTag == sourceLanguageTag) {
      if (defaultMustBeTranslated) {
        throw StateError('The language default term for the language '
            '"$languageTag" must be translated yet.');
      } else {
        throw StateError('The language $languageTag is set as default. '
            'The term cannot be changed');
      }
    }
    if (!containsLanguageTerm(languageTag)) {
      throw StateError(
          'Cannot insert a flavor term for language "${languageTag.code}" '
          'if the default value is not present');
    }
    // We cannot know if it has been translated from the correct language...

    _checkValidFlavorKey(flavorCollections, {flavorKey: flavorTerm});
    if (filled(flavorTerm)) {
      var flavorMap = getLanguageFlavorTerms(languageTag) ?? <String, String>{};
      flavorMap[flavorKey] = flavorTerm;
      _flavorTerms[languageTag] = flavorMap;
    } else {
      removeLanguageFlavorTerm(languageTag, flavorKey);
    }
  }

  /// Verifies if the translation exists for a certain language tag.
  bool containsLanguageTerm(LanguageTag languageTag) =>
      _idTerms.containsKey(languageTag);

  /// Verifies if the translation exists for a certain language/flavor tag.
  bool containsLanguageFlavorTerm(LanguageTag languageTag, String flavorKey) =>
      _flavorTerms[languageTag] != null &&
          _flavorTerms[languageTag][flavorKey] != null ||
      containsLanguageTerm(languageTag);

  /// Returns the language tags of the translations that exists for this term
  /// (default language included)
  Iterable<LanguageTag> get languageTags => _idTerms.keys;

  /// Returns the flavor keys that exist for a language tag for this term
  /// (default language included)
  Iterable<String> languageFlavorKeys(LanguageTag languageTag) => [
        if (_flavorTerms != null && _flavorTerms[languageTag] != null)
          ..._flavorTerms[languageTag].keys
      ];

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
        header.sourceLanguageTag, id, getLanguageTerm(header.sourceLanguageTag),
        flavorCollections: flavorCollections,
        sourceFlavorTerms: getLanguageFlavorTerms(header.sourceLanguageTag))
      ..description = description
      ..relativeSourcePath = relativeSourcePath
      ..exampleValues = exampleValues;
    var languageTags = header.targetLanguages;
    for (var languageTag in languageTags) {
      if (containsLanguageTerm(languageTag)) {
        ret.insertLanguageTerm(languageTag, getLanguageTerm(languageTag),
            flavorTerms: getLanguageFlavorTerms(languageTag));
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
        if (flavorCollections != null && flavorCollections.isNotEmpty)
          keyFlavorCollections: {
            for (var flavorCollection in flavorCollections)
              ...flavorCollection.toJson()
          },
        if (_idTerms != null && _idTerms.isNotEmpty)
          keyIdTerms: {
            for (LanguageTag languageTag in _idTerms.keys)
              languageTag.toJson(): _idTerms[languageTag]
          },
        if (_flavorTerms != null && _flavorTerms.isNotEmpty)
          keyFlavorTerms: {
            for (LanguageTag languageTag in _flavorTerms.keys)
              if (_flavorTerms[languageTag] != null &&
                  _flavorTerms[languageTag].isNotEmpty)
                languageTag.toJson(): _flavorTerms[languageTag]
          },
      };
}
