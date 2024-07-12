import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/csv_parser.dart';
import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/model/capi_small.dart';

class UserNotFoundException implements Exception {}

/// For times where you're gonna need to log in again.
class AuthorizationException implements Exception {}

class CapiClient {
  final http.Client _client;
  String _baseUri;
  String? _tokenWithBearer;

  bool isLoggedIn() => _tokenWithBearer != null;
  String getPathToImage(String hash) =>
      '$_baseUri/api/file/raw/$hash?size=100&crop=true';

  String get baseUri => _baseUri;
  set baseUri(String value) {
    if (value == _baseUri) return;

    _tokenWithBearer = null;
    _baseUri = value;
  }

  get _smallUri => "$_baseUri/api/small";
  Map<String, String>? get _authHeader =>
      _tokenWithBearer != null ? {'Authorization': _tokenWithBearer!} : null;

  CapiClient(this._baseUri) : _client = http.Client();

  void dispose() => _client.close();

  Future<void> fetchToken(String username, String password) async {
    final response = await _client.get(
      Uri.parse('$_smallUri/login'
          '?username=${Uri.encodeQueryComponent(username)}'
          '&password=${Uri.encodeQueryComponent(password)}'),
    );

    final passwordRegExp = RegExp(r'Password', caseSensitive: false);
    final userRegExp = RegExp(r'User', caseSensitive: false);

    await Future.delayed(const Duration(milliseconds: 300));
    _tokenWithBearer = switch (response.statusCode) {
      200 => 'Bearer ${response.body}',
      400 when response.body.contains(passwordRegExp) =>
        throw AuthorizationException(),
      404 when response.body.contains(userRegExp) =>
        throw UserNotFoundException(),
      _ => throw Exception(response.body),
    };
  }

  void forgetToken() {
    _tokenWithBearer = null;
  }

  Future<List<CapiSmall>> fetchSearchByName(String name) async {
    // be nice to api and don't let it spill out every single page ever made
    if (name.isEmpty) return [];

    final query = Uri.encodeComponent(name);

    final response = await _client.get(
      Uri.parse('$_smallUri/search' '?search=%25$query%25'),
      headers: _authHeader,
    );

    return switch (response.statusCode) {
      200 => CapiSmall.fromCsv(response.body),
      _ => throw Exception(),
    };
  }

  Future<List<CapiSmall>> fetchSearchById(int id) async {
    final response = await _client.get(
      Uri.parse('$_smallUri/search' '?id=$id'),
      headers: _authHeader,
    );

    return switch (response.statusCode) {
      200 => CapiSmall.fromCsv(response.body),
      _ => throw Exception(),
    };
  }

  Future<CapiProfile> fetchMe() async {
    final response = await _client.get(
      Uri.parse('$_smallUri/me'),
      headers: _authHeader,
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();
      return switch (parseCsv(body)) {
        [List<String> me] => CapiProfile.fromCsvRow(me),
        _ => throw Exception("invalid /small/me response"),
      };
    } else {
      throw Exception("failed to fetch self");
    }
  }

  Future<List<CapiSmall>> fetchChat({
    List<int> roomIds = const [0],
    int lastMessageId = -1,
    int getMessages = -30,
  }) async {
    assert(roomIds.isNotEmpty);
    final uri = Uri.parse('$_smallUri/chat'
        '?rooms=${roomIds.join(',')}'
        '&mid=$lastMessageId'
        '&get=$getMessages');
    final response = await _client.get(uri, headers: _authHeader);
    // print(response.body);

    return switch (response.statusCode) {
      200 => CapiSmall.fromCsv(response.body),
      _ => throw Exception("too lazy to figure out errors yet"),
    };
  }

  Stream<CapiSmall> streamChat({
    List<int> roomIds = const [0],
    int initialMessagesLength = 30,
  }) async* {
    var lastMessageId = -1;
    var messagesLength = -initialMessagesLength;

    while (true) {
      for (final small in await fetchChat(
        roomIds: roomIds,
        lastMessageId: lastMessageId,
        getMessages: messagesLength,
      )) {
        if (small.messageId != null && small.messageId! > lastMessageId) {
          lastMessageId = small.messageId!;
        }
        yield small;
      }
      messagesLength = 30;
    }
  }

  Future<void> postInChat({
    required int roomId,
    required String message,
    String markup = '12y2',
    String? avatar,
  }) async {
    final uri = Uri.parse([
      '$_smallUri/post/$roomId',
      '?values[m]=$markup',
      if (avatar != null) '&values[a]=$avatar',
      '&message=${Uri.encodeComponent(message)}',
    ].join());
    // print(uri);
    final response = await _client.get(uri, headers: _authHeader);
    if (response.statusCode != 200) throw Exception();
  }
}
