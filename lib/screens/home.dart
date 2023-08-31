import 'package:flutter_application_14/screens/userinfo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:flutter_application_14/models/configure.dart';
import 'package:flutter_application_14/models/users.dart';
import 'package:flutter_application_14/screens/userform.dart';

class Home extends StatefulWidget {
  static const String routeName = '/';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String accountName = "N/A";
    String accountEmail = "N/A";
    String accountUrl =
        "https://scontent-sin6-4.xx.fbcdn.net/v/t39.30808-6/366044413_2440907329420584_8042169544596073824_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_eui2=AeHtHbNBd7dmE_rsk2sNiUmEYR2gsZC1nnVhHaCxkLWedQL-hqu5X8ZwXWlo2BwbF3HNW3xsEjzafj4pgA2ooSVm&_nc_ohc=rjHWR28nZpYAX-WYozS&_nc_ht=scontent-sin6-4.xx&oh=00_AfDOWy8SqPQ3A3_5CGVcsCT6h9z3LGTSdVw6MKy9rHrDsg&oe=64F0ABD2";

    Users users = Configure.login;
    if (users.id != null) {
      accountName = users.fullname!;
      accountEmail = users.email!;
    }

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(accountName),
            accountEmail: Text(accountEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(accountUrl),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            title: Text('Login'),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();
  List<Users> _userList = [];
  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
    return;
  }

  Future<void> removeUsers(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.delete(url);
    print(resp.body);
  }

  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        drawer: const SideMenu(),
        body: mainBody,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String result = await Navigator.push(
                context, MaterialPageRoute(builder: (context) => UserFrom()));
            if (result == "refresh") {
              getUsers();
            }
          },
          child: const Icon(Icons.person_add_alt_1),
        ));
  }

  Widget showUsers() {
    return ListView.builder(
      itemCount: _userList.length,
      itemBuilder: (context, index) {
        Users user = _userList[index];
        return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            child: Card(
              child: ListTile(
                title: Text("${user.fullname}"),
                subtitle: Text("${user.email}"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInfo(),
                          settings: RouteSettings(arguments: user)));
                },
                trailing: IconButton(
                  onPressed: () async {
                    String result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserFrom(),
                            settings: RouteSettings(arguments: user)));
                    if (result == "refresh") {
                      getUsers();
                    }
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
            ),
            onDismissed: (direction) {
              removeUsers(user);
            },
            background: Container(
              color: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.centerRight,
              child: Icon(Icons.delete, color: Colors.white),
            ));
      },
    );
  }
}
