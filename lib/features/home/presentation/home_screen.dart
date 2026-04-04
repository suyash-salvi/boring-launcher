import 'dart:async';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../apps/presentation/app_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../usage/presentation/usage_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  late Timer _timer;
  DateTime _now = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _searchQuery = ''); 
      _searchController.clear();
    }
  }

  Future<void> _launchApp(String packageName, bool isDistracting) async {
    if (isDistracting) {
      Fluttertoast.showToast(
        msg: "Stay mindful. This app is distracting.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    InstalledApps.startApp(packageName);
  }

  Future<void> _openCamera() async {
    const intent = AndroidIntent(
      action: 'android.media.action.STILL_IMAGE_CAMERA',
    );
    await intent.launch();
  }

  Future<void> _openPhone() async {
    const intent = AndroidIntent(
      action: 'android.intent.action.DIAL',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    final appList = ref.watch(appListProvider);
    final unlocks = ref.watch(unlockCountProvider);

    return PopScope(
      canPop: false, 
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center, // Aligns elements vertically centered in the row
                  children: [
                    // Time and Date Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(_now),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Text(
                          DateFormat('EEE, MMM d').format(_now),
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ),
                    
                    // Icons Section (Phone and Camera)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _openPhone,
                          icon: const Icon(Icons.phone_outlined, color: Colors.white24, size: 28),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        IconButton(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 28),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
                    ),

                    // Unlocks Counter Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$unlocks', 
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 32, 
                            fontWeight: FontWeight.w200,
                            height: 1,
                          )
                        ),
                        const SizedBox(height: 4),
                        const Text('unlocks', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white70),
                  cursorColor: Colors.white38,
                  decoration: InputDecoration(
                    hintText: 'Search apps...',
                    hintStyle: const TextStyle(color: Colors.white24),
                    border: InputBorder.none,
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
                const SizedBox(height: 20),
                Expanded(
                  child: appList.when(
                    data: (apps) {
                      final filteredApps = apps.where((a) {
                        final matchesSearch = a.appName.toLowerCase().contains(_searchQuery.toLowerCase());
                        return a.isAllowed && matchesSearch;
                      }).toList();

                      if (filteredApps.isEmpty && _searchQuery.isEmpty) {
                        return Center(
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            child: const Text('Configure apps', style: TextStyle(color: Colors.white38)),
                          ),
                        );
                      }

                      return ReorderableListView.builder(
                        itemCount: filteredApps.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(appListProvider.notifier).reorderAllowedApps(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          return Padding(
                            key: ValueKey(app.packageName),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: InkWell(
                              onTap: () => _launchApp(app.packageName, app.isDistracting),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    app.appName, 
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  if (app.isDistracting) ...[
                                    const SizedBox(width: 12),
                                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent.withOpacity(0.5), size: 16),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.white10)),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white38, size: 28),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
