import 'dart:collection';

import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

import 'meme_header.dart';
import 'meme_term.dart';

class MemeProject {
  final String name;
  MemeHeader _header;
  SplayTreeMap<String, MemeTerm> _terms = SplayTreeMap<String, MemeTerm>();

  MemeProject(this.name, MemeHeader header)
      // we can set the header directly here because there are still no terms
      : _header = header;

  factory MemeProject.fromJson(Map<String, dynamic> jsonMap) {
    if (jsonMap[keyHeader] == null) {
      throw ArgumentError('The jsonMap does not contain the project header');
    }
    final project =
        MemeProject(jsonMap[keyName], MemeHeader.fromJson(jsonMap[keyHeader]));
    if (jsonMap[keyTerms] != null) {
      project._terms = SplayTreeMap<String, MemeTerm>()
        ..addAll({
          for (String key in jsonMap[keyTerms].keys)
            key: MemeTerm.fromJson(jsonMap[keyTerms][key])
        });
    }

    return project;
  }

  MemeHeader get header => _header;

  set header(MemeHeader header) {
    if (_terms.isEmpty) {
      _header = header;
    } else {
      List<LanguageTag> oldManagedLanguages;
      oldManagedLanguages = _header.managedLanguages;
      for (var language in header.managedLanguages) {
        oldManagedLanguages.remove(language);
      }
      _header = header;
      //if (oldManagedLanguages.isNotEmpty) {
      for (var lang in oldManagedLanguages) {
        MemeTerm term;
        for (term in _terms.values) {
          term.removeLanguageTerm(lang);
        }
      }
    }
  }

  Map<String, dynamic> toJson() => {
        keyName: name,
        keyHeader: _header,
        if (_terms.isNotEmpty) keyTerms: _terms
      };

  @Deprecated('Now the header always exists')
  bool get isValid => true;

  bool get isNotEmpty => _terms.isNotEmpty;
  bool get isEmpty => !isNotEmpty;

  Iterable<MemeTerm> get terms => _terms.values;

  /// Merge this project with another and returns a brand new one.
  /// The name must be the same in the two projects, unless the
  /// forceIfNameIsDifferent is set. In this case the name of
  /// this project is used
  /// The header is taken from this project
  ///
  /// If the only ids from this project flag is set to true,
  /// all ids that are present only in the project to be merged are lost
  /// and only the exceeding translations for the valid ids are taken
  /// from that project.
  /// If the flag is not set (default) aside by this logic, also all exceeding
  /// ids are preserved.
  MemeProject mergeWith(MemeProject projectToBeMerged,
      {bool? onlyIdsInThisProject,
      bool? forceIfNameIsDifferent,
      bool? toBeMergedHasPriority}) {
    var _onlyIdsInThisProject = onlyIdsInThisProject ?? false;
    var _forceIfNameIsDifferent = forceIfNameIsDifferent ?? false;
    var _toBeMergedHasPriority = toBeMergedHasPriority ?? false;
    if (!_forceIfNameIsDifferent && name != projectToBeMerged.name) {
      throw StateError('Project "$name" cannot be merged with '
          'project ${projectToBeMerged.name}');
    }
    var retProject = MemeProject(name, _header);
    retProject._terms = SplayTreeMap.from(_terms);
    for (var toBeMergedTerm in projectToBeMerged._terms.values) {
      //if (retProject._terms.containsKey(toBeMergedTerm.id)) {
      var term = retProject._terms[toBeMergedTerm.id];
      if (term != null) {
        retProject.substituteTerm(_toBeMergedHasPriority
            ? term.combineTerm(_header, toBeMergedTerm)
            : term.mergeTerm(_header, toBeMergedTerm));
      } else if (!_onlyIdsInThisProject) {
        retProject.insertTerm(toBeMergedTerm);
      }
    }

    return retProject;
  }

  /// Insert the term only if the id is not yet present
  MemeTerm insertTerm(MemeTerm term, {bool? preserveTermIfDefaultIsMissing}) {
    if (_terms.containsKey(term.id)) {
      throw StateError('The id ${term.id} is already present in this project');
    }
    return substituteTerm(term,
        preserveTermIfDefaultIsMissing: preserveTermIfDefaultIsMissing);
  }

  /// Substitutes a term (or insert it if missing).
  /// If the header has changed, the translations are arranged consequently
  MemeTerm substituteTerm(MemeTerm term,
      {bool? preserveTermIfDefaultIsMissing}) {
    var _preserveTermIfDefaultIsMissing =
        preserveTermIfDefaultIsMissing ?? true;
    /*  if (!isValid) {
      throw StateError('Cannot insert a term if the header is missing');
    } */

    MemeTerm newTerm;
    if (_preserveTermIfDefaultIsMissing) {
      newTerm = term.resetTerms(_header);
    } else {
      var _newTerm = term.resetTermsUnlessNoOriginalMatch(_header);
      if (_newTerm == null) {
        throw StateError('The term has not been inserted because '
            'is not compatible with the header');
      }
      newTerm = _newTerm;
    }

    _terms[newTerm.id] = newTerm;
    return newTerm;
  }

  MemeTerm? getTerm(String id) => _terms[id]?.duplicate();

  MemeTerm? removeTerm(String id) => _terms.remove(id);

  void removeAllTerms() => _terms.clear();

  void setLanguageTerm(String id, LanguageTag languageTag, String term) {
    if (languageTag == _header.originalLanguageTag) {
      throw ArgumentError('Source language terms cannot be modified');
    } else if (!_header
        .managedLanguages /*targetLanguages*/ .contains(languageTag)) {
      throw ArgumentError('The language ${languageTag.posixCode} is not '
          'managed in this project ($name)');
    } else if (!_terms.containsKey(id)) {
      throw ArgumentError('The project "$name" does not contains the id "$id"');
    }
    _terms[id]?.insertLanguageTerm(languageTag, term);
  }

  void removeLanguageTerm(String id, LanguageTag languageTag) {
    // no header, no terms
    if (_header.managedLanguages.contains(languageTag)) {
      _terms[id]?.removeLanguageTerm(languageTag);
    }
  }
}
