
typedef EventCallback = void Function(dynamic arg);

class LJEventBus {
  static final Map<String, dynamic> _valueMap = {};
  static final _eventMap = <Object, List<EventCallback>>{};

  //添加订阅者
  static void on(eventName, EventCallback callback, {bool receiveWhenOn = false}) {
    if (eventName == null) return;
    _eventMap[eventName] ??= <EventCallback>[];
    _eventMap[eventName]?.add(callback);

    if (receiveWhenOn) {
      callback.call(_valueMap[eventName]);
    }
  }

  //移除订阅者
  static void off(eventName, [EventCallback? callback]) {
    var list = _eventMap[eventName];
    if (eventName == null || list == null) return;
    if (callback == null) {
      _eventMap[eventName]?.clear();
    } else {
      list.remove(callback);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  static void emit(eventName, [arg]) {
    var list = _eventMap[eventName];
    if (list == null) return;
    _valueMap[eventName] = arg;
    int len = list.length - 1;
    //反向遍历，防止订阅者在回调中移除自身带来的下标错位
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}