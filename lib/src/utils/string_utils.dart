

String checkDotsInName(String name) {
  if (name.contains('.')) {
    throw ArgumentError('Parameter "name" cannot contain dots');
  }
  return name;
}