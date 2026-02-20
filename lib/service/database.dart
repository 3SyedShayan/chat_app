import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance
      .collection("groups");

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future savingUserData(String fullname, String email) async {
    try {
      await userCollection.doc(uid).set({
        "fullname": fullname,
        "email": email,
        "groups": [],
        "uid": uid,
      });
      debugPrint("User Data Saved");
    } on FirebaseException catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future getUserGroups() async {
    try {
      return userCollection.doc(uid).snapshots();
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future createGroup(String groupName, String id, String userName) async {
    DocumentReference groupReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "groupId": "",
      "admin": "${id}_$userName",
      "members": [],
      "recentMessage": "",
      "recentMessageSender": "",
      "totalMembers": 0,
    });
    await groupReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupReference.id,
      "totalMembers": FieldValue.increment(1),
    });
    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(["${groupReference.id}_$groupName"]),
    });
  }

  Future getChats(String groupId) async {
    try {
      return groupCollection
          .doc(groupId)
          .collection("messages")
          .orderBy("time")
          .snapshots();
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future getGroupAdmin(String groupId) async {
    try {
      DocumentReference d = groupCollection.doc(groupId);
      DocumentSnapshot documentSnapshot = await d.get();
      return documentSnapshot['admin'];
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  getMembers(String groupId) async {
    try {
      return groupCollection.doc(groupId).snapshots();
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
    }
  }

  Future<bool> isUserJoined(
    String groupName,
    String groupId,
    String userName,
  ) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  searchByName(String groupName) {
    return groupCollection
        .where("groupName", isGreaterThanOrEqualTo: groupName)
        .where("groupName", isLessThan: '${groupName}z')
        .get();
  }

  Future toggleGroupJoin(
    String groupId,
    String userName,
    String groupName,
  ) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      });
    }
  }
}
