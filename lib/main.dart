import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/servers_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/speed_test_screen.dart';
import 'services/storage_service.dart';
import 'services/vpn_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VpnService(storageService),
        ),
      ],
      child: const VpnOneApp(),
    ),
  );
}

class VpnOneApp extends StatelessWidget {
  const VpnOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPN One',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ServersScreen(),
    SpeedTestScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E2B42), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.primaryCyan,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_rounded),
              activeIcon: Icon(Icons.shield_rounded, color: AppTheme.primaryCyan),
              label: 'Tunnel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public_rounded),
              activeIcon: Icon(Icons.public_rounded, color: AppTheme.primaryCyan),
              label: 'Servers & IPs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.speed_rounded),
              activeIcon: Icon(Icons.speed_rounded, color: AppTheme.primaryCyan),
              label: 'Speed Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.tune_rounded, color: AppTheme.primaryCyan),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
