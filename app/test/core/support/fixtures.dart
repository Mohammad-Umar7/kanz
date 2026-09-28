import 'dart:convert';
import 'dart:io';

/// Loads a contract fixture from `contracts/fixtures` (tests run from app/).
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('../contracts/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;
