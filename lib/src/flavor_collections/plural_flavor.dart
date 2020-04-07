import 'package:vy_dart_meme/src/element/flavor_collection.dart';

class PluralFlavor extends FlavorCollection {
  static const singular = 'singular';
  static const plural = 'plural';

  const PluralFlavor() : super('PluralFlavor', const [singular, plural]);
}
