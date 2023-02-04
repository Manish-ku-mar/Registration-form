import 'dart:io';

import 'package:authenticate/pages/home_page.dart';
import 'package:authenticate/pages/main_page.dart';
import 'package:authenticate/pages/alumni_page.dart';
import 'package:authenticate/pages/faculty_page.dart';
import 'package:authenticate/pages/student_page.dart';
import 'package:authenticate/pages/user_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'pages/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'Student':(context)=> StudentRegisterPage(),
        'Faculty':(context)=> FacultyRegistrationPage(),
        'Alumni':(context)=> AlumniRegisterPage(),
        'usertype':(context)=> UserType(),
        'home':(context)=>HomePage()
      },
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
