
//订阅者回调签名
typedef EventCallback = void Function(dynamic arg);

class LJEventBus {
  //私有构造函数
  LJEventBus._internal();

  //保存发送值
  final Map<String, dynamic> _valueMap = {};

  //保存单例
  static final LJEventBus _singleton = LJEventBus._internal();

  //工厂构造函数
  factory LJEventBus()=> _singleton;

  //保存事件订阅者队列，key:事件名(id)，value: 对应事件的订阅者队列
  final _eventMap = <Object, List<EventCallback>>{};

  //添加订阅者
  void on(eventName, EventCallback callback, {bool receiveWhenOn = false}) {
    if (eventName == null) return;
    _eventMap[eventName] ??= <EventCallback>[];
    _eventMap[eventName]?.add(callback);

    if (receiveWhenOn) {
      callback.call(_valueMap[eventName]);
    }
  }

  //移除订阅者
  void off(eventName, [EventCallback? callback]) {
    var list = _eventMap[eventName];
    if (eventName == null || list == null) return;
    if (callback == null) {
      _eventMap[eventName]?.clear();
    } else {
      list.remove(callback);
    }
  }

  //触发事件，事件触发后该事件所有订阅者会被调用
  void emit(eventName, [arg]) {
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