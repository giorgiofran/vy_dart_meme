import 'dart:convert';

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
    const checkPattern = 'meme =';
    var declarationIndex = check.indexOf(checkPattern) + checkPattern.length;
    var endDeclarationIndex = check.indexOf(';', check.length - 4);
    var meme = Meme.fromJson(
        json.decode(check.substring(declarationIndex, endDeclarationIndex)));
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
}
