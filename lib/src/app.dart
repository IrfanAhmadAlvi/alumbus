import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alumbus/src/providers/auth_provider.dart';
import 'package:alumbus/src/providers/directory_provider.dart';
import 'package:alumbus/src/auth/auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide both of our providers to the app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DirectoryProvider()),
      ],
      child: MaterialApp(
        title: 'Alumbus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthGate(),
      ),
    );
  }
}