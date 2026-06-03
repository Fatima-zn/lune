import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/local/storage_service.dart';
import '../main.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return storageService;
});