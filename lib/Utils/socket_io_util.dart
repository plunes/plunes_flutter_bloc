//import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIoUtil {
//  SocketIOManager _socketIOManager;
//  SocketIO _socket;
  static const String insightTopic = "realtimeInsight";
  IO.Socket _socket;

  void initSocket() async {
    String _url =
        Urls.socketUrl + "?userId=" + UserManager().getUserDetails().uid;
    print("_url $_url");
    _socket = IO.io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.on("connect", (_) => pprint('Connected $_'));
    _socket.on("connect_error", (_) => pprint('connect_error $_'));
    _socket.on("connect_timeout", (_) => pprint('connect_timeout $_'));
    _socket.on("connecting", (_) => pprint('connecting $_'));
    _socket.on("disconnect", (_) => pprint('Disconnected $_'));

    _socket.on("error", (_) => pprint('error $_'));
    _socket.on("reconnect", (_) => pprint('reconnect $_'));
    _socket.on("reconnect_attempt", (_) => pprint('reconnect_attempt $_'));
    _socket.on("reconnect_failed", (_) => pprint('reconnect_failed $_'));

    _socket.on("reconnect_error", (_) => pprint('reconnect_error $_'));
    _socket.on("reconnecting", (_) => pprint('reconnecting $_'));
    _socket.on("ping", (_) => pprint('ping $_'));
    _socket.on("pong", (_) => pprint('pong $_'));
    _socket.on("disconnect", (_) => pprint('Disconnected $_'));
    _socket.on(insightTopic, (data) {
      pprint("insightTopic $data");
      if (data != null) {
        EventProvider()
            .getSessionEventBus()
            .fire(ScreenRefresher(screenName: insightTopic));
      }
    });
    _socket.connect();
    pprint("_socket ${_socket == null}");
//    _socket.onconnect();
  }

//  void initSocket() async {
//    _socketIOManager = SocketIOManager();
//    String _url =
//        Urls.baseUrl + "?userId=" + UserManager().getUserDetails().uid;
//    pprint("_url $_url");
//    SocketOptions _socketOptions = SocketOptions(_url);
//    _socket = await _socketIOManager.createInstance(_socketOptions);
//    _socket.onConnect((data) {
//      pprint("connected...");
//      pprint(data);
//    });
//    _socket.onConnectError((data) => pprint(data));
//    _socket.onConnectTimeout((data) => pprint(data));
//    _socket.onError((data) => pprint(data));
//    _socket.onDisconnect((data) => pprint("Disconnected $data"));
//    _socket.on(insightTopic, (data) {
//      pprint("msg from $insightTopic | $data");
//      if (data != null) {
//        EventProvider()
//            .getSessionEventBus()
//            .fire(ScreenRefresher(screenName: insightTopic));
//      }
//    });
//    _socket.connect();
//  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
//    _socketIOManager?.clearInstance(_socket);
  }

  void pprint(String s) {
    print("data $s");
  }
}
