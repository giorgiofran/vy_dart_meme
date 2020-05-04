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
      //var projectLanguages = <LanguageTag>{LanguageTag('en', region: 'US')};

      var term = MemeTerm(languageTag, 'Hello', '0001' /*, projectLanguages*/);
      expect(term.originalLanguageTag, languageTag);
      expect(term.getLanguageTerm(languageTag), 'Hello');
      term.insertLanguageTerm(languageTag, 'Hi');
      expect(term.getLanguageTerm(languageTag), 'Hi');
      term.removeLanguageTerm(languageTag);
      expect(term.getLanguageTerm(languageTag), 'Hello');
      // original term is not removed...
      term.removeLanguageTerm(languageTag);
      expect(term.getLanguageTerm(languageTag), 'Hello');

      expect(term.id, '0001');
      expect(term.languageTags.first, languageTagUs);
    });
    test('Creation complete', () {
      var languageTag = LanguageTag('en', region: 'US');
      //var projectLanguages = <LanguageTag>{LanguageTag('en', region: 'US')};

      var term = MemeTerm(languageTag, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [MaleFemaleFlavor(), PluralFlavor()])
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];
      expect(term.originalLanguageTag, languageTag);
      expect(term.getLanguageTerm(languageTag), 'Hello');
      expect(term.id, '0001');
      expect(term.languageTags.first, languageTagUs);
      //expect(term.languageTags.first, languageTag);
      expect(term.description, 'Term Test');
      expect(term.relativeSourcePath, 'lib/src/term.dart');
      expect(term.exampleValues, ['No values']);
      expect(term.flavorCollections, [MaleFemaleFlavor(), PluralFlavor()]);
    });
    test('Creation complete with flavors', () {
      var languageTag = LanguageTag('en', region: 'US');
      //var projectLanguages = <LanguageTag>{LanguageTag('en', region: 'US')};

      var term = MemeTerm(languageTag, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor()
      ], originalFlavorTerms: {
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

      expect(term.originalLanguageTag, languageTag);
      expect(term.flavorCollections, [MaleFemaleFlavor(), PluralFlavor()]);
      expect(
          term.containsLanguageFlavorTerm(
              term.originalLanguageTag,
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
              term.originalLanguageTag,
              '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
              '${PluralFlavor.plural}'),
          'Hey women!');
      expect(term.getLanguageFlavorTerms(term.originalLanguageTag), {
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}': 'Hey man!',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.singular}': 'Hey woman!',
        '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}': 'Hey men!',
        '${MaleFemaleFlavor.female}${FlavorCollection.keySeparator}'
            '${PluralFlavor.plural}': 'Hey women!',
      });
      var flavorKey = '${MaleFemaleFlavor.male}${FlavorCollection.keySeparator}'
          '${PluralFlavor.singular}';
      term.insertLanguageFlavorTerm(languageTagUs, flavorKey, 'Hi man!');
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKey), 'Hi man!');
      term.removeLanguageFlavorTerm(languageTag, flavorKey);
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKey), 'Hey man!');
      // original messages are not removed.
      term.removeLanguageFlavorTerm(languageTag, flavorKey);
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKey), 'Hey man!');

      expect(term.languageFlavorKeys(term.originalLanguageTag), [
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
      //var projectLanguages = <LanguageTag>{LanguageTag('en', region: 'US')};
      expect(
          () => MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
                  originalFlavorTerms: {
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
          () => MemeTerm(languageTagUs, '0001', 'Hello', /*projectLanguages,*/
                  flavorCollections: [
                PluralFlavor()
              ], originalFlavorTerms: {
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
          () => MemeTerm(languageTagUs, '0001', 'Hello', /*projectLanguages,*/
                  flavorCollections: [
                PluralFlavor(),
                MaleFemaleFlavor()
              ], originalFlavorTerms: {
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
          () => MemeTerm(languageTagUs, '0001', 'Hello', /*projectLanguages,*/
                  flavorCollections: [
                MaleFemaleFlavor(),
                PluralFlavor()
              ], originalFlavorTerms: {
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
          () => MemeTerm(languageTagUs, '0001', 'Hello', /*projectLanguages,*/
                  flavorCollections: [
                MaleFemaleFlavor(),
                PluralFlavor(),
              ], originalFlavorTerms: {
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
          MemeTerm(languageTagUs, '0001', 'Hello', /*projectLanguages,*/
              flavorCollections: [
            MaleFemaleFlavor(),
            PluralFlavor(),
          ], originalFlavorTerms: {
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
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/

      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(term.languageTags.length, 3);
      expect(term.originalLanguageTag, languageTagUs);
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
/*      var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ]);
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      expect(term.getLanguageFlavorTerms(languageTagIt), isEmpty);
      expect(
          () => term.insertLanguageFlavorTerm(
              languageTagIt, flavorKeyOne, 'Ciao ragazzi'),
          throwsStateError);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);

      term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(term.languageTags.length, 4);
      expect(term.containsLanguageTerm(languageTagFr), isTrue);
      term.removeLanguageTerm(languageTagFr);
      expect(term.languageTags.length, 3);
      expect(term.originalLanguageTag, languageTagUs);
      expect(term.containsLanguageTerm(languageTagUs), isTrue);
      expect(term.containsLanguageTerm(languageTagBr), isTrue);
      expect(term.containsLanguageTerm(languageTagFr), isFalse);

      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.id, '0001');
      expect(term.getLanguageTerm(languageTagFr), isNull);
    });

    test('Language flavor term Removal', () {
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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

    test('Original Language flavor term Removal', () {
/*      var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
        flavorKeyOne: 'Hey Men!'
      });
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      term.insertLanguageTerm(languageTagUs, 'Hi!');
      expect(
          term.getLanguageFlavorTerm(languageTagUs, flavorKeyOne), 'Hey Men!');

      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyOne, 'Oi rapazes!');
      term.insertLanguageFlavorTerm(languageTagBr, flavorKeyTwo, 'Oi rapaz!');
      term.insertLanguageFlavorTerm(languageTagUs, flavorKeyOne, 'Hi men!');
      expect(
          term.getLanguageFlavorTerm(languageTagUs, flavorKeyOne), 'Hi men!');
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKeyTwo), 'Hi!');

      term.removeLanguageFlavorTerm(languageTagUs, flavorKeyOne);
      expect(
          term.getLanguageFlavorTerm(languageTagUs, flavorKeyOne), 'Hey Men!');
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKeyTwo), 'Hi!');
      term.removeLanguageTerm(languageTagUs);
      expect(
          term.getLanguageFlavorTerm(languageTagUs, flavorKeyOne), 'Hey Men!');
      expect(term.getLanguageFlavorTerm(languageTagUs, flavorKeyTwo), 'Hello');

      expect(term.getLanguageFlavorTerms(languageTagBr).length, 2);
      term.removeLanguageFlavorTerm(languageTagBr, flavorKeyTwo);
      expect(term.getLanguageFlavorTerms(languageTagBr).length, 1);
      expect(term.getLanguageFlavorTerm(languageTagBr, flavorKeyTwo), 'Oi');
      expect(term.getLanguageFlavorTerm(languageTagBr, flavorKeyOne),
          'Oi rapazes!');
    });

    test('Reset terms - new language Tag added', () {
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(
          languageTagUs, [languageTagBr, languageTagIt, languageTagDe]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.originalLanguageTag, term.originalLanguageTag);
      expect(newTerm.getLanguageTerm(header.originalLanguageTag),
          term.getLanguageTerm(header.originalLanguageTag));
      expect(newTerm.languageTags.length, 3);
      expect(newTerm.containsLanguageTerm(languageTagFr), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagIt), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagDe), isFalse);
      expect(newTerm.getLanguageTerm(languageTagBr),
          term.getLanguageTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms with flavors - new language Tag added', () {
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /* projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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

      var header = MemeHeader(
          languageTagUs, [languageTagBr, languageTagIt, languageTagDe]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.originalLanguageTag, term.originalLanguageTag);
      expect(newTerm.getLanguageFlavorTerms(header.originalLanguageTag),
          term.getLanguageFlavorTerms(header.originalLanguageTag));
      expect(newTerm.languageFlavorKeys(header.originalLanguageTag).length, 2);
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
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(languageTagUs, [languageTagBr]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.originalLanguageTag, term.originalLanguageTag);
      expect(newTerm.getLanguageTerm(header.originalLanguageTag),
          term.getLanguageTerm(header.originalLanguageTag));
      expect(newTerm.languageTags.length, 2);
      expect(newTerm.containsLanguageTerm(languageTagFr), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagIt), isFalse);
      expect(newTerm.containsLanguageTerm(languageTagBr), isTrue);
      expect(newTerm.getLanguageTerm(languageTagBr),
          term.getLanguageTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms with flavors - language Tag removed', () {
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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
      expect(newTerm.originalLanguageTag, term.originalLanguageTag);
      expect(newTerm.getLanguageTerm(header.originalLanguageTag),
          term.getLanguageTerm(header.originalLanguageTag));
      expect(newTerm.getLanguageFlavorTerms(header.originalLanguageTag),
          term.getLanguageFlavorTerms(header.originalLanguageTag));
      expect(newTerm.languageFlavorKeys(header.originalLanguageTag).length, 2);
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
/*      var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      var header = MemeHeader(languageTagFr, [languageTagBr]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.originalLanguageTag, languageTagUs);
      expect(newTerm.getLanguageTerm(header.originalLanguageTag),
          term.getLanguageTerm(languageTagFr));
      expect(newTerm.languageTags.length, 3);
      expect(term.languageTags.length, 4);
      expect(newTerm.containsLanguageTerm(languageTagFr), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagUs), isTrue);
      expect(newTerm.containsLanguageTerm(languageTagIt), isFalse);
      expect(newTerm.getLanguageTerm(languageTagBr),
          term.getLanguageTerm(languageTagBr));
      expect(newTerm.id, term.id);
    });

    test('Reset terms with flavors source language change', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      /*     var projectLanguages = <LanguageTag>{
        languageTagUs,
        languageTagIt,
        languageTagBr,
        languageTagFr
      };*/
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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

      var header = MemeHeader(languageTagFr, [languageTagBr]);
      var newTerm = term.resetTerms(header);
      expect(newTerm.originalLanguageTag, languageTagUs);
      expect(newTerm.originalTerm, newTerm.getLanguageTerm(languageTagUs));

      expect(newTerm.getLanguageTerm(header.originalLanguageTag),
          term.getLanguageTerm(languageTagFr));
      expect(newTerm.getLanguageFlavorTerms(header.originalLanguageTag),
          term.getLanguageFlavorTerms(languageTagFr));
      expect(newTerm.languageFlavorKeys(header.originalLanguageTag).length, 2);
      expect(newTerm.containsLanguageFlavorTerm(languageTagFr, flavorKeyTwo),
          isTrue);
      expect(newTerm.containsLanguageFlavorTerm(languageTagUs, flavorKeyTwo),
          isTrue);
      expect(newTerm.containsLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          isFalse);
      expect(newTerm.getLanguageFlavorTerms(languageTagBr),
          term.getLanguageFlavorTerms(languageTagBr));
      /*     expect(newTerm.getLanguageFlavorTerm(languageTagIt, flavorKeyOne),
          'Ciao ragazzi!');*/

      expect(newTerm.id, term.id);
    });
  });

  group('MemeTerm merge test - term only', () {
    var headerUsIt = MemeHeader(languageTagUs, [languageTagIt]);
    var headerItUs = MemeHeader(languageTagIt, [languageTagUs]);
    var headerUsFr = MemeHeader(languageTagUs, [languageTagFr]);
    var headerUsItFr =
        MemeHeader(languageTagUs, [languageTagIt, languageTagFr]);
    var headerFrDeIt =
        MemeHeader(languageTagFr, [languageTagDe, languageTagIt]);
    MemeTerm testTerm, term, toBeMergedTerm;

    setUp(() {});

    test('Merge equal terms only original', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm =
          MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);

      expect(term.id, '0001');
    });
    test('Merge equal terms only original language, different terms', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hi', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);

      expect(term.id, '0001');
    });
    test('Merge different terms, different id', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hi', '0002');

      expect(() => testTerm.mergeTerm(headerUsIt, toBeMergedTerm),
          throwsArgumentError);
      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm,
          forceDifferentIds: true);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);

      expect(term.id, '0001');
    });
    test('Merge equal terms only original - to be merged with translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hi');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), 'Hi');

      expect(term.id, '0001');
    });
    test('Merge equal terms only original - both with translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi!');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hi!');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), 'Hi!');

      expect(term.id, '0001');
    });
    test('Merge equal terms only original - this with translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi!');
      toBeMergedTerm =
          MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hi!');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), 'Hi!');

      expect(term.id, '0001');
    });

    test('Merge equal terms with italian translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao!');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(
          term.translation(languageTagIt), term.getLanguageTerm(languageTagIt));
    });
    test('Merge equal terms, this has italian translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(
          term.translation(languageTagIt), term.getLanguageTerm(languageTagIt));
    });
    test('Merge equal terms, to be  merged has the italian translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao!');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao!');
      expect(
          term.translation(languageTagIt), term.getLanguageTerm(languageTagIt));
    });

    test(
        'Merge equal terms, to be  merged has the portuguese translation'
        'but header does not manage it', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagBr, 'Oi!');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagBr), isNull);
    });

    test('This has an italian translation, to be merged a french one', () {
      testTerm = MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
            ..insertLanguageTerm(languageTagFr, 'Salut!');

      term = testTerm.mergeTerm(headerUsItFr, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsItFr.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.translation(headerUsItFr.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(headerUsItFr.originalLanguageTag), 'Hello');
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.getLanguageTerm(languageTagFr), 'Salut!');
      expect(term.translations.length, 2);
      expect(
          term.translation(languageTagFr), term.getLanguageTerm(languageTagFr));
    });
    test('both have italian and french translation', () {
      term = MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao')
        ..insertLanguageTerm(languageTagFr, 'Salut');
      toBeMergedTerm =
          MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
            ..insertLanguageTerm(languageTagIt, 'Ciao!')
            ..insertLanguageTerm(languageTagFr, 'Salut!');

      term.mergeTerm(headerUsItFr, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsItFr.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsItFr.originalLanguageTag), 'Hello');
      expect(term.translations.length, 2);
      expect(term.translation(headerUsItFr.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(
          term.translation(languageTagIt), term.getLanguageTerm(languageTagIt));
      expect(term.getLanguageTerm(languageTagFr), 'Salut');
      expect(
          term.translation(languageTagFr), term.getLanguageTerm(languageTagFr));
    });
    test(
        'This has an italian translation, to be merged a french one'
        'but header does not manage italian', () {
      testTerm = MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
            ..insertLanguageTerm(languageTagFr, 'Salut!');

      term = testTerm.mergeTerm(headerUsFr, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsItFr.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.translation(headerUsItFr.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(headerUsItFr.originalLanguageTag), 'Hello');
      expect(term.getLanguageTerm(languageTagIt), null);
      expect(term.getLanguageTerm(languageTagFr), 'Salut!');
      expect(term.translations.length, 1);
      expect(
          term.translation(languageTagFr), term.getLanguageTerm(languageTagFr));
    });

    test('Merge terms with different original language. Header = this one', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerItUs.originalLanguageTag, 'Ciao', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
    });

    test(
        'Merge terms with different original language. '
        'Header = to be merged one', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerItUs.originalLanguageTag, 'Ciao', '0001');

      term = testTerm.mergeTerm(headerItUs, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
    });
    test(
        'Merge terms with different original language. '
        'Header = to be merged one, new header does not contain '
        'this original language', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerFrDeIt.originalLanguageTag, 'Salut', '0001')
            ..insertLanguageTerm(languageTagDe, 'Hallo');

      term = testTerm.mergeTerm(headerFrDeIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations.length, 3);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.getLanguageTerm(languageTagFr), 'Salut');
      expect(term.getLanguageTerm(languageTagDe), 'Hallo');
    });
  });

  group('MemeTerm merge test - with flavor keys', () {
    var headerUsIt = MemeHeader(languageTagUs, [languageTagIt]);
    var headerItUs = MemeHeader(languageTagIt, [languageTagUs]);
    var headerUsFr = MemeHeader(languageTagUs, [languageTagFr]);
    var headerUsItFr =
        MemeHeader(languageTagUs, [languageTagIt, languageTagFr]);
    var headerFrDeIt =
        MemeHeader(languageTagFr, [languageTagDe, languageTagIt]);
    MemeTerm testTerm, term, toBeMergedTerm;
    var flavorCollection = <FlavorCollection>[
      MaleFemaleFlavor(),
      PluralFlavor()
    ];
    var flavorKeyMalePlural = [MaleFemaleFlavor.male, PluralFlavor.plural]
        .join(FlavorCollection.keySeparator);
    var flavorKeyMaleSingular = [MaleFemaleFlavor.male, PluralFlavor.singular]
        .join(FlavorCollection.keySeparator);
    var flavorKeyFemalePlural = [MaleFemaleFlavor.female, PluralFlavor.plural]
        .join(FlavorCollection.keySeparator);
    var flavorKeyFemaleSingular = [
      MaleFemaleFlavor.female,
      PluralFlavor.singular
    ].join(FlavorCollection.keySeparator);
    setUp(() {});

    test('Merge equal - flavor terms only original', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyFemaleSingular: 'Hey woman!',
            flavorKeyMalePlural: 'Hey men!',
            flavorKeyFemalePlural: 'Hey women!'
          });
      toBeMergedTerm =
          MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.id, '0001');
      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.originalFlavorTerms?.length, 4);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          isNull);
    });
    test(
        'Merge equal - flavor collection defined - '
        'flavor terms only original', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyFemaleSingular: 'Hey woman!',
            flavorKeyMalePlural: 'Hey men!',
            flavorKeyFemalePlural: 'Hey women!'
          });
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection);

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.id, '0001');
      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.originalFlavorTerms?.length, 4);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          isNull);
    });
    test('Merge equal - flavor terms only to be merged', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyFemaleSingular: 'Hey woman!',
            flavorKeyMalePlural: 'Hey men!',
            flavorKeyFemalePlural: 'Hey women!'
          });

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hello');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          isNull);
    });
    test(
        'Merge equal - flavor collection defined - '
        'flavor terms only to be merged', () {
      testTerm = MemeTerm(
        headerUsIt.originalLanguageTag,
        'Hello',
        '0001',
        flavorCollections: flavorCollection,
      );
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyFemaleSingular: 'Hey woman!',
            flavorKeyMalePlural: 'Hey men!',
            flavorKeyFemalePlural: 'Hey women!'
          });

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
    });
    test('Merge equal - different flavor terms', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          });
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          });

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMaleSingular),
          isNull);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMaleSingular),
          'Hi man!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyFemaleSingular),
          isNull);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyFemaleSingular),
          'Hi woman!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          isNull);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          'Hello');
    });

    test('Merge equal terms - to be merged with translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          });
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          })
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          isNull);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          'Hi');
    });

    test('Merge equal terms - both with translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          })
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi!');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          })
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          isNull);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          'Hi!');
    });
    test('Merge equal terms - this with translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          })
        ..insertLanguageTerm(headerUsIt.originalLanguageTag, 'Hi!');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          });

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyMalePlural),
          'Hey men!');
      expect(
          term.flavorTranslation(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          isNull);
      expect(
          term.getLanguageFlavorTerm(
              headerUsIt.originalLanguageTag, flavorKeyFemalePlural),
          'Hi!');
    });

    test('Merge equal terms with italian translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          })
        ..insertLanguageTerm(languageTagIt, 'Ciao')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyMaleSingular, 'Ciao ragazzo')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyMalePlural, 'Ciao ragazzi');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          })
        ..insertLanguageTerm(languageTagIt, 'Ciao!')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyMaleSingular, 'Ciao ragazzo!')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyFemaleSingular, 'Ciao ragazza');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.flavorTranslation(languageTagIt, flavorKeyMaleSingular),
          'Ciao ragazzo');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyMaleSingular),
          'Ciao ragazzo');
      expect(term.flavorTranslation(languageTagIt, flavorKeyFemaleSingular),
          'Ciao ragazza');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyFemaleSingular),
          'Ciao ragazza');
      expect(term.flavorTranslation(languageTagIt, flavorKeyMalePlural),
          'Ciao ragazzi');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyMalePlural),
          'Ciao ragazzi');
      expect(
          term.flavorTranslation(languageTagIt, flavorKeyFemalePlural), isNull);
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyFemalePlural),
          'Ciao');
    });
    test('Merge equal terms, this has italian translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          })
        ..insertLanguageTerm(languageTagIt, 'Ciao')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyMaleSingular, 'Ciao ragazzo!')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyFemaleSingular, 'Ciao ragazza');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          });

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.flavorTranslation(languageTagIt, flavorKeyMaleSingular),
          'Ciao ragazzo!');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyMaleSingular),
          'Ciao ragazzo!');
      expect(term.flavorTranslation(languageTagIt, flavorKeyFemaleSingular),
          'Ciao ragazza');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyFemaleSingular),
          'Ciao ragazza');
      expect(term.flavorTranslation(languageTagIt, flavorKeyMalePlural),
          isNull);
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyMalePlural),
          'Ciao');
      expect(
          term.flavorTranslation(languageTagIt, flavorKeyFemalePlural), isNull);
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyFemalePlural),
          'Ciao');
    });
    test('Merge equal terms, to be  merged has the italian translation', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hi man!',
            flavorKeyFemaleSingular: 'Hi woman!'
          });
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001',
          flavorCollections: flavorCollection,
          originalFlavorTerms: {
            flavorKeyMaleSingular: 'Hey man!',
            flavorKeyMalePlural: 'Hey men!'
          })
        ..insertLanguageTerm(languageTagIt, 'Ciao!')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyMaleSingular, 'Ciao ragazzo!')
        ..insertLanguageFlavorTerm(
            languageTagIt, flavorKeyFemaleSingular, 'Ciao ragazza');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.flavorTranslation(languageTagIt, flavorKeyMaleSingular),
          'Ciao ragazzo!');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyMaleSingular),
          'Ciao ragazzo!');
      expect(term.flavorTranslation(languageTagIt, flavorKeyFemaleSingular),
          'Ciao ragazza');
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyFemaleSingular),
          'Ciao ragazza');
      expect(
          term.flavorTranslation(languageTagIt, flavorKeyMalePlural), isNull);
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyMalePlural),
          'Ciao!');
      expect(
          term.flavorTranslation(languageTagIt, flavorKeyFemalePlural), isNull);
      expect(term.getLanguageFlavorTerm(languageTagIt, flavorKeyFemalePlural),
          'Ciao!');
    });

    // Tod to be developed yet
/*    test(
        'Merge equal terms, to be  merged has the portuguese translation'
        'but header does not manage it', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagBr, 'Oi!');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagBr), isNull);
    });

    test('This has an italian translation, to be merged a french one', () {
      testTerm = MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
            ..insertLanguageTerm(languageTagFr, 'Salut!');

      term = testTerm.mergeTerm(headerUsItFr, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsItFr.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.translation(headerUsItFr.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(headerUsItFr.originalLanguageTag), 'Hello');
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.getLanguageTerm(languageTagFr), 'Salut!');
      expect(term.translations.length, 2);
      expect(
          term.translation(languageTagFr), term.getLanguageTerm(languageTagFr));
    });
    test('both have italian and french translation', () {
      term = MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao')
        ..insertLanguageTerm(languageTagFr, 'Salut');
      toBeMergedTerm =
          MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
            ..insertLanguageTerm(languageTagIt, 'Ciao!')
            ..insertLanguageTerm(languageTagFr, 'Salut!');

      term.mergeTerm(headerUsItFr, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsItFr.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsItFr.originalLanguageTag), 'Hello');
      expect(term.translations.length, 2);
      expect(term.translation(headerUsItFr.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(
          term.translation(languageTagIt), term.getLanguageTerm(languageTagIt));
      expect(term.getLanguageTerm(languageTagFr), 'Salut');
      expect(
          term.translation(languageTagFr), term.getLanguageTerm(languageTagFr));
    });
    test(
        'This has an italian translation, to be merged a french one'
        'but header does not manage italian', () {
      testTerm = MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerUsItFr.originalLanguageTag, 'Hello', '0001')
            ..insertLanguageTerm(languageTagFr, 'Salut!');

      term = testTerm.mergeTerm(headerUsFr, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsItFr.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.translation(headerUsItFr.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(headerUsItFr.originalLanguageTag), 'Hello');
      expect(term.getLanguageTerm(languageTagIt), null);
      expect(term.getLanguageTerm(languageTagFr), 'Salut!');
      expect(term.translations.length, 1);
      expect(
          term.translation(languageTagFr), term.getLanguageTerm(languageTagFr));
    });

    test('Merge terms with different original language. Header = this one', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerItUs.originalLanguageTag, 'Ciao', '0001');

      term = testTerm.mergeTerm(headerUsIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
    });

    test(
        'Merge terms with different original language. '
        'Header = to be merged one', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001');
      toBeMergedTerm = MemeTerm(headerItUs.originalLanguageTag, 'Ciao', '0001');

      term = testTerm.mergeTerm(headerItUs, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations, isNotEmpty);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
    });
    test(
        'Merge terms with different original language. '
        'Header = to be merged one, new header does not contain '
        'this original language', () {
      testTerm = MemeTerm(headerUsIt.originalLanguageTag, 'Hello', '0001')
        ..insertLanguageTerm(languageTagIt, 'Ciao');
      toBeMergedTerm =
          MemeTerm(headerFrDeIt.originalLanguageTag, 'Salut', '0001')
            ..insertLanguageTerm(languageTagDe, 'Hallo');

      term = testTerm.mergeTerm(headerFrDeIt, toBeMergedTerm);

      expect(term.originalLanguageTag, headerUsIt.originalLanguageTag);
      expect(term.originalTerm, 'Hello');
      expect(term.getLanguageTerm(headerUsIt.originalLanguageTag), 'Hello');
      expect(term.translations.length, 3);
      expect(term.translation(headerUsIt.originalLanguageTag), isNull);
      expect(term.getLanguageTerm(languageTagIt), 'Ciao');
      expect(term.getLanguageTerm(languageTagFr), 'Salut');
      expect(term.getLanguageTerm(languageTagDe), 'Hallo');
    });*/
  });

  group('Serialization', () {
    test('toJson', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","idTerms":{"fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(json.encode(term), checkSource);
    });
    test('toJson with origin change', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","idTerms":{"en-US":"Hey","fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagUs, 'Hey');
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');

      expect(json.encode(term), checkSource);
    });

    test('toJson Complete - No Flavors', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},"idTerms":{"fr-FR":"Salut",'
          '"it-IT":"Ciao","pt-BR":"Oi"}}';
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
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
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},'
          '"originalFlavorTerms":{"male#%plural":"Hey Men!",'
          '"male#%singular":"Hey Man!"},'
          '"idTerms":{"fr-FR":"Salut","it-IT":"Ciao","pt-BR":"Oi"},'
          '"flavorTerms":{"fr-FR":{"male#%plural":"Salut mec",'
          '"male#%singular":"Hé mec"},"it-IT":{"male#%plural":"Ciao ragazzi!",'
          '"male#%singular":"Ciao ragazzo!"},'
          '"pt-BR":{"male#%plural":"Oi rapazes!"}}}';

      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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

    test('toJson Complete - With Flavors and origin change', () {
      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},'
          '"originalFlavorTerms":{"male#%plural":"Hey Men!",'
          '"male#%singular":"Hey Man!"},'
          '"idTerms":{"fr-FR":"Salut","it-IT":"Ciao","pt-BR":"Oi"},'
          '"flavorTerms":{"fr-FR":{"male#%plural":"Salut mec",'
          '"male#%singular":"Hé mec"},"it-IT":{"male#%plural":"Ciao ragazzi!",'
          '"male#%singular":"Ciao ragazzo!"},'
          '"pt-BR":{"male#%plural":"Oi rapazes!"},'
          '"en-US":{"male#%singular":"Hi man!"}}}';

      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor(),
      ], originalFlavorTerms: {
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
      expect(
          term.getLanguageFlavorTerm(languageTagUs, flavorKeyTwo), 'Hey Man!');
      term.insertLanguageFlavorTerm(languageTagUs, flavorKeyTwo, 'Hi man!');
      expect(
          term.getLanguageFlavorTerm(languageTagUs, flavorKeyTwo), 'Hi man!');

      expect(json.encode(term), checkSource);
    });

    test('fromJson', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","idTerms":{"fr-FR":"Salut","it-IT":"Ciao",'
          '"pt-BR":"Oi"}}';
      var term =
          MemeTerm(languageTagUs, 'Hello', '0001' /*, projectLanguages*/);
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      var jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.originalLanguageTag, term.originalLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));
    });
    test('fromJson Complete - No Flavors', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},"idTerms":{"fr-FR":"Salut",'
          '"it-IT":"Ciao","pt-BR":"Oi"}}';
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [MaleFemaleFlavor(), PluralFlavor()])
        ..description = 'Term Test'
        ..relativeSourcePath = 'lib/src/term.dart'
        ..exampleValues = ['No values'];
      term.insertLanguageTerm(languageTagFr, 'Salut');
      term.insertLanguageTerm(languageTagIt, 'Ciao');
      term.insertLanguageTerm(languageTagBr, 'Oi');
      var jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.originalLanguageTag, term.originalLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.relativeSourcePath, term.relativeSourcePath);
      expect(jsonTerm.exampleValues, term.exampleValues);
      expect(jsonTerm.flavorCollections, term.flavorCollections);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));
    });
    test('fromJson Complete - With Flavors', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},'
          '"originalFlavorTerms":{"male#%plural":"Hey Men!",'
          '"male#%singular":"Hey Man!"},'
          '"idTerms":{"fr-FR":"Salut","it-IT":"Ciao","pt-BR":"Oi"},'
          '"flavorTerms":{"fr-FR":{"male#%plural":"Salut mec",'
          '"male#%singular":"Hé mec"},"it-IT":{"male#%plural":"Ciao ragazzi!",'
          '"male#%singular":"Ciao ragazzo!"},'
          '"pt-BR":{"male#%plural":"Oi rapazes!"}}}';

      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor()
      ], originalFlavorTerms: {
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

      expect(jsonTerm.originalLanguageTag, term.originalLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.relativeSourcePath, term.relativeSourcePath);
      expect(jsonTerm.exampleValues, term.exampleValues);
      expect(jsonTerm.flavorCollections, term.flavorCollections);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));

      expect(jsonTerm.originalLanguageTag, term.originalLanguageTag);
      expect(jsonTerm.getLanguageTerm(jsonTerm.originalLanguageTag),
          term.getLanguageTerm(term.originalLanguageTag));
      expect(jsonTerm.getLanguageFlavorTerms(jsonTerm.originalLanguageTag),
          term.getLanguageFlavorTerms(term.originalLanguageTag));
      expect(
          jsonTerm.languageFlavorKeys(jsonTerm.originalLanguageTag).length, 2);
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
    test('fromJson Complete - With Flavors and origin change', () {
      var checkSource = '{"originalLanguageTag":"en-US","originalTerm":"Hello",'
          '"id":"0001","relativeSourcePath":"lib/src/term.dart",'
          '"description":"Term Test","exampleValues":["No values"],'
          '"flavorCollections":{"MaleFemaleFlavor":["male","female"],'
          '"PluralFlavor":["singular","plural"]},'
          '"originalFlavorTerms":{"male#%plural":"Hey Men!",'
          '"male#%singular":"Hey Man!"},'
          '"idTerms":{"fr-FR":"Salut","it-IT":"Ciao","pt-BR":"Oi"},'
          '"flavorTerms":{"fr-FR":{"male#%plural":"Salut mec",'
          '"male#%singular":"Hé mec"},"it-IT":{"male#%plural":"Ciao ragazzi!",'
          '"male#%singular":"Ciao ragazzo!"},'
          '"pt-BR":{"male#%plural":"Oi rapazes!"},'
          '"en-US":{"male#%singular":"Hi man!"}}}';

      var flavorKeyOne = [MaleFemaleFlavor.male, PluralFlavor.plural]
          .join(FlavorCollection.keySeparator);
      var flavorKeyTwo = [MaleFemaleFlavor.male, PluralFlavor.singular]
          .join(FlavorCollection.keySeparator);
      var term = MemeTerm(languageTagUs, 'Hello', '0001', /*projectLanguages,*/
          flavorCollections: [
        MaleFemaleFlavor(),
        PluralFlavor()
      ], originalFlavorTerms: {
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
      term.insertLanguageFlavorTerm(languageTagUs, flavorKeyTwo, 'Hi man!');

      var jsonTerm = MemeTerm.fromJson(json.decode(checkSource));

      expect(jsonTerm.originalLanguageTag, term.originalLanguageTag);
      expect(jsonTerm.description, term.description);
      expect(jsonTerm.relativeSourcePath, term.relativeSourcePath);
      expect(jsonTerm.exampleValues, term.exampleValues);
      expect(jsonTerm.flavorCollections, term.flavorCollections);
      expect(jsonTerm.getLanguageTerm(languageTagIt),
          term.getLanguageTerm(languageTagIt));

      expect(jsonTerm.originalLanguageTag, term.originalLanguageTag);
      expect(jsonTerm.getLanguageTerm(jsonTerm.originalLanguageTag),
          term.getLanguageTerm(term.originalLanguageTag));
      expect(jsonTerm.getLanguageFlavorTerms(jsonTerm.originalLanguageTag),
          term.getLanguageFlavorTerms(term.originalLanguageTag));
      expect(
          jsonTerm.languageFlavorKeys(jsonTerm.originalLanguageTag).length, 2);
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
