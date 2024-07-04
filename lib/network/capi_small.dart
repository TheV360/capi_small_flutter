import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/csv_parser.dart';
import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/model/capi_small.dart';

const capiBaseUri = "http://localhost:5147";
const capiSmallUri = "$capiBaseUri/api/small";

class UserNotFoundException implements Exception {}

/// For times where you're gonna need to log in again.
class AuthorizationException implements Exception {}

Future<String> fetchToken(String username, String password) async {
  final response = await http.get(
    Uri.parse('$capiSmallUri/login' '?username=$username&password=$password'),
  );

  if (response.statusCode == 200) {
    return response.body;
  } else if (response.statusCode == 400) {
    if (response.body.contains(RegExp('Password', caseSensitive: false))) {
      throw AuthorizationException();
    } else {
      throw Exception(response.body);
    }
  } else if (response.statusCode == 404) {
    if (response.body.contains(RegExp('User', caseSensitive: false))) {
      throw UserNotFoundException();
    } else {
      throw Exception(response.body);
    }
  } else {
    throw Exception("failed to fetch token on Dart's side");
  }
}

Future<List<CapiSmall>> fetchSearch(
  String query, {
  String? token,
}) async {
  // be nice to api and don't let it spill out every single page ever made
  if (query.isEmpty) return [];

  final response = await http.get(
    Uri.parse('$capiSmallUri/search' '?search=%25$query%25'),
    headers: (token != null)
        ? {
            'Authorization': 'Bearer $token',
          }
        : null,
  );

  if (response.statusCode == 200) {
    return CapiSmall.fromCsv(response.body);
  } else {
    throw Exception("failed to load");
  }
}

Future<CapiProfile> fetchMe({required String token}) async {
  final response = await http.get(Uri.parse('$capiSmallUri/me'), headers: {
    'Authorization': 'Bearer $token',
  });

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

String getPathToImage(String hash) =>
    '$capiBaseUri/api/file/raw/$hash?size=100&crop=true';
