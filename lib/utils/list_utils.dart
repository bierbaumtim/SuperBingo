int getMiddleIndex(Iterable list) {
  double middle = list.length / 2;
  if (middle % 2 != 0)
    return (middle - 0.5).truncate();
  else
    return middle.truncate();
}
