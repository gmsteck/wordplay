import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/service/word_list_service.dart';

final wordValidationServiceProvider = Provider<WordValidationService>((ref) {
  final service = WordValidationService();
  service.loadWordList(); // load asynchronously when provider is initialized
  return service;
});
