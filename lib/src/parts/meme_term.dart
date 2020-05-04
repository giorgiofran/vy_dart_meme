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
  final String id;
  final LanguageTag originalLanguageTag;
  final String originalTerm;
  final Map<String, String> originalFlavorTerms;
  String relativeSourcePath;
  String description;
  List<String> exampleValues;
  final List<FlavorCollection> flavorCollections;
  // String locale (posix) - term
  Map<LanguageTag, String> _idTerms;
  // Language tag : {flavor key (ex. male%plural): term}
  Map<LanguageTag, Map<String, String>> _flavorTerms;

  MemeTerm(this.originalLanguageTag, this.originalTerm, this.id,
      {this.flavorCollections, this.originalFlavorTerms}) {
    if (originalLanguageTag == null) {
      throw ArgumentError('Original language required in MemeTerm creation');
    } else if (id == null) {
      throw ArgumentError('Id required in MemeTerm creation');
    } else if (originalTerm == null) {
      throw ArgumentError('Original Source term required in MemeTerm creation');
    } else if (originalFlavorTerms != null && originalFlavorTerms.isNotEmpty) {
      _checkValidFlavorKey(flavorCollections, originalFlavorTerms);
    }
    _idTerms = <LanguageTag, String>{};
    _flavorTerms = <LanguageTag, Map<String, String>>{};
  }

  factory MemeTerm.fromJson(Map<String, dynamic> jsonMap) {
    return MemeTerm(LanguageTag.fromJson(jsonMap[keyOriginalLanguageTag]),
        jsonMap[keyOriginalTerm], jsonMap[keyId],
        flavorCollections: <FlavorCollection>[
          for (var key in jsonMap[keyFlavorCollections]?.keys ?? [])
            FlavorCollection.fromJson({
              key: <String>[
                for (var flavor in jsonMap[keyFlavorCollections][key]) flavor
              ]
            })
        ],
        originalFlavorTerms: <String, String>{
          for (String key in jsonMap[keyOriginalFlavorTerms]?.keys ?? [])
            key: jsonMap[keyOriginalFlavorTerms][key]
        })
      ..description = jsonMap[keyDescription]
      ..exampleValues = <String>[
        if (jsonMap[keyExampleValues] != null) ...jsonMap[keyExampleValues]
      ]
      ..relativeSourcePath = jsonMap[keyRelativeSourcePath]
      .._idTerms = <LanguageTag, String>{
        for (String key in jsonMap[keyIdTerms]?.keys ?? [])
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

  MemeTerm duplicate() => MemeTerm(originalLanguageTag, originalTerm, id,
      flavorCollections: flavorCollections,
      originalFlavorTerms: originalFlavorTerms)
    ..relativeSourcePath = relativeSourcePath
    ..description = description
    ..exampleValues = [if (exampleValues != null) ...exampleValues]
    .._idTerms = {..._idTerms}
    .._flavorTerms = {..._flavorTerms};

  String translation(LanguageTag languageTag) {
    _checkForNullValues(languageTag);
    return _idTerms[languageTag];
  }

  // The difference with getLanguageTerm is only related to
  // the original language.
  // Here the original language is returned only if the original term has
  // been modified, while in getLanguageTerm, if there is not a variation,
  // the original term is returned.
  Map<LanguageTag, String> get translations => {..._idTerms};

  String flavorTranslation(LanguageTag languageTag, String flavorKey) {
    _checkForNullValues(languageTag, flavorKey: flavorKey);
    if (_flavorTerms == null || _flavorTerms[languageTag] == null) {
      return null;
    }
    return _flavorTerms[languageTag][flavorKey];
  }

  /// The difference with getLanguageFlavorTerm is only related to
  /// the original language.
  /// Here the original language is returned only if the original term has
  /// been modified, while in getLanguageFlavorTerm, if there is not a variation,
  /// the original term is returned.
  Map<LanguageTag, Map<String, String>> get flavorTranslations =>
      <LanguageTag, Map<String, String>>{..._flavorTerms};

  /// Remove the translation for a certain language
  void removeLanguageTerm(LanguageTag languageTag) {
    _checkForNullValues(languageTag);
    _idTerms.remove(languageTag);
    removeLanguageFlavors(languageTag);
  }

  /// Remove the translation flavors for a certain language
  /// Throws error if it is the default language (it cannot be changed...)
  void removeLanguageFlavors(LanguageTag languageTag) {
    _checkForNullValues(languageTag);
    _flavorTerms.remove(languageTag);
  }

  /// Remove one translation flavor for a certain language
  /// The originalFlavor are never removed.
  void removeLanguageFlavorTerm(LanguageTag languageTag, String flavorKey) {
    _checkForNullValues(languageTag, flavorKey: flavorKey);
    var flavors = _flavorTerms[languageTag];
    flavors?.remove(flavorKey);
  }

  /// Return a translation for a certain term or null if missing
  String getLanguageTerm(LanguageTag languageTag) {
    _checkForNullValues(languageTag);
    var ret = _idTerms[languageTag];
    if (ret == null && languageTag == originalLanguageTag) {
      ret = originalTerm;
    }
    return ret;
  }

  /// Return all flavors for a certain language
  /// The missing keys are not substituted with default terms
  Map<String, String> getLanguageFlavorTerms(LanguageTag languageTag) {
    _checkForNullValues(languageTag);
    var flavors = _flavorTerms[languageTag];
    // The modified translations (if any) override the original one
    return <String, String>{
      if (languageTag == originalLanguageTag && originalFlavorTerms != null)
        ...originalFlavorTerms,
      if (flavors != null) ...flavors,
    };
  }

  /// Return a translation for a certain flavor key or the default if missing
  String getLanguageFlavorTerm(LanguageTag languageTag, String flavorKey) {
    _checkForNullValues(languageTag, flavorKey: flavorKey);
    var flavors = getLanguageFlavorTerms(languageTag);
    return (flavors == null
            ? getLanguageTerm(languageTag)
            : flavors[flavorKey]) ??
        getLanguageTerm(languageTag);
  }

  void _checkForNullValues(LanguageTag languageTag, {String flavorKey = ''}) {
    if (languageTag == null) {
      throw ArgumentError('Missing language tag in call to method');
    }
    if (flavorKey == null) {
      throw ArgumentError('Missing flavor key in call to method');
    }
  }

  /// Insert a term for a certain language.
  /// If a translation for the required language is already present it is
  /// overwritten.
  /// Flavor terms are overwritten too.
  void insertLanguageTerm(LanguageTag languageTag, String term,
      {Map<String, String> flavorTerms}) {
    if (languageTag != originalLanguageTag ||
        (term != null && term != originalTerm)) {
      _idTerms[languageTag] = term;
    }

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
    if (!containsLanguageTerm(languageTag)) {
      throw StateError(
          'Cannot insert a flavor term for language "${languageTag.code}" '
          'if the default term is not present');
    }

    _checkValidFlavorKey(flavorCollections, {flavorKey: flavorTerm});
    if (filled(flavorTerm)) {
      if (originalFlavorTerms == null ||
          originalLanguageTag != languageTag ||
          !originalFlavorTerms.containsKey(flavorKey) ||
          originalFlavorTerms[flavorKey] != flavorTerm) {
        var flavorMap = _flavorTerms[languageTag] ?? <String, String>{};
        flavorMap[flavorKey] = flavorTerm;
        _flavorTerms[languageTag] = flavorMap;
      }
    } else {
      removeLanguageFlavorTerm(languageTag, flavorKey);
    }
  }

  /// Verifies if the translation exists for a certain language tag.
  bool containsLanguageTerm(LanguageTag languageTag) =>
      languageTag == originalLanguageTag || _idTerms.containsKey(languageTag);

  /// Verifies if the translation exists for a certain language/flavor tag.
  bool containsLanguageFlavorTerm(LanguageTag languageTag, String flavorKey) =>
      (languageTag == originalLanguageTag &&
          originalFlavorTerms != null &&
          originalFlavorTerms[flavorKey] != null) ||
      (_flavorTerms[languageTag] != null &&
          _flavorTerms[languageTag][flavorKey] != null) ||
      containsLanguageTerm(languageTag);

  /// Returns the language tags of the translations that exists for this term
  Iterable<LanguageTag> get languageTags =>
      {originalLanguageTag, ..._idTerms.keys};

  /// Returns the flavor keys that exist for a language tag for this term
  /// (default language included)
  Iterable<String> languageFlavorKeys(LanguageTag languageTag) => {
        if (languageTag == originalLanguageTag && originalFlavorTerms != null)
          ...originalFlavorTerms.keys,
        if (_flavorTerms != null && _flavorTerms[languageTag] != null)
          ..._flavorTerms[languageTag].keys
      };

  /// This method is used in case of change of the default and/or target
  /// languages (in the header/parameters vy_translation.yaml)
  /// If a language is no more present into the target ones, it is not
  /// preserved.
  MemeTerm resetTerms(MemeHeader header,
      {bool preserveTermIfDefaultIsMissing}) {
    preserveTermIfDefaultIsMissing ??= true;
    if (!preserveTermIfDefaultIsMissing &&
        !containsLanguageTerm(header.originalLanguageTag)) {
      return null;
    }
    var ret = MemeTerm(originalLanguageTag, originalTerm, id,
        flavorCollections: flavorCollections,
        originalFlavorTerms: originalFlavorTerms)
      ..description = description
      ..relativeSourcePath = relativeSourcePath
      ..exampleValues = exampleValues;
    for (var languageTag in header.managedLanguages) {
      if (containsLanguageTerm(languageTag)) {
        ret.insertLanguageTerm(languageTag, translation(languageTag),
            flavorTerms: flavorTranslations[languageTag]);
      }
    }
    return ret;
  }

  // Merges another term with this one based on the received header
  // The id must be the same, unless force different Ids is specified.
  // in this case, the id of this term is maintained
  MemeTerm mergeTerm(MemeHeader header, MemeTerm toBeMerged,
      {bool forceDifferentIds}) {
    forceDifferentIds ??= false;
    if (id != toBeMerged?.id && !forceDifferentIds) {
      throw ArgumentError('It is not possible to merge two terms '
          'with different ids ("$id" and "${toBeMerged?.id}")');
    }
    var ret = resetTerms(header);
    for (var languageTag in header.managedLanguages) {
      var toBeMergedText;
      if (languageTag == ret.originalLanguageTag) {
        // if toBeMergedTerm has the sane original language tag
        // it does not use the original term but only the
        // modification (translation) if present
        toBeMergedText = toBeMerged.translation(languageTag);
      } else {
        toBeMergedText = toBeMerged.getLanguageTerm(languageTag);
      }
      if (filled(toBeMergedText) && !ret._idTerms.containsKey(languageTag)) {
        ret.insertLanguageTerm(languageTag, toBeMergedText);
      }
      // Flavor collections must be present, equal and in the same order
      // The order could be improved, at present it is a simplified control
      if (ret.flavorCollections != null &&
          ret.flavorCollections.isNotEmpty &&
          toBeMerged.flavorCollections != null &&
          ret.flavorCollections.length == toBeMerged.flavorCollections.length) {
        var checkOk = true;
        for (var idx = 0; idx < ret.flavorCollections.length; idx++) {
          if (ret.flavorCollections[idx] != toBeMerged.flavorCollections[idx]) {
            checkOk = false;
            break;
          }
        }
        if (checkOk) {
          var toBeMergedFlavors;
          //if (languageTag == ret.originalLanguageTag) {
          //  toBeMergedFlavors = toBeMerged.flavorTranslations[languageTag];
          //} else {
          toBeMergedFlavors = toBeMerged.getLanguageFlavorTerms(languageTag);
          //}
          var toBeMergedFlavorKeys = toBeMergedFlavors?.keys ?? [];
          var flavorTerms =
              ret.flavorTranslations[languageTag] ?? <String, String>{};

          for (var key in toBeMergedFlavorKeys) {
            if (!flavorTerms.containsKey(key)) {
              if (languageTag != ret.originalLanguageTag) {
                ret.insertLanguageFlavorTerm(
                    languageTag, key, toBeMergedFlavors[key]);
              } else {
                if (ret.originalFlavorTerms == null ||
                    originalFlavorTerms[key] == null) {
                  ret.insertLanguageFlavorTerm(
                      languageTag, key, toBeMergedFlavors[key]);
                }
              }
            }
          }
        }
      }
    }
    return ret;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        keyOriginalLanguageTag: originalLanguageTag,
        keyOriginalTerm: originalTerm,
        //keySourceLanguage: sourceLanguageTag,
        keyId: id,
        /*       if (defaultToBeTranslatedFromLanguage != null)
          keyDefaultToBeTranslatedFromLanguage:
              defaultToBeTranslatedFromLanguage,*/
        if (relativeSourcePath != null)
          keyRelativeSourcePath: relativeSourcePath,
        if (description != null)
          keyDescription: description,
        if (exampleValues != null && exampleValues.isNotEmpty)
          keyExampleValues: exampleValues,
        if (flavorCollections != null && flavorCollections.isNotEmpty)
          keyFlavorCollections: {
            for (var flavorCollection in flavorCollections)
              ...flavorCollection.toJson()
          },
        if (originalFlavorTerms != null && originalFlavorTerms.isNotEmpty)
          keyOriginalFlavorTerms: {
            for (String key in originalFlavorTerms.keys)
              key: originalFlavorTerms[key]
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
