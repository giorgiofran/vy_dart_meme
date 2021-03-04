import 'dart:convert';

import 'package:vy_dart_meme/src/parts/meme_header.dart';
import 'package:vy_dart_meme/src/parts/meme_project.dart';
import 'package:vy_dart_meme/src/parts/meme_term.dart';
import 'package:test/test.dart';
import 'package:vy_dart_meme/vy_dart_meme.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

void main() {
  var languageTagUs = LanguageTag('en', region: 'US');
  var languageTagIt = LanguageTag('it', region: 'IT');
  var languageTagBr = LanguageTag('pt', region: 'BR');
  var languageTagFr = LanguageTag('fr', region: 'FR');
  var languageTagDe = LanguageTag('de', region: 'DE');

  group('MemeHeader', () {
    test('Creation', () {
      var header = MemeHeader(languageTagUs, [languageTagBr, languageTagIt]);
      expect(header.originalLanguageTag, languageTagUs);
      expect(header.targetLanguages.length, 2);
      expect(header.targetLanguages.length, 2);
      expect(header.targetLanguages.contains(languageTagIt), isTrue);
    });

    test('Creation with added languages', () {
      var header = MemeHeader(languageTagUs,
          [languageTagBr, languageTagIt, languageTagFr, languageTagDe]);
      expect(header.originalLanguageTag, languageTagUs);
      expect(header.targetLanguages.length, 4);
      expect(header.targetLanguages.contains(languageTagFr), isTrue);
    });

    test('toJson', () {
      var checkSource = '{"originalLanguageTag":"en-US",'
          '"targetLanguageTags":["pt-BR","it-IT","fr-FR","de-DE"]}';
      var header = MemeHeader(languageTagUs,
          [languageTagBr, languageTagIt, languageTagFr, languageTagDe]);

      expect(json.encode(header), checkSource);
    });
    test('fromJson', () {
      var checkSource = '{"originalLanguageTag":"en-US",'
          '"targetLanguageTags":["pt-BR","it-IT","fr-FR","de-DE"]}';
      var header = MemeHeader(languageTagUs,
          [languageTagBr, languageTagIt, languageTagFr, languageTagDe]);

      var jsonHeader = MemeHeader.fromJson(json.decode(checkSource));

      expect(jsonHeader.originalLanguageTag, header.originalLanguageTag);
      expect(jsonHeader.targetLanguages.length, header.targetLanguages.length);
      expect(jsonHeader.targetLanguages.contains(languageTagDe), isTrue);
      expect(jsonHeader.targetLanguages.contains(languageTagUs), isFalse);
      expect(jsonHeader.managedLanguages.contains(languageTagUs), isTrue);
      expect(jsonHeader.targetLanguages.length, header.targetLanguages.length);
    });
  });

  group('MemeProject', () {
    test('Creation', () {
      var project = MemeProject('project 1',
          MemeHeader(languageTagDe, [languageTagIt, languageTagBr]));
      expect(project.isEmpty, isTrue);
      expect(project.isNotEmpty, isFalse);
    });

    test('set header', () {
      var headerDe = MemeHeader(languageTagDe, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerDe);
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      expect(project.header.originalLanguageTag, headerDe.originalLanguageTag);
      project.header = headerUs;
      expect(project.header.originalLanguageTag, languageTagUs);
    });

    test('set term', () {
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);
    });

    test('set language term', () {
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');
      expect(() => project.setLanguageTerm('0002', languageTagIt, 'Alto'),
          throwsArgumentError);
      expect(project.getTerm('0001')?.getLanguageTerm(languageTagIt), 'Ciao');
      project.removeTerm('0001');
      expect(project.isEmpty, isTrue);
    });

    test('toJson', () {
      var checkSource = '{"name":"project 1","header":{"originalLanguageTag":'
          '"en-US","targetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","description":"first test",'
          '"idTerms":{"it-IT":"Ciao"}}}}';
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');

      expect(json.encode(project), checkSource);
    });

    test('fromJson', () {
      var checkSource = '{"name":"project 1","header":{"originalLanguageTag":'
          '"en-US","targetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","description":"first test",'
          '"idTerms":{"it-IT":"Ciao"}}}}';
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');

      var jsonProject = MemeProject.fromJson(json.decode(checkSource));

      expect(jsonProject.name, project.name);
      expect(jsonProject.isEmpty, isFalse);
      expect(jsonProject.header.originalLanguageTag,
          project.header.originalLanguageTag);
      expect(jsonProject.header.targetLanguages.length,
          project.header.targetLanguages.length);
      expect(jsonProject.getTerm('0001')?.getLanguageTerm(languageTagIt),
          project.getTerm('0001')?.getLanguageTerm(languageTagIt));
    });

    // Todo do more tests
  });

  group('Meme', () {
    test('Creation', () {
      var meme = Meme();
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);

      meme.addProject(project);

      expect(meme.projectNames.length, 1);
      expect(meme.projectNames.first, 'project 1');
    });

    test('toJson', () {
      var checkSource = '[{"name":"project 1","header":{"originalLanguageTag":'
          '"en-US","targetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","description":"first test"}}}]';
      var meme = Meme();
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);

      meme.addProject(project);

      expect(json.encode(meme), checkSource);
    });

    test('fromJson', () {
      var checkSource = '[{"name":"project 1","header":{"originalLanguageTag":'
          '"en-US","targetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","description":"first test", '
          '"idTerms":{"it-IT":"Ciao"}}}}]';
      var meme = Meme();
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');
      meme.addProject(project);

      var jsonMeme = Meme.fromJson(json.decode(checkSource));

      var jsonProject = jsonMeme.getProject('project 1');

      if (jsonProject != null) {
        expect(jsonProject.name, project.name);
        expect(jsonProject.isEmpty, isFalse);
        expect(jsonProject.header.originalLanguageTag,
            project.header.originalLanguageTag);
        expect(jsonProject.header.targetLanguages.length,
            project.header.targetLanguages.length);
        expect(jsonProject.getTerm('0001')?.getLanguageTerm(languageTagIt),
            project.getTerm('0001')?.getLanguageTerm(languageTagIt));
      }
    });

    test('encode', () {
      var checkSource = 'List<Map<String, dynamic>> meme = '
          '[{"name":"project 1","header":{"originalLanguageTag":"en-US",'
          '"targetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","description":"first test"}}}];';
      var meme = Meme();
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.insertTerm(term);

      meme.addProject(project);

      expect(meme.encode(), checkSource);
    });

    test('decode', () {
      var checkSource = 'List<Map<String, dynamic>> meme = '
          '[{"name":"project 1","header":{"originalLanguageTag":"en-US",'
          '"targetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","description":"first test"}}}];';
      var meme = Meme();
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var project = MemeProject('project 1', headerUs);
      var term = MemeTerm(headerUs.originalLanguageTag, 'Hello', '0001')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      var decodedMeme = Meme.decode(checkSource);

      expect(meme.projectNames.length, decodedMeme.projectNames.length);
      expect(meme.projectNames.first, decodedMeme.projectNames.first);
    });

    // Todo do more tests
  });
}
