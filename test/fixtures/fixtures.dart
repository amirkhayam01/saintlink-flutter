import 'dart:convert';
import 'dart:io';

/// Real responses captured from the live API, so a renamed field fails here and not on a phone.
Map<String, dynamic> loadFixture(String name) {
  final file = File('test/fixtures/$name.json');

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}
