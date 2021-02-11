import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';

class LogoutUser {

  Future deleteUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(ApplicationKeys.IsLogin,false);
    sharedPreferences.setString(ApplicationKeys.FirstName,null);
    sharedPreferences.setString(ApplicationKeys.LastName,null);
    sharedPreferences.setString(ApplicationKeys.BorrowerNumber,null);
    sharedPreferences.setString(ApplicationKeys.CardNumber,null);
    sharedPreferences.setString(ApplicationKeys.BranchCode,null);
    sharedPreferences.setString(ApplicationKeys.Cookie,null);
    sharedPreferences.setString(ApplicationKeys.UserId,null);
    sharedPreferences.setString(ApplicationKeys.Password,null);
    sharedPreferences.setString(ApplicationKeys.PaymentDetails,null);
    sharedPreferences.setString(ApplicationKeys.ReadingHistory,null);
  }
}