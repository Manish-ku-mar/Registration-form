import 'package:authenticate/pages/student_page.dart';
import 'package:flutter/material.dart';

class UserType extends StatefulWidget {
   UserType({Key? key}) : super(key: key);

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  final List<String> _users=[
    "Student",
    "Faculty",
    "Alumni"
  ];

  var selectedUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:Text("Select user type"),
            backgroundColor: Colors.deepPurpleAccent
        ),
      backgroundColor: Colors.grey[300],
        body: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Please select the user type",
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
            SizedBox(height: 20,),
            Center(
              child: Container(
                margin: EdgeInsets.only(top:50),
                alignment: Alignment.topCenter,
                child: DropdownButton(
                  value: selectedUser,
                  onChanged: (value){
                    setState(() {
                      selectedUser = value.toString();
                    });
                    print(selectedUser);
                    Navigator.pushNamed(context, selectedUser);
                  },
                  dropdownColor: Colors.deepPurple[200],
                  hint:Text("Select User",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),) ,
                  items: _users.map((itemone){
                    return DropdownMenuItem(
                        value: itemone,
                        child: Center(child: Text(itemone,style: TextStyle(color: Colors.white),))
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        )
    );
  }
}
