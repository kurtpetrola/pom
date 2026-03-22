import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the current time, can be overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => () => DateTime.now());
