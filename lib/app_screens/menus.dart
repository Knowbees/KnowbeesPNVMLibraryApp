import 'package:com.knowbees.pnvmlibraryapp/app_screens/home_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/newarrival_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/payment_details_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/current_checkodouts_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/reading_history_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/reserved_books_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/user_details_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/contact_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/login_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/logout/LogoutUser.dart';


class MenuDrawer extends StatefulWidget {
  @override
  _MenuDrawerState createState() => new _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {

  SharedPreferences sharedPreferences;
  bool isLogin, isLoading;
  String  logInOutMenu, userName, cardNumber;
  Map map;
  Map<String,int> colorsMap;

  void initState() {
    initializeUI();
    manage();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initializeUI(){
    map = Map();
    map[ApplicationKeys.NewArrivalMenu] = ConfigValues.NewArrivalMenu;
    map[ApplicationKeys.PaymentDetailsMenu] = ConfigValues.PaymentDetailsMenu;
    map[ApplicationKeys.IssuedItemsMenu] = ConfigValues.IssuedItemsMenu;
    map[ApplicationKeys.ReadingHistoryMenu] = ConfigValues.ReadingHistoryMenu;
    map[ApplicationKeys.ReservedItemsMenu] = ConfigValues.ReservedItemsMenu;
    map[ApplicationKeys.LoginMenu] = ConfigValues.LoginMenu;
    map[ApplicationKeys.LogoutMenu] = ConfigValues.LogoutMenu;
    map[ApplicationKeys.LibraryName] = ConfigValues.LibraryName;
    logInOutMenu = map[ApplicationKeys.LoginMenu];

    colorsMap = Map();
    colorsMap[ApplicationKeys.ColorPrimary] = ConfigValues.ColorPrimary;
    colorsMap[ApplicationKeys.ColorPrimaryDark] = ConfigValues.ColorPrimaryDark;
    colorsMap[ApplicationKeys.ColorAccent] = ConfigValues.ColorAccent;
    colorsMap[ApplicationKeys.AppBarTextColor] = ConfigValues.AppBarTextColor;
    colorsMap[ApplicationKeys.SubTitleColor] = ConfigValues.SubTitleColor;
    colorsMap[ApplicationKeys.TableHeadingColor] = ConfigValues.TableHeadingColor;
    colorsMap[ApplicationKeys.TitleColor] = ConfigValues.TitleColor;
    colorsMap[ApplicationKeys.TextColor] = ConfigValues.TextColor;
  }

  Future manage() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setUI();
    setLoginUser();
  }

  setUI(){
    map[ApplicationKeys.NewArrivalMenu] = sharedPreferences.getString(ApplicationKeys.NewArrivalMenu);
    map[ApplicationKeys.PaymentDetailsMenu] = sharedPreferences.getString(ApplicationKeys.PaymentDetailsMenu);
    map[ApplicationKeys.IssuedItemsMenu] = sharedPreferences.getString(ApplicationKeys.IssuedItemsMenu);
    map[ApplicationKeys.ReadingHistoryMenu] = sharedPreferences.getString(ApplicationKeys.ReadingHistoryMenu);
    map[ApplicationKeys.ReservedItemsMenu] = sharedPreferences.getString(ApplicationKeys.ReservedItemsMenu);
    map[ApplicationKeys.LoginMenu] = sharedPreferences.getString(ApplicationKeys.LoginMenu);
    map[ApplicationKeys.LogoutMenu] = sharedPreferences.getString(ApplicationKeys.LogoutMenu);

    map[ApplicationKeys.FeedbackEmailId] = sharedPreferences.getString(ApplicationKeys.FeedbackEmailId);
    map[ApplicationKeys.WebLink] = sharedPreferences.getString(ApplicationKeys.WebLink);
    map[ApplicationKeys.ApplicationLink] = sharedPreferences.getString(ApplicationKeys.ApplicationLink);
    map[ApplicationKeys.LibraryName] = sharedPreferences.getString(ApplicationKeys.LibraryName);

    colorsMap[ApplicationKeys.ColorPrimary] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimary),radix: 16);
    colorsMap[ApplicationKeys.ColorPrimaryDark] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimaryDark),radix: 16);
    colorsMap[ApplicationKeys.ColorAccent] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorAccent),radix: 16);
    colorsMap[ApplicationKeys.AppBarTextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.AppBarTextColor),radix: 16);
    colorsMap[ApplicationKeys.SubTitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.SubTitleColor),radix: 16);
    colorsMap[ApplicationKeys.TextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TextColor),radix: 16);
    setState(() {});
  }

  setLoginUser(){
    isLogin = sharedPreferences.getBool(ApplicationKeys.IsLogin) ?? false;
    if(isLogin){
      String firstName = sharedPreferences.getString(ApplicationKeys.FirstName);
      String lastName = sharedPreferences.getString(ApplicationKeys.LastName);
      userName = '$firstName'+' '+'$lastName';
      cardNumber = sharedPreferences.getString(ApplicationKeys.CardNumber);
      logInOutMenu = map[ApplicationKeys.LogoutMenu];
    } else {
      userName = cardNumber = null;
      logInOutMenu = map[ApplicationKeys.LoginMenu];
    }
    setState(() {});
  }

  Future doLogInOrLogOut() async {
    if(isLogin){
      await LogoutUser().deleteUserData();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen()));
    } else {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen()));
    }
  }

  gotoScreen(var screen){
    Navigator.pop(context);
    if(!isLogin){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen()));
    }else{
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {

    if(isLogin != null){
      setLoginUser();
    }
   return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.account_circle,color: Colors.white,),
                      iconSize: 60 ,
                      onPressed: () {
                        gotoScreen(UserDetailsScreen());
                      },
                    ),
                    if(userName != null) Text(userName, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Colors.white)),
                    if(cardNumber != null) Text('Card No:'+cardNumber, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Colors.white)),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),

                ),
              ),
              ListTile(
                  title: Text(ConfigValues.HomeOptionMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                  leading: Icon(Icons.home, color: Color(colorsMap[ApplicationKeys.TextColor]),),
                  onTap: () {
                    isLogin = true;
                    gotoScreen(HomeScreen());
                  }
              ),
              ListTile(
                  title: Text(ConfigValues.NewArrivalMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                  leading: Icon(Icons.description, color: Color(colorsMap[ApplicationKeys.TextColor]),),
                  onTap: () {
                    isLogin = true;
                    gotoScreen(NewArrivalsScreen());
                  }
              ),
              ListTile(
                title: Text(ConfigValues.PaymentDetailsMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                leading: Icon(Icons.insert_chart, color: Color(colorsMap[ApplicationKeys.TextColor]),),
                onTap: () {
                  gotoScreen(PaymentDetailsScreen());
                },
              ),
              ListTile(
                title: Text(ConfigValues.IssuedItemsMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                leading: Icon(Icons.view_list, color: Color(ConfigValues.TextColor),),
                onTap: () {
                  gotoScreen(CurrentCheckedOutsScreen());
                },
              ),
              ListTile(
                title: Text(ConfigValues.ReadingHistoryMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                leading: Icon(Icons.history, color: Color(ConfigValues.TextColor),),
                onTap: () {
                  gotoScreen(ReadingHistoryScreen());
                },
              ),
              ListTile(
                title: Text(ConfigValues.ReservedItemsMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                leading: Icon(Icons.book, color: Color(ConfigValues.TextColor),),
                onTap: () {
                  gotoScreen(ReservedBooksScreen());
                },
              ),
              ListTile(
                  title: Text(logInOutMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                  leading: isLogin == true ? Icon(Icons.lock_open, color: Color(ConfigValues.TextColor),) : Icon(Icons.lock, color: Color(ConfigValues.TextColor),),
                  onTap: () {
                    doLogInOrLogOut();
                  }
              ),
              Divider(
                height: 1.5,
                color: Colors.black,
              ),

              ListTile(
                  title: Text(ConfigValues.WebLinkMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                  leading: Icon(Icons.link, color: Color(ConfigValues.TextColor),),
                  onTap: () {
                    Navigator.pop(context);
                    fireLink();
                  }
              ) ,
              ListTile(
                title: Text(ConfigValues.ShareMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                leading: Icon(Icons.share, color: Color(ConfigValues.TextColor),),
                onTap: () {
                  Navigator.pop(context);
                  appShare();
                },
              ),
              ListTile(
                title: Text(ConfigValues.ContactMenu,style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor])),),
                leading: Icon(Icons.contacts, color: Color(ConfigValues.TextColor),),
                onTap: () {
                  isLogin = true;
                  gotoScreen(ContactScreen());
                },
              ),
            ],
          ),
    );
  }

  fireLink() async {
    if (await canLaunch(map[ApplicationKeys.WebLink])) {
      await launch(map[ApplicationKeys.WebLink]);
    } else {
      Fluttertoast.showToast(
          msg: 'Something went wrong!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  appShare() async{
    Share.share(map[ApplicationKeys.LibraryName].toString()+'s Library Application, ' +'Powered by Knowbees Consulting Pvt. Ltd.'
        '\n\nNow, you can download it from \n'+ map[ApplicationKeys.ApplicationLink],
        subject: 'Application');
  }
}

