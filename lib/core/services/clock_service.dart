import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that returns the current time [DateTime].
/// Can be easily overridden in tests to mock time-dependent logic.
final clockProvider = Provider<DateTime Function()>((ref) => () => DateTime.now());
