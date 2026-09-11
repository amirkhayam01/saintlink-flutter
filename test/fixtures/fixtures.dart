import 'dart:convert';
import 'dart:io';

/// Real responses captured from `https://saintslink.co.uk/api/v1`.
///
/// Every `fromJson` is tested against one of these rather than against JSON
/// typed by hand, so a field the server names differently from what the app
/// expects fails here instead of on a customer's phone.
Map<String, dynamic> loadFixture(String name) {
  final file = File('test/fixtures/$name.json');

  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}
