class ObjectPool<T> {
  final T Function() _create;
  final List<T> _available = [];
  final int _maxSize;
  
  ObjectPool({
    required T Function() create,
    int initialSize = 10,
    int maxSize = 50,
  }) : _create = create, _maxSize = maxSize {
    for (int i = 0; i < initialSize; i++) {
      _available.add(_create());
    }
  }
  
  T? obtain() {
    if (_available.isNotEmpty) {
      return _available.removeLast();
    }
    return _create();
  }
  
  void release(T object) {
    if (_available.length < _maxSize) {
      _available.add(object);
    }
  }
  
  void clear() {
    _available.clear();
  }
}
