import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FacultyRegistrationPage extends StatefulWidget {
  const FacultyRegistrationPage({Key? key}) : super(key: key);

  @override
  State<FacultyRegistrationPage> createState() =>
      _FacultyRegistrationPageState();
}

class _FacultyRegistrationPageState extends State<FacultyRegistrationPage> {
  final formGlobalKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _collegeNameController = TextEditingController();
  FirebaseStorage storage = FirebaseStorage.instance;
  PlatformFile? resume;
  PlatformFile? profilePic;
  UploadTask? uploadTask1;
  UploadTask? uploadTask2;
  String? urlProfile;
  String? urlResume;

  Future pickResume() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return null;
      setState(() {
        resume = result.files.first;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future uploadResume() async {
    final path = 'Resume/${resume!.name}';
    final file = File(resume!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask2 = ref.putFile(file);
    final snapshot = await uploadTask2!.whenComplete(() => {});
    urlResume = await snapshot.ref.getDownloadURL();
    print(urlResume);
  }

  Future pickProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return null;
      setState(() {
        profilePic = result.files.first;
      });
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future uploadProfileImage() async {
    final path = 'Profile_image/${profilePic!.name}';
    final file = File(profilePic!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask1 = ref.putFile(file);
    final snapshot = await uploadTask1!.whenComplete(() => {});
    urlProfile = await snapshot.ref.getDownloadURL();
    print(urlProfile);
  }

  Future saveToDatabase() async {
    // create user details
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);

    await uploadProfileImage();
    await uploadResume();

    //add user deatils
    await addUserDetails(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _mobileController.text,
        _collegeNameController.text,
        urlResume.toString(),
        urlProfile.toString());
    //add image to database
    Navigator.pushNamed(context, "home");
  }

  Future addUserDetails(
      String name,
      String email,
      String passsword,
      String mobile,
      String college,
      String urlResume,
      String urlProfile) async {
    await FirebaseFirestore.instance
        .collection('Faculty')
        .doc('${name}${mobile}')
        .set({
      'email': email,
      'passsword': passsword,
      'mobile number': mobile,
      'college name': college,
      'Profile pic': urlProfile,
      'Resume': urlResume
    }, SetOptions(merge: true)).onError((error, _) => print(error.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formGlobalKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.android,
                    size: 100,
                  ),
                  //hello
                  Text(
                    'Faculty!',
                    style: GoogleFonts.bebasNeue(fontSize: 52),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Register below with your details !',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),

                  SizedBox(
                    height: 50,
                  ),
                  //username
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'value cannot be empty';
                            return null;
                          },
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty|| !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //pass
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextFormField(
                          validator: (value) {
                            if(value!.length<6)
                              return 'Password cannot be less than 6';
                            return null;
                          },
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //confirm pass

                  //mobile
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty&&!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) return 'value cannot be empty';
                            return null;
                          },
                          controller: _mobileController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Mobile Number',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //college name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'value cannot be empty';
                            return null;
                          },
                          controller: _collegeNameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'College name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //add image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: pickProfileImage,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            "Upload Profile pic",
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //add pdf
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: pickResume,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            "Upload Resume",
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //sigin button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: (){
                        if (formGlobalKey.currentState!.validate() &&
                            profilePic != null &&
                            resume != null) {
                          formGlobalKey.currentState!.save();
                          saveToDatabase();
                        } else if (profilePic == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please upload profile pic')),
                          );
                          print("enter the data");
                        } else if (resume == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please upload resume')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Please enter details correctly')),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  //register button
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
