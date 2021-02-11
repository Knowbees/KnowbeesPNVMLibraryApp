import 'dart:async';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchAPI.dart';
import 'package:flutter/material.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  SharedPreferences sharedPreferences;
  String status;
  bool isLoading,isUserNameError,isPasswordError,isPasswordVisible,isForeground;
  Map map;
  Map<String,int> colorsMap;
  final userNameEt = TextEditingController();
  final passwordEt = TextEditingController();

  void initState() {
    isForeground = true;
    initializeUIValues();
    setUIValues();
    super.initState();
  }

  initializeUIValues(){
    isLoading = false;
    isUserNameError = false;
    isPasswordError = false;
    isPasswordVisible = true;
    map = Map();
    map[ApplicationKeys.LoginMenu] = ConfigValues.LoginMenu;

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

  setUIValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    map[ApplicationKeys.LoginMenu] = sharedPreferences.getString(ApplicationKeys.LoginMenu);

    colorsMap[ApplicationKeys.ColorPrimary] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimary),radix: 16);
    colorsMap[ApplicationKeys.ColorPrimaryDark] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimaryDark),radix: 16);
    colorsMap[ApplicationKeys.ColorAccent] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorAccent),radix: 16);
    colorsMap[ApplicationKeys.AppBarTextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.AppBarTextColor),radix: 16);
    colorsMap[ApplicationKeys.SubTitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.SubTitleColor),radix: 16);
    colorsMap[ApplicationKeys.TableHeadingColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TableHeadingColor),radix: 16);
    colorsMap[ApplicationKeys.TitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TitleColor),radix: 16);
    colorsMap[ApplicationKeys.TextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TextColor),radix: 16);
    setState(() { });
  }

  Future doLogin() async {

    status = null;
    isUserNameError = false;
    isPasswordError = false;
    setState(() { });

    String userName = userNameEt.text;
    String password = passwordEt.text;

    if(userName.isEmpty){
      setState(() {
        isUserNameError = true;
      });
    }

    if(password.isEmpty){
      setState(() {
        isPasswordError = true;
      });
    }

    if(isUserNameError || isPasswordError){
      return;
    }

    status = 'Please wait...';
    isLoading = true;
    setState(() { });

    Map extras = Map();
    extras['userid'] = userName;
    extras['password'] = password;
    var response = await FetchAPI().fetchData(KohaURLs.LoginURL, extras);

    print('\nParsing Login Web Response:-\n'+response);
    print('\n\t--XXX-\n');

    try{
      Map parsedJson = jsonDecode(response);
      getUserDetails(parsedJson);
      status = 'Login Successful!';
    } catch(E){
      print('\nException:- '+E.toString());
      status = 'Login Failed!';
    }
    isLoading = false;
    if(isForeground){
      setState(() { });
    }
  }

  @override
  void dispose() {
    isForeground = false;
    userNameEt.dispose();
    passwordEt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(map[ApplicationKeys.LoginMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
          backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
        ),
        drawer: MenuDrawer(),
        body: GestureDetector(
          onTap: (){FocusScope.of(context).requestFocus(FocusNode());},
          child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[

                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        cursorColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
                        controller: userNameEt,
                        style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor]),fontSize: ConfigValues.SecondaryTextSize),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(colorsMap[ApplicationKeys.ColorPrimary])),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          hintText: 'User',
                          hintStyle: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor]), fontSize: ConfigValues.SecondaryTextSize),
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Color(colorsMap[ApplicationKeys.ColorAccent]), fontSize: ConfigValues.SecondaryTextSize),
                          prefixIcon: const Icon(Icons.account_box, color: Color(ConfigValues.ColorAccent),),
                          errorText: isUserNameError?'Enter Username please':null,
                        ),
                      ),
                    ),
                  ),

                  Container(
                      margin: const EdgeInsets.all(10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: TextField(
                          cursorColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
                          controller: passwordEt,
                          obscureText: isPasswordVisible,
                          style: TextStyle(color: Color(colorsMap[ApplicationKeys.SubTitleColor]), fontSize: ConfigValues.SecondaryTextSize),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(colorsMap[ApplicationKeys.ColorPrimary])),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            hintText: 'User123',
                            hintStyle: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor]), fontSize: ConfigValues.SecondaryTextSize),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Color(colorsMap[ApplicationKeys.ColorAccent]), fontSize: ConfigValues.SecondaryTextSize),
                            prefixIcon: const Icon(Icons.lock, color: Color(ConfigValues.ColorAccent),),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {isPasswordVisible = !isPasswordVisible;});
                              },
                              child: Icon(isPasswordVisible ? Icons.visibility_off: Icons.visibility, color: Color(colorsMap[ApplicationKeys.ColorAccent])),
                            ),
                            errorText: isPasswordError?'Enter password please':null,
                          ),
                        ),
                      )
                  ),

                  Center(
                    child: isLoading != true?
                    RaisedButton(
                        textColor: Colors.white,
                        color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        onPressed: (){
                          FocusScope.of(context).requestFocus(FocusNode());
                          doLogin();
                        },
                        child: SizedBox(
                          width: 80,
                          height: 40,
                          child: Center(
                            child: Text('Login', style: TextStyle(fontSize: ConfigValues.ButtonsTextSize),textAlign: TextAlign.center),
                          ),
                        )
                    ):null,
                  ),

                  if(status != null) Container(
                    margin: EdgeInsets.all(25),
                    child: Center(
                      child: Text(status, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize, color: Color(colorsMap[ApplicationKeys.ColorAccent])),textAlign: TextAlign.center),
                    ),
                  ),

                  if(isLoading == true) Container(
                    margin: EdgeInsets.all(25),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ],
              )
          ),
        )
    );
  }

  void getUserDetails(Map parsedJson) {
    if(parsedJson['LoginStatus'] == 'Successful'){
      sharedPreferences.setBool(ApplicationKeys.IsLogin, true);
      sharedPreferences.setString(ApplicationKeys.Cookie, parsedJson['Cookie']);
      sharedPreferences.setString(ApplicationKeys.FirstName, parsedJson['UserDetails']['firstname']);
      sharedPreferences.setString(ApplicationKeys.LastName, parsedJson['UserDetails']['surname']);
      sharedPreferences.setString(ApplicationKeys.BorrowerNumber, parsedJson['UserDetails']['borrowernumber']);
      sharedPreferences.setString(ApplicationKeys.CardNumber, parsedJson['UserDetails']['cardnumber']);
      sharedPreferences.setString(ApplicationKeys.Category, parsedJson['UserDetails']['categorycode']);
      sharedPreferences.setString(ApplicationKeys.BranchCode, parsedJson['UserDetails']['branchcode']);
      sharedPreferences.setString(ApplicationKeys.Address, parsedJson['UserDetails']['address']);
      sharedPreferences.setString(ApplicationKeys.ZipCode, parsedJson['UserDetails']['zipcode']);
      sharedPreferences.setString(ApplicationKeys.City, parsedJson['UserDetails']['city']);
      sharedPreferences.setString(ApplicationKeys.State, parsedJson['UserDetails']['state']);
      sharedPreferences.setString(ApplicationKeys.UserEmailId, parsedJson['UserDetails']['email']);
      sharedPreferences.setString(ApplicationKeys.UserPhoneNo, parsedJson['UserDetails']['phone']);
      sharedPreferences.setString(ApplicationKeys.Country, parsedJson['UserDetails']['country']);
      sharedPreferences.setString(ApplicationKeys.DateOfExpiry, parsedJson['UserDetails']['dateexpiry']);
      sharedPreferences.setString(ApplicationKeys.UserId, parsedJson['UserDetails']['userid']);

      if(isForeground){
        Timer(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      }
    }
  }
}
