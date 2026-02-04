import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/game_state.dart';
import 'screens/home_screen.dart';
import 'screens/pet_selection_screen.dart';
import 'theme/pixel_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MathGameApp());
}

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Math Quest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: PixelTheme.bgDark,
          appBarTheme: const AppBarTheme(
            backgroundColor: PixelTheme.bgDark,
            foregroundColor: PixelTheme.textLight,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: PixelTheme.pixelFont,
              fontSize: 14,
              color: PixelTheme.textLight,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: PixelTheme.textLight),
            bodyMedium: TextStyle(color: PixelTheme.textLight),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: PixelTheme.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const AppRouter(),
      ),
    );
  }
}

/// 根據用戶狀態決定顯示哪個頁面
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    // 如果未選擇初始寵物，顯示選擇頁面
    if (!gameState.hasChosenStarterPet) {
      return const PetSelectionScreen();
    }
    
    // 否則顯示主頁
    return const HomeScreen();
  }
}
