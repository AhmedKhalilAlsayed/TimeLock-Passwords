import 'package:delay_pass/presentation/presentation_constants.dart';
import 'package:delay_pass/presentation/welcome_view/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// startup load time & build size:
/// v.1.0 futter run --debug: 11s 
/// v.1.0 flutter run --release: 6s 36M
/// v.1.0 flutter build web:  31M
/// v.1.0 flutter build web --debug:  41M
/// v.1.0 flutter build web --release:  31M
/// v.1.0 lutter build web --release --dart2js-optimization=O4:  31M
/// after clean: futter build --debug: 7s
/// after clean: futter build --release: 31M
/// after clean: futter build --release --wasm: 33M
/// 
/// 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: PresentationConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        // Apply the system UI style to the entire app theme
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      home: const WelcomeView(),
    );
  }
}
