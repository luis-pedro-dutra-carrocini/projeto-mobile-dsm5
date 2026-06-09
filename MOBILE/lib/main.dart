import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screens/inicial.dart';

//void main() => runApp(DividasApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await testarBanco();
  runApp(DividasApp());
}

class DividasApp extends StatelessWidget {
  const DividasApp({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = "pt_BR";
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Dashboard(),

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 224, 2, 9)),

        primaryColor: const Color.fromARGB(255, 199, 7, 16),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 199, 7, 16),
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color.fromARGB(255, 199, 7, 16),
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 199, 7, 16),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
