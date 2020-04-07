import 'dart:convert';

import 'package:vy_dart_meme/src/element/flavor_collection.dart';
import 'package:vy_dart_meme/src/flavor_collections/male_female_flavor.dart';
import 'package:vy_dart_meme/src/flavor_collections/plural_flavor.dart';
import 'package:vy_dart_meme/src/parts/meme_header.dart';
import 'package:vy_dart_meme/src/parts/meme_term.dart';
import 'package:test/test.dart';
import 'package:vy_language_tag/vy_language_tag.dart';

void main() {
  var languageTagUs = LanguageTag('en', region: 'US');
  var languageTagIt = LanguageTag('it', region: 'IT');
  var languageTagBr = LanguageTag('pt', region: 'BR');
  var languageTagFr = LanguageTag('fr', region: 'FR');
  var languageTagDe = LanguageTag('de', region: 'DE');

  group('MemeTerm test', () {
    setUp(() {});

    test('Creation', () {
      var languageTag = LanguageTag('en', region: 'US');

      var term = MemeTerm(languageTag, '0001', 'Hello');
      expect(term.sourceLanguageTag, languageTag);
      expect(term.getLanguageTerm(languageTag), 'Hello');
      expect(term.id, '0001');
      expect(term.languageTags.length, 1);
      expect(term.languageTags.first, languageTag);
    });
    test('Creation complete', () {
      var languageTag = LanguageTag('en', region: 'US');

      var term = MemeTerm(languageTag, '0001', 'Hello',
          flavorCollections: [MaleFemaleFlavor(), PluralFlavor()])
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];
      expect(term.sourceLanguageTag, languageTag);
      expect(term.getLanguageTerm(languageTag), 'Hello');
      expect(term.id, '0001');
      expect(term.languageTags.length, 1);
      expect(term.languageTags.first, languageTag);
      expect(term.description, 'Term Test');
      expect(term.relativeSourcePath, 'lib/src/term.dart');
      expect(term.exampleValues, ['No values']);
      expect(term.flavorCollections, [MaleFemaleFlavor(), PluralFlavor()]);
    });
    test('Creation complete with flavors', () {
      var languageTag = LanguageTag('en', region: 'US');

      var term = MemeTerm(languageTag, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor()
      ], sourceFlavorTerms: {
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}': 'Hey man!',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}': 'Hey woman!',
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}': 'Hey men!',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}': 'Hey women!',
      })
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];

      expect(term.sourceLanguageTag, languageTag);

      expect(term.flavorCollections, [MaleFemaleFlavor(), PluralFlavor()]);

      expect(
          term.containsLanguageFlavorTerm(
              term.sourceLanguageTag,
              '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
              '${PluralFlavor.singular}'),
          isTrue);
      expect(
          term.containsLanguageFlavorTerm(
              LanguageTag('pt', region: 'BR'),
              '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
              '${PluralFlavor.singular}'),
          isFalse);
      expect(
          term.getLanguageFlavorTerm(
              term.sourceLanguageTag,
              '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
              '${PluralFlavor.plural}'),
          'Hey women!');
      expect(term.getLanguageFlavorTerms(term.sourceLanguageTag), {
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}': 'Hey man!',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}': 'Hey woman!',
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}': 'Hey men!',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}': 'Hey women!',
      });
      expect(term.languageFlavorKeys(term.sourceLanguageTag), [
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}',
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}'
      ]);
    });

    test('Creation complete with flavors - errors', () {
      expect(
          () => MemeTerm(languageTagUs, '0001', 'Hello', sourceFlavorTerms: {
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey man!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey woman!',
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey men!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey women!',
              }),
          throwsArgumentError);
      expect(
          () => MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
                PluralFlavor()
              ], sourceFlavorTerms: {
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey man!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey woman!',
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey men!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey women!',
              }),
          throwsArgumentError);
      expect(
          () => MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
                PluralFlavor(),
                MaleFemaleFlavor()
              ], sourceFlavorTerms: {
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey man!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey woman!',
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey men!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey women!',
              }),
          throwsArgumentError);
      expect(
          () => MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
                MaleFemaleFlavor(),
                PluralFlavor()
              ], sourceFlavorTerms: {
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    'singulart': 'Hey man!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey woman!',
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey men!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey women!',
              }),
          throwsArgumentError);
      expect(
          () => MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
                MaleFemaleFlavor(),
                PluralFlavor(),
              ], sourceFlavorTerms: {
                '${MaleFemaleFlavor.male}': 'Hey man!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.singular}': 'Hey woman!',
                '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey men!',
                '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                    '${PluralFlavor.plural}': 'Hey women!',
              }),
          throwsArgumentError);
      expect(
          MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
            MaleFemaleFlavor(),
            PluralFlavor(),
          ], sourceFlavorTerms: {
            '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                '${PluralFlavor.singular}': 'Hey woman!',
            '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
                '${PluralFlavor.plural}': 'Hey men!',
            '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
                '${PluralFlavor.plural}': 'Hey women!',
          }),
          isNotNull);
    });

    test('Language term Insertion', () {
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(term.languageTags.length, 3);
      expect(term.sourceLanguageTag, languageTagUs);
      expect(term.containsLanguageTerm(languageTagUs), isTrue);
      expect(term.containsLanguageTerm(languageTagBr), isTrue);
      expect(term.containsLanguageTerm(languageTagFr), isFalse);

      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.id, '0001');

      term.insertLanguageTerm(languageTagFr, 'Salut');
      expect(term.languageTags.length, 4);
      expect(term.containsLanguageTerm(languageTagFr), isTrue);
      expect(term.containsLanguageTerm(languageTagIt), isTrue);
      expect(term.getLanguageTerm(languageTagFr), 'Salut');
    });

    test('Language term Flavor Insertion', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Saludos Amigos!'
      });
      expect(term.getLanguageFlavorTerms(languageTagUs), isNotEmpty);
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKeyTwo), 'Hello');

      expect(term.getLanguageFlavorTerms(languageTagIt), isEmpty);
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      expect(term.getLanguageFlavorTerms(languageTagIt), isEmpty);
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyOne, 'Ciao ragazzi!');
      expect(term.getLanguageFlavorTerms(languageTagIt), isNotEmpty);
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          'Ciao ragazzi!');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyTwo), 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi!');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');

      expect(term.getLanguageFlavorTerms(languageTagBr), isNotEmpty);
    });

    test('Language term Flavor Insertion Error', () {
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ]);
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      expect(term.getLanguageFlavorTerms(languageTagUs), isEmpty);
      expect(
          () => term.insertLanguageFlavorTerm(
              languageTagUs, flavorKeyOne, 'Hey men'),
          throwsStateError);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);

      term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Saludos Amigos!'
      });
      expect(
          () => term.insertLanguageFlavorTerm(
              languageTagIt, flavorKeyOne, 'Ciao ragazzi!'),
          throwsStateError);
      expect(
          () => term.insertLanguageFlavorTerm(
              languageTagIt, flavorKeyTwo, 'Ciao ragazzo!'),
          throwsStateError);
    });

    test('Language term Removal', () {
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(term.languageTags.length, 4);
      expect(term.containsLanguageTerm(languageTagFr), isTrue);
      term.removeLanguageTerm(languageTagFr);
      expect(term.languageTags.length, 3);
      expect(term.sourceLanguageTag, languageTagUs);
      expect(term.containsLanguageTerm(languageTagUs), isTrue);
      expect(term.containsLanguageTerm(languageTagBr), isTrue);
      expect(term.containsLanguageTerm(languageTagFr), isFalse);

      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.id, '0001');
      expect(term.getLanguageTerm(languageTagFr), isNull);
    });

    test('Language flavor term Removal', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Saludos Amigos!'
      });
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyTwo, 'Oi rapaz!');

      expect(term.getLanguageFlavorTerms(languageTagBr).length, 2);
      term.removeLanguageFlavorTerm(languageTagBr, flavorKeyTwo);
      expect(term.getLanguageFlavorTerms(languageTagBr).length, 1);
      expect(term.getLanguageFlavorTerm(languageTagBr, flavorKeyTwo), 'Oi');
      expect(term.getLanguageFlavorTerm(languageTagBr, flavorKeyOne),
          'Oi rapazes!');
    });

    test('Reset terms - new language Tag added', () {
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagDe]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(newTerm.getLanguageTerm(header.sourceLanguageTag),
          term.getLanguageTerm(header.sourceLanguageTag));
      expect(newTerm.languageTags.length, 3);
      expect(newTerm.containsLanguageTerm(languageTagFr), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagIt), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagDe), isFalse);
      expect(newTerm.getLanguageTerm(languageTagBr),
          term.getLanguageTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms with flavors - new language Tag added', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Hey Men!',
        flavorKeyTwo: 'Hey Man!'
      });
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyOne, 'Salut mec');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyTwo, 'Hé mec');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyOne, 'Ciao ragazzi!');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyTwo, 'Ciao ragazzo!');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(languageTagUs, [languageTagBr, languageTagIt],
          addedLanguageTags: [languageTagDe]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(newTerm.getLanguageFlavorTerms(header.sourceLanguageTag),
          term.getLanguageFlavorTerms(header.sourceLanguageTag));
      expect(newTerm.languageFlavorKeys(header.sourceLanguageTag).length, 2);
      expect(newTerm.containsLanguageFlavorTerm(languageTagFr, flavorKeyTwo),
          isFalse);
      expect(newTerm.containsLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          isTrue);
      expect(newTerm.containsLanguageFlavorTerm(languageTagDe, flavorKeyTwo),
          isFalse);
      expect(newTerm.getLanguageFlavorTerms(languageTagBr),
          term.getLanguageFlavorTerms(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms - language Tag removed', () {
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(languageTagUs, [languageTagBr]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(newTerm.getLanguageTerm(header.sourceLanguageTag),
          term.getLanguageTerm(header.sourceLanguageTag));
      expect(newTerm.languageTags.length, 2);
      expect(newTerm.containsLanguageTerm(languageTagFr), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagIt), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagBr), isTrue);
      expect(newTerm.getLanguageTerm(languageTagBr),
          term.getLanguageTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms with flavors - language Tag removed', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Hey Men!',
        flavorKeyTwo: 'Hey Man!'
      });
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyOne, 'Salut mec');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyTwo, 'Hé mec');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyOne, 'Ciao ragazzi!');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyTwo, 'Ciao ragazzo!');

      var header = MemeHeader(languageTagUs, [languageTagBr]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(newTerm.getLanguageTerm(header.sourceLanguageTag),
          term.getLanguageTerm(header.sourceLanguageTag));
      expect(newTerm.getLanguageFlavorTerms(header.sourceLanguageTag),
          term.getLanguageFlavorTerms(header.sourceLanguageTag));
      expect(newTerm.languageFlavorKeys(header.sourceLanguageTag).length, 2);
      expect(newTerm.containsLanguageFlavorTerm(languageTagFr, flavorKeyTwo),
          isFalse);
      expect(newTerm.containsLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          isFalse);
      expect(newTerm.getLanguageFlavorTerms(languageTagIt), isEmpty);
      expect(newTerm.containsLanguageFlavorTerm(languageTagDe, flavorKeyTwo),
          isFalse);
      expect(newTerm.getLanguageFlavorTerms(languageTagBr),
          term.getLanguageFlavorTerms(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms - source language change', () {
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(languageTagFr, [languageTagBr, languageTagIt]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, languageTagFr);
      expect(newTerm.getLanguageTerm(header.sourceLanguageTag),
          term.getLanguageTerm(languageTagFr));
      expect(newTerm.languageTags.length, 3);
      expect(term.languageTags.length, 4);
      expect(newTerm.containsLanguageTerm(languageTagFr), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagIt), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagDe), isFalse);
      expect(newTerm.getLanguageTerm(languageTagBr),
          term.getLanguageTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms with flavors source language change', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Hey Men!',
        flavorKeyTwo: 'Hey Man!'
      });
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyOne, 'Salut mec');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyTwo, 'Hé mec');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyOne, 'Ciao ragazzi!');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyTwo, 'Ciao ragazzo!');

      var header = MemeHeader(languageTagFr, [languageTagBr, languageTagIt]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.sourceLanguageTag, languageTagFr);
      expect(newTerm.getLanguageTerm(header.sourceLanguageTag),
          term.getLanguageTerm(languageTagFr));
      expect(newTerm.getLanguageFlavorTerms(header.sourceLanguageTag),
          term.getLanguageFlavorTerms(languageTagFr));
      expect(newTerm.languageFlavorKeys(header.sourceLanguageTag).length, 2);
      expect(newTerm.containsLanguageFlavorTerm(languageTagFr, flavorKeyTwo),
          isTrue);
      expect(newTerm.containsLanguageFlavorTerm(languageTagUs, flavorKeyTwo),
          isFalse);
      expect(newTerm.containsLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          isTrue);
      expect(newTerm.getLanguageFlavorTerms(languageTagBr),
          term.getLanguageFlavorTerms(languageTagBr));
      expect(newTerm.getLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          'Ciao ragazzi!');

      expect(newTerm.id, term.id);
    });
  });

  group('Serialization', () {
    test('toJson', () {
      var checkSource = '{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(json.encode(term), checkSource);
    });

    test('toJson Complete - No Flavors', () {
      var checkSource = '{"sourceLanguage":"en-US","id":'
          '"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},'
          '"idTerms":{"en-US":"Hello","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term = MemeTerm(languageTagUs, '0001', 'Hello',
          flavorCollections: [MaleFemaleFlavor(), PluralFlavor()])
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];

      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(json.encode(term), checkSource);
    });

    test('toJson Complete - With Flavors', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var checkSource = '{"sourceLanguage":"en-US","id":"0001",'
          '"relativeSourcePath":"lib/src/term.dart","description":"Term Test",'
          '"exampleValues":["No values"],"flavorCollections":'
          '{"MaleFemaleFlavor":["male","female"],"PluralFlavor":'
          '["singular","plural"]},"idTerms":{"en-US":"Hello","fr-FR":"Salut",'
          '"it-IT":"Ciao","pt-BR":"Oi"},"flavorTerms":{"en-US":'
          '{"male#%plural":"Hey Men!","male#%singular":"Hey Man!"},'
          '"fr-FR":{"male#%plural":"Salut mec","male#%singular":"Hé mec"},'
          '"it-IT":{"male#%plural":"Ciao ragazzi!","male#%singular":'
          '"Ciao ragazzo!"},"pt-BR":{"male#%plural":"Oi rapazes!"}}}';

      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Hey Men!',
        flavorKeyTwo: 'Hey Man!'
      })
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];

      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyOne, 'Salut mec');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyTwo, 'Hé mec');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyOne, 'Ciao ragazzi!');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyTwo, 'Ciao ragazzo!');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');

      expect(json.encode(term), checkSource);
    });

    test('fromJson', () {
      var checkSource = '{"sourceLanguage":"en-US","id":"0001",'
          '"idTerms":{"en-US":"Hello","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term = MemeTerm(languageTagUs, '0001', 'Hello');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      var jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));
    });
    test('fromJson Complete - No Flavors', () {
      var checkSource = '{"sourceLanguage":"en-US","id":'
          '"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},'
          '"idTerms":{"en-US":"Hello","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term = MemeTerm(languageTagUs, '0001', 'Hello',
          flavorCollections: [MaleFemaleFlavor(), PluralFlavor()])
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      var jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.relativeSourcePath, term.relativeSourcePath);
      expect(jsonTerm.exampleValues, term.exampleValues);
      expect(jsonTerm.flavorCollections, term.flavorCollections);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));
    });
    test('fromJson Complete - With Flavors', () {
      var checkSource = '{"sourceLanguage":"en-US","id":"0001",'
          '"relativeSourcePath":"lib/src/term.dart","description":"Term Test",'
          '"exampleValues":["No values"],"flavorCollections":'
          '{"MaleFemaleFlavor":["male","female"],"PluralFlavor":'
          '["singular","plural"]},"idTerms":{"en-US":"Hello","fr-FR":"Salut",'
          '"it-IT":"Ciao","pt-BR":"Oi"},"flavorTerms":{"en-US":'
          '{"male#%plural":"Hey Men!","male#%singular":"Hey Man!"},'
          '"fr-FR":{"male#%plural":"Salut mec","male#%singular":"Hé mec"},'
          '"it-IT":{"male#%plural":"Ciao ragazzi!","male#%singular":'
          '"Ciao ragazzo!"},"pt-BR":{"male#%plural":"Oi rapazes!"}}}';

      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, '0001', 'Hello', flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor()
      ], sourceFlavorTerms: {
        flavorKeyOne: 'Hey Men!',
        flavorKeyTwo: 'Hey Man!'
      })
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyOne, 'Salut mec');
      term.insertLanguageFlavorTerm(languageTagFr, flavorKeyTwo, 'Hé mec');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyOne, 'Ciao ragazzi!');
      term.insertLanguageFlavorTerm(
          languageTagIt, flavorKeyTwo, 'Ciao ragazzo!');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');
      var jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.relativeSourcePath, term.relativeSourcePath);
      expect(jsonTerm.exampleValues, term.exampleValues);
      expect(jsonTerm.flavorCollections, term.flavorCollections);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));

      expect(jsonTerm.sourceLanguageTag, term.sourceLanguageTag);
      expect(jsonTerm.getLanguageTerm(jsonTerm.sourceLanguageTag),
          term.getLanguageTerm(term.sourceLanguageTag));
      expect(jsonTerm.getLanguageFlavorTerms(jsonTerm.sourceLanguageTag),
          term.getLanguageFlavorTerms(term.sourceLanguageTag));
      expect(jsonTerm.languageFlavorKeys(jsonTerm.sourceLanguageTag).length, 2);
      expect(jsonTerm.containsLanguageFlavorTerm(languageTagFr, flavorKeyTwo),
          isTrue);
      expect(jsonTerm.containsLanguageFlavorTerm(languageTagUs, flavorKeyTwo),
          isTrue);
      expect(jsonTerm.containsLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          isTrue);
      expect(jsonTerm.getLanguageFlavorTerms(languageTagBr),
          term.getLanguageFlavorTerms(languageTagBr));
      expect(jsonTerm.getLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          'Ciao ragazzi!');
    });
  });
}
