Future<String?> extractFcmToken({
  required Map<String, dynamic> result,
  required Map<String, dynamic> fallbackUser,
}) async {
  if (fallbackUser['fcmToken'] != null && fallbackUser['fcmToken'].toString().trim().isNotEmpty) {
    return fallbackUser['fcmToken'];
  }

  final apiUserData = result['data'];
  if (apiUserData != null && apiUserData is Map) {
    final casted = Map<String, dynamic>.from(apiUserData);
    return casted['fcmToken'];
  }

  return null;
}
