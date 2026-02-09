import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  static RxString userLoggedInKey = "LOGGEDINKEY".obs;
  static RxString userNameKey = "USERNAMEKEY".obs;
  static RxString userEmailKey = "USEREMAILKEY".obs;

  RxString userName = "".obs;
  RxString userEmail = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    userName.value = await getUserNameFromSF() ?? "";
    userEmail.value = await getUserEmailFromSF() ?? "";
  }

  static Future<bool?> setUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey.value, isUserLoggedIn);
  }

  static Future<bool> setUserName(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userNameKey.value, userName);
  }

  static Future<bool> setUserEmail(String email) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(userEmailKey.value, email);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey.value);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey.value);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey.value);
  }
}
