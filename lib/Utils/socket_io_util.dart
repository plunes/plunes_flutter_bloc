import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/resources/network/Urls.dart';

class SocketIoUtil {
  SocketIOManager _socketIOManager;
  SocketIO _socket;
  static const String insightTopic = "realtimeInsight";

  void initSocket() async {
    _socketIOManager = SocketIOManager();
    String _url =
        Urls.baseUrl + "?userId=" + UserManager().getUserDetails().uid;
    pprint("_url $_url");
    SocketOptions _socketOptions = SocketOptions(_url);
    _socket = await _socketIOManager.createInstance(_socketOptions);
    _socket.onConnect((data) {
      pprint("connected...");
      pprint(data);
    });
    _socket.onConnectError((data) => pprint(data));
    _socket.onConnectTimeout((data) => pprint(data));
    _socket.onError((data) => pprint(data));
    _socket.onDisconnect((data) => pprint("Disconnected $data"));
    _socket.on(insightTopic, (data) {
      pprint("msg from $insightTopic | $data");
      if (data != null) {
        EventProvider()
            .getSessionEventBus()
            .fire(ScreenRefresher(screenName: insightTopic));
      }
    });
    _socket.connect();
  }

  void dispose() {
    _socketIOManager?.clearInstance(_socket);
  }

  void pprint(String s) {
//    print("data $s");
  }
}
