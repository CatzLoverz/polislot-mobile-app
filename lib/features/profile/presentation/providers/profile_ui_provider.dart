import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_ui_provider.g.dart';

@riverpod
class ProfileSection extends _$ProfileSection {
  @override
  int build() {
    return 0; // Default 0: Menu Utama
  }

  void setSection(int index) {
    state = index;
  }
}