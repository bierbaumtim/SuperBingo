/// Teilt die Länge der Liste durch 2.
/// Ist das Ergebnis ungrade wird um 0.5 verringert
/// ansonsten wird das Ergebnis zurückgegeben.
int getMiddleIndex(Iterable list) {
  assert(list != null);

  final middle = list.length / 2;
  if (middle % 2 != 0) {
    return (middle - 0.5).truncate();
  } else {
    return middle.truncate();
  }
}
