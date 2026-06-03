import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/storage_provider.dart';

final favoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getFavorites();
});