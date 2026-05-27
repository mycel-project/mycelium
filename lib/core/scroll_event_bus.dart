import 'dart:async';

class ScrollEventBus {
  final _controller = StreamController<int>.broadcast();
  Stream<int> get onScrollRequest => _controller.stream;
  void requestScroll(int offset) => _controller.add(offset);
}
