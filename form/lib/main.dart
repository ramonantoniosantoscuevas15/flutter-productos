import 'package:flutter/material.dart';
import 'package:form/services/services.dart';
import 'package:provider/provider.dart';

import 'screens/screens.dart';


void main() => runApp(const AppState());
class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: 
    [
      ChangeNotifierProvider(create: (_)=> ProductsServices()),
      ChangeNotifierProvider(create: (_)=> AuthServices())

    ],
     child: const MyApp() ,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'check',
      routes: {
        'login' :(_) => const LoginScreen(),
        'home' :(_) => const  HomeScreen(),
        'product' :(_) => const ProductScreen(),
        'register' :(_) => const  RegisterScreen(),
        'check' :(_) => const CheckAuthScreen()
      },
      scaffoldMessengerKey: NotificationsServices.messengerKey,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[300],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          color: Colors.indigo
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          elevation: 0
        )
      ),
    );
  }
}