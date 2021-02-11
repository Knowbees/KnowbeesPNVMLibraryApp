import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/home_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/configuration_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SharedPreferences sharedPreferences;
  String companyName, libraryName, appVersion;
  Uint8List libraryIcon;
  bool isConfigured;
  Map<String,int> colorsMap;

  @override
  void initState() {
    initializeUIValues();
    setUIValues();
    setTimer();
    super.initState();
  }

  void initializeUIValues(){
    colorsMap = Map();
    colorsMap[ApplicationKeys.ColorPrimary] = ConfigValues.ColorPrimary;
    colorsMap[ApplicationKeys.ColorPrimaryDark] = ConfigValues.ColorPrimaryDark;
    colorsMap[ApplicationKeys.ColorAccent] = ConfigValues.ColorAccent;
    colorsMap[ApplicationKeys.AppBarTextColor] = ConfigValues.AppBarTextColor;
    colorsMap[ApplicationKeys.SubTitleColor] = ConfigValues.SubTitleColor;
    colorsMap[ApplicationKeys.TableHeadingColor] = ConfigValues.TableHeadingColor;
    colorsMap[ApplicationKeys.TitleColor] = ConfigValues.TitleColor;
    colorsMap[ApplicationKeys.TextColor] = ConfigValues.TextColor;
    companyName = ConfigValues.CompanyName;
    libraryName = ConfigValues.CompanyName;
    appVersion = ConfigValues.AppVersion;
  }

  void setUIValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isConfigured = sharedPreferences.getBool(ApplicationKeys.IsConfigured) ?? false;
    if(isConfigured){
      colorsMap[ApplicationKeys.ColorPrimary] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimary),radix: 16);
      colorsMap[ApplicationKeys.ColorPrimaryDark] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimaryDark),radix: 16);
      colorsMap[ApplicationKeys.ColorAccent] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorAccent),radix: 16);
      colorsMap[ApplicationKeys.AppBarTextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.AppBarTextColor),radix: 16);
      colorsMap[ApplicationKeys.SubTitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.SubTitleColor),radix: 16);}
    else { setState(() { });}
    companyName = sharedPreferences.getString(ApplicationKeys.CompanyName) ?? ConfigValues.CompanyName;
    libraryName = sharedPreferences.getString(ApplicationKeys.LibraryName) ?? ConfigValues.CompanyName;
    String libraryIcon = sharedPreferences.getString(ApplicationKeys.LibraryIcon) ?? null;
    if(libraryIcon != null) this.libraryIcon = base64.decode(libraryIcon);
    appVersion = sharedPreferences.getString(ApplicationKeys.KohaVersion) ?? null;
    if(appVersion != null){ appVersion = ConfigValues.AppVersion+'/'+appVersion; }
    else { appVersion = ConfigValues.AppVersion; }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(libraryName,style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor]))),
            backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
            brightness: Brightness.dark,
          ),
          backgroundColor: Colors.white,
          body: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image(
                      width: 100, height: 100,
                      image: libraryIcon == null ? AssetImage(ConfigValues.DefaultIcon) : MemoryImage(libraryIcon)
                  ),

                  Text(libraryName, style: TextStyle(fontSize: ConfigValues.PageTitlesSize, color: Color(colorsMap[ApplicationKeys.SubTitleColor])),textAlign: TextAlign.center,),
                  Text('Powered By\n'+companyName, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.SubTitleColor])),textAlign: TextAlign.center),
                  Text(appVersion, style: TextStyle(fontSize: ConfigValues.CaptionsTextSize,color: Color(colorsMap[ApplicationKeys.SubTitleColor])),textAlign: TextAlign.center)
                ],
              )
          )
      ),
    );
  }

  void setTimer(){
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        if(isConfigured){
          return HomeScreen();
        } else {
          return ConfigurationScreen();
        }
      }));
    });
  }

}
