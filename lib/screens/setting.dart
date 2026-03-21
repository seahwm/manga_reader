import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/cache_size_provider.dart';

import '../utils/loading.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
   return _SettingsScreenState();
  }

}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // State for the slider (Page to cache)
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cacheSize=ref.watch(cacheSizeProvider);
    return cacheSize.when(
      // 只有第一次从 SharedPrefs 读取时会显示这个
        loading: () => const Loading(),
        // 读取失败的处理
        error: (err, stack) => Text('Error: $err'),
        // 一旦有了值（或者是之后的同步更新），都会走这里
        data: (size) =>  _buildSettingScreen(size)
    );
  }

  Widget _buildSettingScreen(int cacheSize){
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Stack(
        children: [
          ListView(
            children: [
              // --- Cache Section ---
              _buildSectionHeader('Cache Settings'),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pages to Cache',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cacheSize}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: cacheSize.toDouble(),
                      min: 20,
                      max: 300,
                      divisions: 70,
                      label: cacheSize.round().toString(),
                      onChanged: (double value) async {
                        ref.watch(cacheSizeProvider.notifier).setCacheSize(value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading) Loading(),
        ],
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
