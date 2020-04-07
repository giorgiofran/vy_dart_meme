import 'package:vy_dart_meme/src/element/flavor_collection.dart';

class MaleFemaleFlavor extends FlavorCollection {
  static const male = 'male';
  static const female = 'female';

  MaleFemaleFlavor() : super('MaleFemaleFlavor') {
    addCollectionFlavors([male, female]);
  }
}
