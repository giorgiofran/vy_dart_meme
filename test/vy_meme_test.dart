import 'dart:convert';

import 'package:vy_dart_meme/src/parts/meme_header.dart';
import 'package:vy_dart_meme/src/parts/meme_project.dart';
import 'package:vy_dart_meme/src/parts/meme_term.dart';
import 'package:test/test.dart';
import 'package:vy_dart_meme/vy_dart_meme.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

void main() {
  LanguageTag languageTagUs = LanguageTag('en', region: 'US');
  LanguageTag languageTagIt = LanguageTag('it', region: 'IT');
  LanguageTag languageTagBr = LanguageTag('pt', region: 'BR');
  LanguageTag languageTagFr = LanguageTag('fr', region: 'FR');
  LanguageTag languageTagDe = LanguageTag('de', region: 'DE');

  group('MemeHeader', () {
    test('Creation', () {
      MemeHeader header =
          MemeHeader(languageTagUs, [languageTagBr, languageTagIt]);
      expect(header.sourceLanguageTag, languageTagUs);
      expect(header.originalTargetLanguageTags.length, 2);
      expect(header.targetLanguages.length, 2);
      expect(header.targetLanguages.contains(languageTagIt), isTrue);
      expect(header.addedLanguageTags, isEmpty);
    });

    test('Creation with added languages', () {
      MemeHeader header = MemeHeader(
          languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagFr, languageTagDe]);
      expect(header.sourceLanguageTag, languageTagUs);
      expect(header.originalTargetLanguageTags.length, 2);
      expect(header.targetLanguages.length, 4);
      expect(header.targetLanguages.contains(languageTagFr), isTrue);
      expect(header.addedLanguageTags.length, 2);
    });

    test('toJson', () {
      String checkSource = '{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["pt-BR","it-IT"],'
          '"addedeLanguageTags":["fr-FR","de-DE"]}';
      MemeHeader header = MemeHeader(
          languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagFr, languageTagDe]);

      expect(json.encode(header), checkSource);
    });
    test('fromJson', () {
      String checkSource = '{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["pt-BR","it-IT"],'
          '"addedeLanguageTags":["fr-FR","de-DE"]}';
      MemeHeader header = MemeHeader(
          languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagFr, languageTagDe]);

      MemeHeader jsonHeader = MemeHeader.fromJson(json.decode(checkSource));

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
  group('MemeTerm test', () {
    setUp(() {});

    test('Creation', () {
      LanguageTag languageTag = LanguageTag('en', region: 'US');

      MemeTerm term = MemeTerm(languageTag, '0001', 'Hello');
      expect(term.sourceLanguageTag, languageTag);
      expect(term.getTerm(languageTag), 'Hello');
      expect(term.id, '0001');
      expect(term.languageTags.length, 1);
      expect(term.languageTags.first, languageTag);
    });
    test('Insertion', () {
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');

      expect(term.languageTags.length, 3);
      expect(term.sourceLanguageTag, languageTagUs);
      expect(term.containsLanguageTerm(languageTagUs), isTrue);
      expect(term.containsLanguageTerm(languageTagBr), isTrue);
      expect(term.containsLanguageTerm(languageTagFr), isFalse);

      expect(term.getTerm(languageTagIt), 'Ciao');
      expect(term.id, '0001');

      term.insertTerm(languageTagFr, 'Salut');
      expect(term.languageTags.length, 4);
      expect(term.containsLanguageTerm(languageTagFr), isTrue);
      expect(term.containsLanguageTerm(languageTagIt), isTrue);
      expect(term.getTerm(languageTagFr), 'Salut');
    });

    test('Removal', () {
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagFr, 'Salut');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');

      expect(term.languageTags.length, 4);
      expect(term.containsLanguageTerm(languageTagFr), isTrue);
      term.removeTerm(languageTagFr);
      expect(term.languageTags.length, 3);
      expect(term.sourceLanguageTag, languageTagUs);
      expect(term.containsLanguageTerm(languageTagUs), isTrue);
      expect(term.containsLanguageTerm(languageTagBr), isTrue);
      expect(term.containsLanguageTerm(languageTagFr), isFalse);

      expect(term.getTerm(languageTagIt), 'Ciao');
      expect(term.id, '0001');
      expect(term.getTerm(languageTagFr), isNull);
    });

    test('Reset terms - new language Tag added', () {
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagFr, 'Salut');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');

      MemeHeader header = MemeHeader(
          languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagDe]);
      MemeTerm newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(newTerm.getTerm(header.sourceLanguageTag),
          term.getTerm(header.sourceLanguageTag));
      expect(newTerm.languageTags.length, 3);
      expect(newTerm.containsLanguageTerm(languageTagFr), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagIt), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagDe), isFalse);
      expect(newTerm.getTerm(languageTagBr), term.getTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });
    test('Reset terms - language Tag removed', () {
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagFr, 'Salut');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');

      MemeHeader header = MemeHeader(languageTagUs, [languageTagBr]);
      MemeTerm newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(newTerm.getTerm(header.sourceLanguageTag),
          term.getTerm(header.sourceLanguageTag));
      expect(newTerm.languageTags.length, 2);
      expect(newTerm.containsLanguageTerm(languageTagFr), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagIt), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagBr), isTrue);
      expect(newTerm.getTerm(languageTagBr), term.getTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });
    test('Reset terms - source language change', () {
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagFr, 'Salut');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');

      MemeHeader header =
          MemeHeader(languageTagFr, [languageTagBr, languageTagIt]);
      MemeTerm newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, languageTagFr);
      expect(newTerm.getTerm(header.sourceLanguageTag),
          term.getTerm(languageTagFr));
      expect(newTerm.languageTags.length, 3);
      expect(term.languageTags.length, 4);
      expect(newTerm.containsLanguageTerm(languageTagFr), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagIt), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagDe), isFalse);
      expect(newTerm.getTerm(languageTagBr), term.getTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });
    test('toJson', () {
      String checkSource = '{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagFr, 'Salut');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');

      expect(json.encode(term), checkSource);
    });
    test('fromJson', () {
      String checkSource = '{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      MemeTerm term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertTerm(languageTagFr, 'Salut');
      term.insertTerm(languageTagIt, 'Ciao');
      term.insertTerm(languageTagBr, 'Oi');
      MemeTerm jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.getTerm(languageTagIt), term.getTerm(languageTagIt));
    });
  });

  group('MemeProject', () {
    test('Creation', () {
      MemeProject project = MemeProject('project 1');
      expect(project.header, isNull);
      expect(project.isValid, isFalse);
      expect(project.isEmpty, isTrue);
      expect(project.isNotEmpty, isFalse);
    });

    test('set header', () {
      MemeProject project = MemeProject('project 1');
      MemeHeader headerDe =
          MemeHeader(languageTagDe, [languageTagIt, languageTagBr]);
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerDe;
      expect(project.isValid, isTrue);
      project.header = headerUs;
      expect(project.isValid, isTrue);
      expect(project.header.sourceLanguageTag, languageTagUs);
    });

    test('set term', () {
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      expect(() => project.insertTerm(term), throwsStateError);
      project.header = headerUs;

      project.insertTerm(term);
    });

    test('set language term', () {
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');
      expect(() => project.setLanguageTerm('0002', languageTagIt, 'Alto'),
          throwsArgumentError);
      expect(project.getTerm('0001').getTerm(languageTagIt), 'Ciao');
      project.removeTerm('0001');
      expect(project.isEmpty, isTrue);
    });

    test('toJson', () {
      String checkSource =
          '{"name":"project 1","header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","it-IT":"Ciao"}}}}';
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');

      expect(json.encode(project), checkSource);
    });

    test('fromJson', () {
      String checkSource =
          '{"name":"project 1","header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","it-IT":"Ciao"}}}}';
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');

      MemeProject jsonProject = MemeProject.fromJson(json.decode(checkSource));

      expect(jsonProject.name, project.name);
      expect(jsonProject.isValid, isTrue);
      expect(jsonProject.isEmpty, isFalse);
      expect(jsonProject.header.sourceLanguageTag,
          project.header.sourceLanguageTag);
      expect(jsonProject.header.targetLanguages.length,
          project.header.targetLanguages.length);
      expect(jsonProject.getTerm('0001').getTerm(languageTagIt),
          project.getTerm('0001').getTerm(languageTagIt));
    });

    // Todo do more tests
  });

  group('Meme', () {
    test('Creation', () {
      Meme meme = Meme();
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      expect(meme.projectNames.length, 1);
      expect(meme.projectNames.first, 'project 1');
    });

    test('toJson', () {
      String checkSource = '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello"}}}}]';
      Meme meme = Meme();
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      expect(json.encode(meme), checkSource);
    });

    test('fromJson', () {
      String checkSource = '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello"}}}}]';
      Meme meme = Meme();
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      project.header = headerUs;
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.insertTerm(term);
      project.setLanguageTerm('0001', languageTagIt, 'Ciao');
      meme.addProject(project);

      Meme jsonMeme = Meme.fromJson(json.decode(checkSource));

      /*     expect(jsonProject.name, project.name);
      expect(jsonProject.isValid, isTrue);
      expect(jsonProject.isEmpty, isFalse);
      expect(jsonProject.header.sourceLanguageTag,
          project.header.sourceLanguageTag);
      expect(jsonProject.header.targetLanguages.length,
          project.header.targetLanguages.length);
      expect(jsonProject.getTerm('0001').getTerm(languageTagIt),
          project.getTerm('0001').getTerm(languageTagIt));*/
    });

    test('encode', () {
      String checkSource = 'List<Map<String, dynamic>> Meme = '
          '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello"}}}}];';
      Meme meme = Meme();
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      expect(meme.encode(), checkSource);
    });

    test('decode', () {
      String checkSource = 'List<Map<String, dynamic>> Meme = '
          '[{"name":"project 1",'
          '"header":{"sourceLanguageTag":"en-US",'
          '"originalTargetLanguageTags":["it-IT","pt-BR"]},'
          '"terms":{"0001":{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello"}}}}];';
      Meme meme = Meme();
      MemeProject project = MemeProject('project 1');
      MemeHeader headerUs =
          MemeHeader(languageTagUs, [languageTagIt, languageTagBr]);
      MemeTerm term = MemeTerm(headerUs.sourceLanguageTag, '0001', 'Hello')
        ..description = 'first test';
      project.header = headerUs;
      project.insertTerm(term);

      meme.addProject(project);

      Meme decodedMeme = Meme.decode(checkSource);

      expect(meme.projectNames.length, decodedMeme.projectNames.length);
      expect(meme.projectNames.first, decodedMeme.projectNames.first);
    });

    // Todo do more tests
  });
}
