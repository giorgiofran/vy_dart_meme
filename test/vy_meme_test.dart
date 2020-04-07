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
      expect(header.sourceLanguageTag, languageTagUs);
      expect(header.originalTargetLanguageTags.length, 2);
      expect(header.targetLanguages.length, 2);
      expect(header.targetLanguages.contains(languageTagIt), isTrue);
      expect(header.addedLanguageTags, isEmpty);
    });

    test('Creation with added languages', () {
      var header = MemeHeader(languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagFr, languageTagDe]);
      expect(header.sourceLanguageTag, languageTagUs);
      expect(header.originalTargetLanguageTags.length, 2);
      expect(header.targetLanguages.length, 4);
      expect(header.targetLanguages.contains(languageTagFr), isTrue);
      expect(header.addedLanguageTags.length, 2);
    });

    test('toJson', () {
      var checkSource = '{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["pt-BR","it-IT"],'
          '"addedeLanguageTags":["fr-FR","de-DE"]}';
      var header = MemeHeader(languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagFr, languageTagDe]);

      expect(json.encode(header), checkSource);
    });
    test('fromJson', () {
      var checkSource = '{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["pt-BR","it-IT"],'
          '"addedeLanguageTags":["fr-FR","de-DE"]}';
      var header = MemeHeader(languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagFr, languageTagDe]);

      var jsonHeader = MemeHeader.fromJson(json.decode(checkSource));

      expect(jsonHeader.sourceLanguageTag, header.sourceLanguageTag);
      expect(jsonHeader.targetLanguages.length, header.targetLanguages.length);
      expect(jsonHeader.targetLanguages.contains(languageTagDe), isTrue);
      expect(jsonHeader.addedLanguageTags.contains(languageTagDe), isTrue);
      expect(jsonHeader.originalTargetLanguageTags.contains(languageTagDe),
          isFalse);
      expect(jsonHeader.originalTargetLanguageTags.length,
          header.originalTargetLanguageTags.length);
    });
  });

  group('MemeProject', () {
    test('Creation', () {
      var project = MemeProject('project 1');
      expect(project.header, isNull);
      expect(project.isValid, isFalse);
      expect(project.isEmpty, isTrue);
      expect(project.isNotEmpty, isFalse);
    });

    test('set header', () {
      var project = MemeProject('project 1');
      var headerDe = MemeHeader(languageTagDe, [languageTagIt, languageTagBr]);
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerDe;
      expect(project.isValid, isTrue);
      project.header = headerUs;
      expect(project.isValid, isTrue);
      expect(project.header.sourceLanguageTag, languageTagUs);
    });

    test('set term', () {
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      expect(() => project.insertTerm(term), throwsStateError);
      project.header = headerUs;

      project.insertTerm(term);
    });

    test('set language term', () {
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');
      expect(() => project.setLanguageTerm('0002', languageTagIt, 'Alto'),
          throwsArgumentError);
      expect(project.getTerm('0001').getLanguageTerm(languageTagIt), 'Ciao');
      project.removeTerm('0001');
      expect(project.isEmpty, isTrue);
    });

    test('toJson', () {
      var checkSource =
          '{"name":"project 1","header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"description":"first test",'
          '"idTerms":{"en-US":"Hello","it-IT":"Ciao"}}}}';
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');

      expect(json.encode(project), checkSource);
    });

    test('fromJson', () {
      var checkSource =
          '{"name":"project 1","header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","it-IT":"Ciao"}}}}';
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');

      var jsonProject = MemeProject.fromJson(json.decode(checkSource));

      expect(jsonProject.name, project.name);
      expect(jsonProject.isValid, isTrue);
      expect(jsonProject.isEmpty, isFalse);
      expect(jsonProject.header.sourceLanguageTag,
          project.header.sourceLanguageTag);
      expect(jsonProject.header.targetLanguages.length,
          project.header.targetLanguages.length);
      expect(jsonProject.getTerm('0001').getLanguageTerm(languageTagIt),
          project.getTerm('0001').getLanguageTerm(languageTagIt));
    });

    // Todo do more tests
  });

  group('Meme', () {
    test('Creation', () {
      var meme = Meme();
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      expect(meme.projectNames.length, 1);
      expect(meme.projectNames.first, 'project 1');
    });

    test('toJson', () {
      var checkSource = '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"description":"first test",'
          '"idTerms":{"en-US":"Hello"}}}}]';
      var meme = Meme();
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      expect(json.encode(meme), checkSource);
    });

    test('fromJson', () {
      var checkSource = '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","it-IT":"Ciao"}}}}]';
      var meme = Meme();
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');
      meme.addProject(project);

      var jsonMeme = Meme.fromJson(json.decode(checkSource));

      var jsonProject = jsonMeme.getProject('project 1');

      expect(jsonProject.name, project.name);
      expect(jsonProject.isValid, isTrue);
      expect(jsonProject.isEmpty, isFalse);
      expect(jsonProject.header.sourceLanguageTag,
          project.header.sourceLanguageTag);
      expect(jsonProject.header.targetLanguages.length,
          project.header.targetLanguages.length);
      expect(jsonProject.getTerm('0001').getLanguageTerm(languageTagIt),
          project.getTerm('0001').getLanguageTerm(languageTagIt));
    });

    test('encode', () {
      var checkSource = 'List<Map<String, dynamic>> meme = '
          '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"description":"first test",'
          '"idTerms":{"en-US":"Hello"}}}}];';
      var meme = Meme();
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      expect(meme.encode(), checkSource);
    });

    test('decode', () {
      var checkSource = 'List<Map<String, dynamic>> meme = '
          '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"description":"first test",'
          '"idTerms":{"en-US":"Hello"}}}}];';
      var meme = Meme();
      var project = MemeProject('project 1');
      var headerUs = MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      var term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
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
