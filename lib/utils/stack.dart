import 'dart:collection';

class Stack<E> {
  Queue<E> _queue;

  Stack() {
    _queue = Queue<E>();
  }

  void add(E value) => _queue.addFirst(value);

  E remove() => _queue.removeFirst();

  void addAll(Iterable<E> elements) {
    for (var element in elements) {
      _queue.addFirst(element);
    }
  }

  E get first => _queue.first;
}
