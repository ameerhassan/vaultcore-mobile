abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final bool mockConnected;
  NetworkInfoImpl({this.mockConnected = true});

  @override
  Future<bool> get isConnected async => mockConnected;
}
