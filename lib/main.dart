import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/player_screen.dart';
import 'services/api_service.dart';
import 'services/library_service.dart';
import 'services/search_history_notifier.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveService.initHive();
  await HiveService.initializeDefaultCategories();

  runApp(const SuinimeApp());
  ApiService().fetchTopAnime();
}

class SuinimeApp extends StatelessWidget {
  const SuinimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryNotifier()),
        ChangeNotifierProvider(create: (_) => SearchHistoryNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suinime',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkBg,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
        routes: {
          '/detail': (context) => DetailScreen(
            malId: ModalRoute.of(context)?.settings.arguments as int,
          ),
          '/player': (context) => const PlayerScreen(),
        },
      ),
    );
  }
}
