import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/csv_parser.dart';
import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/model/capi_small.dart';

class UserNotFoundException implements Exception {}

/// For times where you're gonna need to log in again.
class AuthorizationException implements Exception {}

class CapiClient {
  String baseUri;
  http.Client client;
  String? tokenWithBearer;

  bool isLoggedIn() => tokenWithBearer != null;
  String getPathToImage(String hash) =>
      '$baseUri/api/file/raw/$hash?size=100&crop=true';

  get _smallUri => "$baseUri/api/small";
  Map<String, String>? get _authHeader =>
      tokenWithBearer != null ? {'Authorization': tokenWithBearer!} : null;

  CapiClient(this.baseUri) : client = http.Client();

  Future<void> fetchToken(String username, String password) async {
    final response = await client.get(
      Uri.parse('$_smallUri/login' '?username=$username&password=$password'),
    );

    final passwordRegExp = RegExp(r'Password', caseSensitive: false);
    final userRegExp = RegExp(r'User', caseSensitive: false);

    tokenWithBearer = switch (response.statusCode) {
      200 => 'Bearer ${response.body}',
      400 when response.body.contains(passwordRegExp) =>
        throw AuthorizationException(),
      404 when response.body.contains(userRegExp) =>
        throw UserNotFoundException(),
      _ => throw Exception(response.body),
    };
  }

  void forgetToken() {
    tokenWithBearer = null;
  }

  Future<List<CapiSmall>> fetchSearchByName(String query) async {
    // be nice to api and don't let it spill out every single page ever made
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse('$_smallUri/search' '?search=%25$query%25'),
      headers: _authHeader,
    );

    return switch (response.statusCode) {
      200 => CapiSmall.fromCsv(response.body),
      _ => throw Exception(),
    };
  }

  Future<List<CapiSmall>> fetchSearchById(int id) async {
    final response = await http.get(
      Uri.parse('$_smallUri/search' '?id=$id'),
      headers: _authHeader,
    );

    return switch (response.statusCode) {
      200 => CapiSmall.fromCsv(response.body),
      _ => throw Exception(),
    };
  }

  Future<CapiProfile> fetchMe() async {
    final response = await http.get(
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
    final response = await http.get(uri, headers: _authHeader);

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
}
