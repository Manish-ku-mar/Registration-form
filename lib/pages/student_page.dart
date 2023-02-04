import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentRegisterPage extends StatefulWidget {
  const StudentRegisterPage({Key? key}) : super(key: key);

  @override
  State<StudentRegisterPage> createState() => _StudentRegisterPageState();
}

class _StudentRegisterPageState extends State<StudentRegisterPage> {
  final formGlobalKey = GlobalKey<FormState>();

  //controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _yearController = TextEditingController();

  //variables
  FirebaseStorage storage = FirebaseStorage.instance;
  PlatformFile? resume;
  PlatformFile? profilePic;
  UploadTask? uploadTask1;
  UploadTask? uploadTask2;
  String? urlProfile;
  String? urlResume;

  //pick pdf
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

  //upload pdf
  Future uploadResume() async {
    final path = 'Resume/${resume!.name}';
    final file = File(resume!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask2 = ref.putFile(file);
    final snapshot = await uploadTask2!.whenComplete(() => {});
    urlResume = await snapshot.ref.getDownloadURL();
    print(urlResume);
  }

  //pick profile image
  Future pickProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles().then((img) async {
        if (img != null) {
          setState(() {
            profilePic = img.files.first;
          });
        }
      });
      if (result == null) return null;
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  //upload image
  Future uploadProfileImage() async {
    final path = 'Profile_image/${profilePic!.name}';
    final file = File(profilePic!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask1 = ref.putFile(file);
    final snapshot = await uploadTask1!.whenComplete(() => {});
    urlProfile = await snapshot.ref.getDownloadURL();
    print(urlProfile);
  }

  //save to database
  Future saveToDatabase() async {
    // create user details
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text, password: _passwordController.text);

    await uploadProfileImage();
    await uploadResume();

    // if(urlProfile!.isEmpty)
    //   {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Please upload profile pic')),
    //     );
    //   }

    //add user deatils
    await addUserDetails(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _mobileController.text,
        _collegeNameController.text,
        _yearController.text,
        urlResume.toString(),
        urlProfile.toString());
    //add image to database
    Navigator.pushNamed(context, "home");
  }

  //simple function to add details
  Future addUserDetails(
      String name,
      String email,
      String passsword,
      String mobile,
      String college,
      String year,
      String urlResume,
      String urlProfile) async {
    final data = {
      'email': email,
      'passsword': passsword,
      'mobile number': mobile,
      'college name': college,
      'admission year': year,
      'Profile pic': urlProfile,
      'Resume': urlResume
    };
    await FirebaseFirestore.instance
        .collection('Students')
        .doc('${name}${mobile}')
        .set(data, SetOptions(merge: true))
        .onError((error, _) => print(error.toString()));
  }

  //validation
  // String? validation(value)

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
                  const Icon(
                    Icons.android,
                    size: 80,
                  ),
                  //hello
                  Text(
                    'Student!',
                    style: GoogleFonts.bebasNeue(fontSize: 52),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Register below with your details !',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
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
                            if (!value.contains('@')) {
                              return 'Email is invalid, must contain @';
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
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
                            if (value!.length < 6)
                              return 'Password cannot be less than 6';
                            return null;
                          },
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
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
                            if (value!.isEmpty &&
                                !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$')
                                    .hasMatch(value))
                              return 'value cannot be empty';
                            return null;
                          },
                          controller: _mobileController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Mobile Number',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
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
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'College name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //admission year
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
                          controller: _yearController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Admission year',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //add image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: pickProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
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
                  const SizedBox(
                    height: 10,
                  ),
                  //add pdf
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: pickResume,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
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
                  const SizedBox(
                    height: 10,
                  ),
                  //sigin button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: GestureDetector(
                      onTap: () {
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text(
                            'Register',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
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
