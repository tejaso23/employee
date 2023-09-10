import 'package:employee_management/models/user_model.dart';
import 'package:flutter/material.dart';

class UserCreatedBtn extends StatelessWidget {
  final UserModel user;

  const UserCreatedBtn({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "User Created with following details",
          style: TextStyle(fontSize: 20.0),
        ),
        const SizedBox(height: 10.0,),
        Table(
          children: [
            TableRow(children: [const Text("User Name"), Text(user.name)]),
            TableRow(children: [const Text("User Email"), Text(user.email)]),
            TableRow(children: [
              const Text("User Contact No"),
              Text(user.contactNo)
            ]),
            TableRow(children: [
              const Text("User Department"),
              Text(user.department)
            ]),
          ],
        ),
        const SizedBox(height: 16.0,),
        ElevatedButton(onPressed: () {}, child: const Text("OK")),
      ],
    );
  }
}
