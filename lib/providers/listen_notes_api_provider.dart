import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/remote/listen_notes_api.dart';

final listenNotesApiProvider = Provider<ListenNotesApi>((ref) {
  return ListenNotesApi();
});