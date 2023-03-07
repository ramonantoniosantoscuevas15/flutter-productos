import 'package:flutter/material.dart';
import 'package:form/screens/home_screen.dart';
import 'package:form/screens/login_screen.dart';
import 'package:provider/provider.dart';

import '../services/services.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context, listen: false);
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return const Icon(Icons.verified_outlined);
            }
            if (snapshot.data == '') {
              Future.microtask(() {
              //Navigator.of(context).pushReplacementNamed('login');
              Navigator.pushReplacement(
                  context, PageRouteBuilder(pageBuilder: 
                  (_, __, ___,) => const LoginScreen(),
                  transitionDuration: const Duration(seconds: 0),
                  ));
            }
            );
            }else{
              Future.microtask(() {
              //Navigator.of(context).pushReplacementNamed('login');
              Navigator.pushReplacement(
                  context, PageRouteBuilder(pageBuilder: 
                  (_, __, ___,) => const HomeScreen(),
                  transitionDuration: const Duration(seconds: 0),
                  ));
            }
            );
            }

            
            return Container();
          },
        ),
      ),
    );
  }
}
