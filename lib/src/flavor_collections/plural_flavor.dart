import 'package:vy_dart_meme/src/element/flavor_collection.dart';

class PluralFlavor extends FlavorCollection {
  static const singular = 'singular';
  static const plural = 'plural';

  PluralFlavor() : super('PluralFlavor') {
    addCollectionFlavors([singular, plural]);
  }
}
