import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/csv_parser.dart';
import 'package:capi_small_mvp/model/capi_instance_status.dart';
import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/model/capi_small.dart';

class UserNotFoundException implements Exception {}

/// For times where you're gonna need to log in again.
class AuthorizationException implements Exception {}

class CapiClient {
  final http.Client _client;
  String? _baseUri;
  String? _tokenWithBearer;

  CapiInstanceStatus? instanceStatus;
  CapiPageId? tempRoomId;

  bool isLoggedIn() => _tokenWithBearer != null;
  String getPathToImage(String hash) =>
      '$_baseUri/api/file/raw/$hash?size=100&crop=true';

  // aaagh TODO maybe replace all Uri.parse with Uri.replace
  // and change the type of baseUri to be Uri to match?
  String get baseUri {
    // mean to do??
    if (_baseUri == null) throw Exception("no base URI set!");
    return _baseUri!;
  }

  set baseUri(String value) {
    if (value == _baseUri) return;

    _tokenWithBearer = null;
    _baseUri = value;
  }

  get _smallUri => "$_baseUri/api/small";
  Map<String, String>? get _authHeader =>
      _tokenWithBearer != null ? {'Authorization': _tokenWithBearer!} : null;

  CapiClient() : _client = http.Client();

  void dispose() => _client.close();

  Future<void> fetchAndSaveInstanceStatus(Uri instance) async {
    final candidateBaseUri = instance.toString();

    final uri = Uri.parse('$candidateBaseUri/api/Status');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    instanceStatus = CapiInstanceStatus.fromJson(data);
    baseUri = candidateBaseUri;
  }

  Future<void> fetchAndSaveToken(String username, String password) async {
    final query = {'username': username, 'password': password};
    final uri = Uri.parse('$_smallUri/login').replace(queryParameters: query);
    final response = await _client.get(uri);

    final passwordRegExp = RegExp(r'Password', caseSensitive: false);
    final userRegExp = RegExp(r'User', caseSensitive: false);

    // await Future.delayed(const Duration(milliseconds: 2000));
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

    final query = {'search': '"$name"'};
    final response = await _client.get(
      Uri.parse('$_smallUri/search').replace(queryParameters: query),
      headers: _authHeader,
    );

    return switch (response.statusCode) {
      200 => CapiSmall.fromCsv(response.body),
      _ => throw Exception(),
    };
  }

  Future<List<CapiSmall>> fetchSearchById(int id) async {
    final query = {'id': '$id'};
    final response = await _client.get(
      Uri.parse('$_smallUri/search').replace(queryParameters: query),
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

  /// Fetches messages using a "last message ID" as a sort of reference point.
  /// If it's -1, it represents the last message. The default parameters will
  /// return the last 30 messages in the room, represented by `-30`, meaning
  /// 30 messages before `lastMessageId`. It may return less than the requested
  /// number, or an empty list, if the room doesn't have as many messages.
  ///
  /// this is incomplete docs lol
  Future<List<CapiSmall>> fetchChat({
    final List<int> roomIds = const [0],
    final int lastMessageId = -1,
    final int messagesToGet = -30,
  }) async {
    assert(roomIds.isNotEmpty);
    final query = {
      if (roomIds.isNotEmpty) 'rooms': roomIds.join(','),
      'mid': '$lastMessageId',
      'get': '$messagesToGet',
    };
    final uri = Uri.parse('$_smallUri/chat').replace(queryParameters: query);
    final response = await _client.get(uri, headers: _authHeader);

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      return CapiSmall.fromCsv(body);
    } else {
      throw Exception("too lazy to figure out errors yet");
    }
  }

  Stream<CapiSmall> streamChat({
    final List<int> roomIds = const [0],
    int lastMessageId = -1,
  }) async* {
    while (true) {
      for (final small in await fetchChat(
        roomIds: roomIds,
        lastMessageId: lastMessageId,
        messagesToGet: 30,
      )) {
        if (small.messageId != null && small.messageId! > lastMessageId) {
          lastMessageId = small.messageId!;
        }
        yield small;
      }
    }
  }

  /// Stream chat after fetching the first number of messages for context.
  Stream<CapiSmall> fetchAndStreamChat({
    final List<int> roomIds = const [0],
    final int contextMessagesToGet = 30,
  }) async* {
    final chat = await fetchChat(
      roomIds: roomIds,
      messagesToGet: -contextMessagesToGet.abs(),
    );
    for (CapiSmall small in chat) {
      yield small;
    }
    yield* streamChat(roomIds: roomIds);
  }

  Future<void> postInChat({
    required final int roomId,
    required final String message,
    final String markup = '12y2',
    final String? avatar,
  }) async {
    final query = {
      'values[m]': markup,
      if (avatar != null) 'values[a]': avatar,
      'message': message
    };
    final uri =
        Uri.parse('$_smallUri/post/$roomId').replace(queryParameters: query);

    final response = await _client.get(uri, headers: _authHeader);
    if (response.statusCode != 200) throw Exception();

    print(response);
  }
}
