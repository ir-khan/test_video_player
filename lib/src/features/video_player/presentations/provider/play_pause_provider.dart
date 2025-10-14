import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'play_pause_provider.g.dart';

@riverpod
class PlayPauseProvider extends _$PlayPauseProvider {
  @override
  bool build() => false;

  void setValue(bool newValue) {
    state = newValue;
  }
}
