import 'dart:collection';

import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

import 'meme_header.dart';
import 'meme_term.dart';

class MemeProject {
  final String name;
  MemeHeader _header;
  SplayTreeMap<String, MemeTerm> _terms;

  MemeProject(this.name);

  factory MemeProject.fromJson(Map<String, dynamic> jsonMap) {
    final project = MemeProject(jsonMap[keyName]);
    if (jsonMap[keyHeader] != null) {
      project.header = MemeHeader.fromJson(jsonMap[keyHeader]);
      if (jsonMap[keyTerms] != null) {
        project._terms = SplayTreeMap<String, MemeTerm>()
          ..addAll({
            for (String key in jsonMap[keyTerms].keys)
              key: MemeTerm.fromJson(jsonMap[keyTerms][key])
          });
      }
    }

    return project;
  }

  MemeHeader get header => _header;

  set header(MemeHeader header) {
    if (_terms == null || _terms.isEmpty) {
      _header = header;
      _terms ??= SplayTreeMap<String, MemeTerm>();
    } else if (_terms.values.first.sourceLanguageTag ==
        header.sourceLanguageTag) {
      List<LanguageTag> oldTargetLanguages;
      oldTargetLanguages = _header.targetLanguages;
      for (var language in header.targetLanguages) {
        oldTargetLanguages.remove(language);
      }
      _header = header;
      if (oldTargetLanguages.isNotEmpty) {
        MemeTerm term;
        for (term in _terms.values) {
          for (var lang in oldTargetLanguages) {
            term.removeLanguageTerm(lang);
          }
        }
      }
    } else {
      throw ArgumentError('It is not allowed to set an header '
          'if there are terms with a different source language');
    }
  }

  void forceNewHeader(MemeHeader _header) {
    try {
      header = _header;
    } on ArgumentError catch (_) {
      header = _header;
      _terms = SplayTreeMap<String, MemeTerm>()
        ..addAll(<String, MemeTerm>{
          for (MemeTerm term in _terms.values)
            if (term.containsLanguageTerm(header.sourceLanguageTag))
              term.id: term.resetTerms(header)
        });
    }
  }

  Map<String, dynamic> toJson() => {
        keyName: name,
        if (_header != null) keyHeader: _header,
        if (_terms != null) keyTerms: _terms
      };

  bool get isValid => _header != null;

  bool get isNotEmpty => isValid && _terms != null && _terms.isNotEmpty;
  bool get isEmpty => !isNotEmpty;

  Iterable<MemeTerm> get terms => _terms?.values ?? <MemeTerm>{};

  /// Merge this project with another and returns a brand new one.
  /// Name and header are taken from this project
  ///
  /// If the only ids from this project flag is set to true,
  /// all ids that are present only in the project to be merged are lost
  /// and only the exceeding translations for the valid ids are taken
  /// from that project.
  /// If the flag is not set (default) aside by this logic, also all exceeding
  /// ids are preserved.
  MemeProject mergeWith(MemeProject projectToBeMerged,
      {bool onlyIdsInThisProject}) {
    onlyIdsInThisProject ??= false;
    var ret = MemeProject(name)..header = header;
    ret._terms = SplayTreeMap.from(_terms);
    for (var toBeMergedTerm in projectToBeMerged._terms.values) {
      if (ret._terms.containsKey(toBeMergedTerm.id)) {
        var term = ret._terms[toBeMergedTerm.id];
        for (var languageTag in ret.header.targetLanguages) {
          if (!term.containsLanguageTerm(languageTag) &&
                  toBeMergedTerm.containsLanguageTerm(languageTag) &&
                  term.getLanguageTerm(term.sourceLanguageTag) ==
                      toBeMergedTerm.getLanguageTerm(term.sourceLanguageTag) ??
              '') {
            term.insertLanguageTerm(
                languageTag, toBeMergedTerm.getLanguageTerm(languageTag));
          }
        }
      } else if (!onlyIdsInThisProject) {
        ret.insertTerm(toBeMergedTerm);
      }
    }

    return ret;
  }

  /// Insert the term only if the id is not yet present
  MemeTerm insertTerm(MemeTerm term, {bool preserveTermIfDefaultIsMissing}) {
    if (!isValid) {
      throw StateError('Cannot insert a term if the header is missing');
    }
    if (_terms.containsKey(term.id)) {
      throw StateError('The id ${term.id} is already present in this project');
    }
    return substituteTerm(term,
        preserveTermIfDefaultIsMissing: preserveTermIfDefaultIsMissing);
  }

  /// Substitutes a term (or insert it if missing).
  /// If the header has changed, the translations are arranged consequently
  MemeTerm substituteTerm(MemeTerm term,
      {bool preserveTermIfDefaultIsMissing}) {
    if (!isValid) {
      throw StateError('Cannot insert a term if the header is missing');
    }
    var newTerm = term.resetTerms(_header,
        preserveTermIfDefaultIsMissing: preserveTermIfDefaultIsMissing);
    if (newTerm == null) {
      throw StateError('The term has not been inserted because '
          'is not compatible with the header');
    }
    _terms[newTerm.id] = newTerm;
    return newTerm;
  }

  MemeTerm getTerm(String id) => _terms[id]?.duplicate();

  MemeTerm removeTerm(String id) => _terms.remove(id);

  void removeAllTerms() => _terms.clear();

  void setLanguageTerm(String id, LanguageTag languageTag, String term) {
    if (!isValid) {
      throw StateError('Cannot insert a term if the header is missing');
    }
    if (languageTag == _header.sourceLanguageTag) {
      throw ArgumentError('Source language terms cannot be modified');
    } else if (!_header.targetLanguages.contains(languageTag)) {
      throw ArgumentError('The language ${languageTag.posixCode} is not '
          'managed in this project ($name)');
    } else if (!_terms.containsKey(id)) {
      throw ArgumentError('The project "$name" does not contains the id "$id"');
    }
    _terms[id].insertLanguageTerm(languageTag, term);
  }

  void removeLanguageTerm(String id, LanguageTag languageTag) {
    // no header, no terms
    if (!isValid) {
      return;
    } else if (languageTag == _header.sourceLanguageTag) {
      throw ArgumentError('Source language terms cannot be removed');
    } else if (_header.targetLanguages.contains(languageTag)) {
      _terms[id].removeLanguageTerm(languageTag);
    }
  }
}
