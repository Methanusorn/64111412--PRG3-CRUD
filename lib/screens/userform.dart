import 'package:flutter/material.dart';
import 'package:flutter_application_14/models/configure.dart';
import 'package:flutter_application_14/models/users.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserFrom extends StatefulWidget {
  static const routeName = "/UserFrom";
  const UserFrom({super.key});

  @override
  State<UserFrom> createState() => _UserFromState();
}

class _UserFromState extends State<UserFrom> {
  final _formkey = GlobalKey<FormState>();
  // Users user = Users();
  late Users user;

  @override
  Widget build(BuildContext context) {
    try {
      user = ModalRoute.of(context)!.settings.arguments as Users;
      print(user.fullname);
    } catch (e) {
      user = Users();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Form"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fnameInputField(),
              EmailInputField(),
              passwordInputField(),
              genderFormInput(),
              SizedBox(
                height: 10,
              ),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addNewUsers(users) async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(users.toJson()));
    var rs = usersFromJson("[${resp.body}]");
    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
    return;
  }

  Future<void> updateData(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.put(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()));
    var rs = usersFromJson("[${resp.body}]");
    if (rs.length == 1) {
      Navigator.pop(context, "refresh");
    }
  }

  Widget fnameInputField() {
    return TextFormField(
      initialValue: user.fullname,
      decoration:
          InputDecoration(labelText: "Fullname:", icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.fullname = newValue,
    );
  }

  Widget EmailInputField() {
    return TextFormField(
      initialValue: user.email,
      decoration:
          InputDecoration(labelText: "email:", icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.email = newValue,
    );
  }

  Widget passwordInputField() {
    return TextFormField(
      initialValue: user.password,
      obscureText: true,
      decoration:
          InputDecoration(labelText: "password:", icon: Icon(Icons.person)),
      validator: (value) {
        if (value!.isEmpty) {
          return "This field is required";
        }
        return null;
      },
      onSaved: (newValue) => user.password = newValue,
    );
  }

  Widget submitButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formkey.currentState!.validate()) {
            _formkey.currentState!.save();
            print(user.toJson().toString());
            // addNewUsers(user);
            if (user.id == null) {
              addNewUsers(user);
            } else {
              updateData(user);
            }
          }
        },
        child: Text("Save"));
  }

  Widget genderFormInput() {
    var initGen = "None";
    try {
      if (user.gender != null) {
        initGen = user.gender!;
      }
    } catch (e) {
      initGen = "None";
    }
    return DropdownButtonFormField(
        value: initGen,
        decoration:
            InputDecoration(labelText: "Gender:", icon: Icon(Icons.man)),
        items: Configure.gender.map((String val) {
          return DropdownMenuItem(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: (value) {
          user.gender = value;
        },
        onSaved: (newValue) => user.gender);
  }
}
