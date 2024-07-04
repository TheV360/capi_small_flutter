import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/model/capi_small.dart';

const capiBaseUri = "http://localhost:5147";
const capiSmallUri = "$capiBaseUri/api/small";

class UserNotFoundException implements Exception {}

/// For times where you're gonna need to log in again.
class AuthorizationException implements Exception {}

Future<String> fetchToken(
  String username,
  String password, {
  String? token,
}) async {
  final response = await http.get(
    Uri.parse('$capiSmallUri/login' '?username=$username&password=$password'),
    headers: (token != null)
        ? {
            'Authorization': 'Bearer $token',
          }
        : null,
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
  final response = await http.get(
    Uri.parse('$capiSmallUri/search' '?search=%25$query%25'),
    headers: (token != null)
        ? {
            'Authorization': 'Bearer $token',
          }
        : null,
  );

  await Future.delayed(const Duration(seconds: 2));
  if (response.statusCode == 200) {
    return CapiSmall.fromCsv(response.body);
  } else {
    throw Exception("failed to load");
  }
}
