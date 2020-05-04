import 'dart:convert';

import 'package:vy_dart_meme/src/constants/key_aliases.dart';
import 'package:vy_string_utils/vy_string_utils.dart';
import 'package:vy_dart_meme/src/constants/utils.dart';
import 'package:vy_dart_meme/src/parts/meme_project.dart';

class Meme {
  List<MemeProject> _projects = <MemeProject>[];

  Meme();

  factory Meme.fromJson(List jsonList) => Meme()
    .._projects = [
      for (Map<String, dynamic> jsonMap in jsonList)
        MemeProject.fromJson(jsonMap)
    ];

  factory Meme.decode(String memeString) {
    var check = memeString.trim();
    if (unfilled(check)) {
      return Meme();
    }
    if (memeString.contains('"sourceLanguage"')) {
      return Meme.decodeOldVersion(memeString);
    }
    const checkPattern = 'meme =';
    var declarationIndex = check.indexOf(checkPattern);
    if (declarationIndex == -1) {
      throw StateError('Trying to decode a meme string, '
          'but it is missing the "meme" variable.');
    }
    declarationIndex += checkPattern.length;
    var endDeclarationIndex = check.indexOf(';', check.length - 4);
    var meme = Meme.fromJson(
        json.decode(check.substring(declarationIndex, endDeclarationIndex)));
    return meme;
  }

  // Temporary method in order to convert old format
  // To be deleted after all old formats have been converted
  factory Meme.decodeOldVersion(String memeString) {
    var check = memeString.trim();
    if (unfilled(check)) {
      return Meme();
    }
    const checkPattern = 'meme =';
    var declarationIndex = check.indexOf(checkPattern);
    if (declarationIndex == -1) {
      throw StateError('Trying to decode a meme string, '
          'but it is missing the "meme" variable.');
    }
    declarationIndex += checkPattern.length;
    var endDeclarationIndex = check.indexOf(';', check.length - 4);
    List<dynamic> dataMap =
        json.decode(check.substring(declarationIndex, endDeclarationIndex));
    var convertedDataMap = <Map<String, dynamic>>[];
    for (var project in dataMap) {
      var header = project['header'];
      var newHeader = <String, dynamic>{
        keyOriginalLanguageTag: header['sourceLanguageTag'],
        keyTargetLanguageTags: [
          ...header['originalTargetLanguageTags'] ?? [],
          ...header['addedLanguageTags'] ?? []
        ]
      };
      var terms = project['terms'];
      var newTerms = <String, dynamic>{};
      for (var id in terms.keys) {
        var content = terms[id];
        var newContent = <String, dynamic>{
          keyId: content[keyId],
          keyOriginalLanguageTag: content['sourceLanguage'],
          keyOriginalTerm: content[keyIdTerms][content['sourceLanguage']],
          if (content[keyFlavorTerms] != null &&
              content[keyFlavorTerms][[content['sourceLanguage']]] != null)
            keyOriginalFlavorTerms: content[keyFlavorTerms]
                [[content['sourceLanguage']]],
          if (content[keyRelativeSourcePath] != null)
            keyRelativeSourcePath: content[keyRelativeSourcePath],
          if (content[keyDescription] != null)
            keyDescription: content[keyDescription],
          if (content[keyExampleValues] != null)
            keyExampleValues: content[keyExampleValues],
          if (content[keyFlavorCollections] != null)
            keyFlavorCollections: content[keyFlavorCollections],
          if (content[keyIdTerms] != null) keyIdTerms: content[keyIdTerms],
          if (content[keyFlavorTerms] != null)
            keyFlavorTerms: content[keyFlavorTerms],
        };
        if (newContent[keyIdTerms] != null) {
          (newContent[keyIdTerms] as Map)
              .remove(newContent[keyOriginalLanguageTag]);
        }
        if (newContent[keyFlavorTerms] != null) {
          (newContent[keyFlavorTerms] as Map)
              .remove(newContent[keyOriginalLanguageTag]);
        }
        newTerms[id] = newContent;
      }
      project['header'] = newHeader;
      project['terms'] = newTerms;

      convertedDataMap.add(project);
    }

    var meme = Meme.fromJson(convertedDataMap);
    return meme;
  }

  bool addProject(MemeProject project, {bool force}) {
    var foundProjectIndex = _projects
        .indexWhere((MemeProject _project) => _project.name == project.name);
    if (foundProjectIndex == notFoundInList) {
      _projects.add(project);
      return true;
    } else if (force) {
      _projects.removeAt(foundProjectIndex);
      _projects.add(project);
      return true;
    }
    return false;
  }

  void removeProject(MemeProject project) => _projects
      .removeWhere((MemeProject _project) => _project.name == project.name);

  MemeProject getProject(String projectName) => _projects
      .firstWhere((element) => element.name == projectName, orElse: () => null);

  bool containsProject(String projectName) =>
      projectNames.contains(projectName);

  List<String> get projectNames =>
      <String>[for (MemeProject project in _projects) project.name];

  String encode() {
    var buffer = StringBuffer();
    buffer.write('List<Map<String, dynamic>> meme = ');
    buffer.write(json.encode(this));
    buffer.write(';');
    return buffer.toString();
  }

  List<Map<String, dynamic>> toJson() =>
      [for (MemeProject project in _projects) project.toJson()];

  Meme mergeMeme(Meme memeToBeMerged, {bool onlyProjectsInThisMeme}) {
    onlyProjectsInThisMeme ??= false;
    var ret = Meme();
    ret._projects = [..._projects];
    for (var toBeMergedProject in memeToBeMerged._projects) {
      if (ret.containsProject(toBeMergedProject.name)) {
        // The meaning fo the flag "onlyProjectsInThisMeme" is not exactly
        // the same of the project meme method flag "onlyIdsInThisProject"
        // but, for now, it could be ok
        var project = ret.getProject(toBeMergedProject.name).mergeWith(
            toBeMergedProject,
            onlyIdsInThisProject: onlyProjectsInThisMeme);
        ret.addProject(project, force: true);
      }
      if (!onlyProjectsInThisMeme) {
        ret.addProject(toBeMergedProject);
      }
    }

    return ret;
  }
}
