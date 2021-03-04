class FlavorCollection {
  static const keySeparator = '#%';

  final List<String> _flavors;
  final String name;

  const FlavorCollection(this.name, List<String>? flavors)
      : _flavors = flavors ?? const <String>[];

  /// It is expected a Map with only one element
  factory FlavorCollection.fromJson(
      Map<String, List<String>> flavorCollection) {
    if (flavorCollection.keys.length != 1) {
      throw ArgumentError(
          'In the given list there are none or too much collection names');
    }
    var key = flavorCollection.keys.first;
    return FlavorCollection(flavorCollection.keys.first, flavorCollection[key]);
  }

  List<String> get collectionFlavors => _flavors;
  List<String> get flavors =>
      <String>[for (var flavor in _flavors) '$name.$flavor'];

  Map<String, List<String>> toJson() => {name: _flavors};

  void addCollectionFlavor(String flavor) => _flavors.add(flavor);
  void addCollectionFlavors(List<String> flavors) => _flavors.addAll(flavors);

  int getFlavorIndex(String flavor) => _flavors.indexOf(flavor);

  @override
  int get hashCode => '$name#${_flavors.join('#')}'.hashCode;

  @override
  bool operator ==(other) =>
      other is FlavorCollection &&
      name == other.name &&
      _flavors.join('#') == other._flavors.join('#');
}
