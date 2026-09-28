import 'dart:convert';
import 'dart:developer' as developer;

/// Decodes a stored API response, returning null instead of throwing when the
/// row is missing or no longer matches the model (for example after an app
/// update changed a schema). History must always open.
T? decodeStored<T>(
  String? json,
  T Function(Map<String, dynamic>) fromJson, {
  required String what,
}) {
  if (json == null || json.isEmpty) return null;
  try {
    return fromJson(jsonDecode(json) as Map<String, dynamic>);
  } on Object catch (e) {
    developer.log('Stored $what could not be decoded: $e', name: 'kanz.db');
    return null;
  }
}

/// Encodes a model for storage.
String encodeStored(Map<String, dynamic> json) => jsonEncode(json);

/// '1,3,4' <-> {1, 3, 4}.
Set<int> decodeIntSet(String csv) => {
  for (final part in csv.split(',')) ?int.tryParse(part.trim()),
};

String encodeIntSet(Iterable<int> values) =>
    (values.toSet().toList()..sort()).join(',');
