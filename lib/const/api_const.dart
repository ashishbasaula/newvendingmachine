// ignore_for_file: constant_identifier_names

class ApiConst {
  static const BASE_URL = "http://192.168.18.7:3000";
  static const GET_ALL_USER = "$BASE_URL/api/machine/users";

  // Header
  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'x-api-key': 'abcd1234efgh5678',
  };
}
