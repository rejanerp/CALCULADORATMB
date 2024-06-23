import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/theme.dart';
import 'dart:io' show Platform;
import '../screens/homescreen.dart';
void main() async{
  runApp(const MainApp());
  WidgetsFlutterBinding.ensureInitialized();
  
  if(Platform.isAndroid){
    await Firebase.initializeApp(
      options: const FirebaseOptions(apiKey: "AIzaSyDiEYm40EhCj_cpzVHhon1PwEQw064hzLQ", 
      appId: "1:457739294547:android:0af7736395d3d40be8b3a6", 
      messagingSenderId: "457739294547", 
      projectId: "projetopos2"
      ),
    );

  }else{
    await Firebase.initializeApp();
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/register': (context) => const SignUpScreen(),
        '/homescreen': (context) =>  HomeScreen(),
      },
    );
  }
}
