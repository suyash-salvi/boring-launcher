import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../apps/presentation/app_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _exitTimer;
  double _exitProgress = 0.0;
  bool _isExiting = false;

  @override
  void dispose() {
    _searchController.dispose();
    _exitTimer?.cancel();
    super.dispose();
  }

  void _startExitTimer() {
    setState(() {
      _isExiting = true;
      _exitProgress = 0.0;
    });
    _exitTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _exitProgress += 0.01; // 1% per 100ms = 10% per second
      });
      if (_exitProgress >= 1.0) {
        timer.cancel();
        _exitLauncher();
      }
    });
  }

  void _stopExitTimer() {
    _exitTimer?.cancel();
    setState(() {
      _isExiting = false;
      _exitProgress = 0.0;
    });
  }

  void _exitLauncher() {
    // This allows the user to switch back to their default launcher
    // by triggering the Android home selector.
    SystemNavigator.pop();
  }

  void _showExitInstruction() {
    Fluttertoast.showToast(
      msg: "Press for 10 seconds to exit or change the launcher",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appList = ref.watch(appListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Apps', style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white70),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: _showExitInstruction,
              onLongPressStart: (_) => _startExitTimer(),
              onLongPressEnd: (_) => _stopExitTimer(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isExiting)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: _exitProgress,
                        color: Colors.redAccent,
                      ),
                    ),
                  const Icon(Icons.exit_to_app, color: Colors.white38),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white70),
              cursorColor: Colors.white38,
              decoration: InputDecoration(
                hintText: 'Search apps to configure...',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.search, color: Colors.white24, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white38, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ) 
                  : null,
              ),
            ),
          ),
        ),
      ),
      body: appList.when(
        data: (apps) {
          final filteredApps = apps.where((a) => 
            a.appName.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

          if (filteredApps.isEmpty) {
            return const Center(child: Text('No apps found', style: TextStyle(color: Colors.white24)));
          }

          return ListView.builder(
            itemCount: filteredApps.length,
            itemBuilder: (context, index) {
              final app = filteredApps[index];
              return ListTile(
                title: Text(app.appName, style: const TextStyle(color: Colors.white70)),
                subtitle: Text(app.packageName, style: const TextStyle(color: Colors.white24, fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        app.isAllowed ? Icons.visibility : Icons.visibility_off_outlined,
                        color: app.isAllowed ? Colors.white70 : Colors.white24,
                      ),
                      onPressed: () => ref.read(appListProvider.notifier).toggleAllowed(app.packageName),
                      tooltip: 'Show on Home',
                    ),
                    IconButton(
                      icon: Icon(
                        app.isDistracting ? Icons.warning : Icons.warning_amber_outlined,
                        color: app.isDistracting ? Colors.red.withOpacity(0.5) : Colors.white24,
                      ),
                      onPressed: () => ref.read(appListProvider.notifier).toggleDistracting(app.packageName),
                      tooltip: 'Mark as Distracting',
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white24)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
