import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrollDirectionNotifier extends AsyncNotifier<Axis> {
  @override
  Future<Axis> build() async {
    final prefs = SharedPreferencesAsync();
    final isHorizontal = await prefs.getBool(AppUtils.scrollDirectionKey) ?? false;
    return isHorizontal ? Axis.horizontal : Axis.vertical;
  }

  Future<void> setScrollDirection(Axis direction) async {
    state = AsyncData(direction);
    final prefs = SharedPreferencesAsync();
    await prefs.setBool(AppUtils.scrollDirectionKey, direction == Axis.horizontal);
  }
}

final scrollDirectionProvider = AsyncNotifierProvider<ScrollDirectionNotifier, Axis>(
  ScrollDirectionNotifier.new,
);
