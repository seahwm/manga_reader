import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/provider/cache_size_provider.dart';
import 'package:manga_reader/provider/auto_crop_provider.dart';
import 'package:manga_reader/provider/scroll_direction_provider.dart';

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
    final autoCrop=ref.watch(autoCropProvider);
    final scrollDirection=ref.watch(scrollDirectionProvider);

    if (cacheSize.isLoading || autoCrop.isLoading || scrollDirection.isLoading) {
      return const Loading();
    }

    if (cacheSize.hasError) return Text('Error: ${cacheSize.error}');
    if (autoCrop.hasError) return Text('Error: ${autoCrop.error}');
    if (scrollDirection.hasError) return Text('Error: ${scrollDirection.error}');

    return _buildSettingScreen(cacheSize.value ?? 100, autoCrop.value ?? false, scrollDirection.value ?? Axis.vertical);
  }

  Widget _buildSettingScreen(int cacheSize, bool isAutoCrop, Axis scrollDir){
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

              // --- Reading Section ---
              _buildSectionHeader('Reading Settings'),
              SwitchListTile(
                title: const Text('Auto Crop Combined Pages'),
                subtitle: const Text('Automatically splits wide pages into right and left halves'),
                value: isAutoCrop,
                onChanged: (bool value) {
                  ref.read(autoCropProvider.notifier).setAutoCrop(value);
                },
              ),
              ListTile(
                title: const Text('Scroll Direction'),
                subtitle: const Text('Choose between vertical (continuous) or horizontal (paging) scrolling'),
                trailing: DropdownButton<Axis>(
                  value: scrollDir,
                  onChanged: (Axis? newValue) {
                    if (newValue != null) {
                      ref.read(scrollDirectionProvider.notifier).setScrollDirection(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Axis.vertical,
                      child: Text('Vertical'),
                    ),
                    DropdownMenuItem(
                      value: Axis.horizontal,
                      child: Text('Horizontal'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading) const Loading(),
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
