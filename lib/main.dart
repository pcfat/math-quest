import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/game_state.dart';
import 'screens/splash_screen.dart';
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
        home: const SplashScreen(),
      ),
    );
  }
}
