import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/routes.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(create: (_) => AppState()..init(), child: const EncargaloApp()));
}

class EncargaloApp extends StatelessWidget {
  const EncargaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return MaterialApp(
      title: 'Encárgalo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: Colors.deepPurple, brightness: Brightness.dark, useMaterial3: true),
      themeMode: st.oscuro ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: Routes.generar,
      home: st.cargando
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : st.usuario == null
              ? const LoginScreen()
              : const HomeScreen(),
    );
  }
}
