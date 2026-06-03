import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniPlayerVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
}

final isMiniPlayerVisibleProvider = NotifierProvider<MiniPlayerVisibilityNotifier, bool>(
  () => MiniPlayerVisibilityNotifier(),
);