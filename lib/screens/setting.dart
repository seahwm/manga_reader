import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_utils.dart';
import '../utils/loading.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State for the slider (Page to cache)
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Stack(
        children: [
          ListView(
            children: [
              // --- Database Section ---
              _buildSectionHeader('Database Management)'),

              ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                title: const Text('Clear All Database'),
                onTap: () async {
                  if (await confirm(
                    context,
                    content: Text('Are you sure want to delete all db record？'),
                  )) {
                    mangaBoc.deleteAll();
                  }
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.cleaning_services,
                  color: Colors.blueAccent,
                ),
                title: const Text('Clear Invalid Records'),
                onTap: () async {
                  setState(() {
                    _isLoading=true;
                  });
                  final rec = await mangaBoc.deleteInvalidRecords();

                  setState(() {
                    _isLoading=false;
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("deleted ${rec} records")));
                },
              ),

              const Divider(),

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
                            '${pagesToCache.round()}',
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
                      value: pagesToCache.toDouble(),
                      min: 20,
                      max: 300,
                      divisions: 70,
                      label: pagesToCache.round().toString(),
                      onChanged: (double value) async {
                        await SharedPreferences.getInstance().then(
                              (prefs) => prefs.setInt(AppUtils.cacheSize, value.toInt()),
                        );
                        setState(() {
                          pagesToCache = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Loading()
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
