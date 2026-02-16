import 'package:chat_app/controller/auth_controller.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/auth/profile.dart';
import 'package:chat_app/pages/search_page.dart';
import 'package:chat_app/service/database.dart';
import 'package:chat_app/service/firebase_auth.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthController authController = Get.put(AuthController());
  Stream? userGroupsStream;
  Future<void> gettingUserData() async {
    await DatabaseService(
      uid: FirebaseAuthService().currentUser?.uid,
    ).getUserGroups().then((value) {
      debugPrint("User Groups: ${value.toString()}");
      userGroupsStream = value;
    });
  }

  String groupName = "";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, const SearchPage());
            },
            icon: const Icon(Icons.search),
          ),
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Groups",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700]),
            const SizedBox(height: 15),
            Obx(
              () => Text(
                authController.userName.value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(height: 2),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                  context,
                  ProfilePage(
                    userName: authController.userName.value,
                    email: authController.userEmail.value,
                  ),
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              leading: const Icon(Icons.group),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.cancel, color: Colors.red),
                        ),
                        IconButton(
                          onPressed: () async {
                            await FirebaseAuthService().logOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.done, color: Colors.green),
                        ),
                      ],
                    );
                  },
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: groupList(),
    );
  }

  void getData() async {
    String email = await AuthController.getUserEmailFromSF() ?? "";
    debugPrint("User Email: $email");
    debugPrint("Current user: ${FirebaseAuthService().currentUser}");
    FirebaseAuthService().gettingUserData(email);
  }

  void signOut(BuildContext context) async {
    try {
      await FirebaseAuthService().logOut();
      await AuthController.setUserEmail("");
      await AuthController.setUserName("");
      await AuthController.setUserLoggedInStatus(false);
      nextScreenReplace(context, const LoginPage());
    } catch (e) {
      showSnackbar(context, Colors.red, e.toString());
    }
  }

  StreamBuilder<dynamic> groupList() {
    return StreamBuilder(
      stream: userGroupsStream,
      builder: (context, AsyncSnapshot snapshot) {
        //       // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return null;
                  // return GroupTile(
                  //   groupId: getId(snapshot.data['groups'][reverseIndex]),
                  //   groupName: getName(snapshot.data['groups'][reverseIndex]),
                  //   userName: snapshot.data['fullName'],
                  // );
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return const Center(child: Text("No Data Found..."));
          // Center(
          //   child: CircularProgressIndicator(
          //     color: Theme.of(context).primaryColor,
          //   ),
          // );
        }
      },
    );
  }

  void popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            return AlertDialog(
              title: const Text("Create a group", textAlign: TextAlign.left),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => authController.isLoading.value
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : TextField(
                            onChanged: (val) {
                              setState(() {
                                groupName = val;
                              });
                            },
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      print("Creating group: $groupName");
                      print(
                        "Current user: ${FirebaseAuthService().currentUser}",
                      );
                      print(
                        "Current user uid: ${FirebaseAuthService().currentUser?.uid}",
                      );
                      setState(() {
                        _isLoading = true;
                      });
                      DatabaseService(
                            uid: FirebaseAuthService().currentUser!.uid,
                          )
                          .createGroup(
                            FirebaseAuthService().currentUser!.displayName ??
                                "",
                            FirebaseAuthService().currentUser!.uid,
                            groupName,
                          )
                          .whenComplete(() {
                            _isLoading = false;
                          });
                      Navigator.of(context).pop();
                      showSnackbar(
                        context,
                        Colors.green,
                        "Group created successfully.",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("CREATE"),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Container noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // popUpDialog(context);
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 75),
          ),
          const SizedBox(height: 20),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
