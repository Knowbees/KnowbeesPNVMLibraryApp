import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:flutter/material.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  SharedPreferences sharedPreferences;
  String contactEmail ,contactNo;
  Map map;
  Map<String,int> colorsMap;

  @override
  void initState() {
    initializeUIValues();
    setUIValues();
    setViewValues();
    super.initState();

  }

  initializeUIValues(){
    map = Map();
    map[ApplicationKeys.ContactMenu] = ConfigValues.ContactMenu;

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
    colorsMap[ApplicationKeys.ColorPrimary] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimary),radix: 16);
    colorsMap[ApplicationKeys.ColorPrimaryDark] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimaryDark),radix: 16);
    colorsMap[ApplicationKeys.ColorAccent] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorAccent),radix: 16);
    colorsMap[ApplicationKeys.AppBarTextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.AppBarTextColor),radix: 16);
    colorsMap[ApplicationKeys.SubTitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.SubTitleColor),radix: 16);
    colorsMap[ApplicationKeys.TableHeadingColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TableHeadingColor),radix: 16);
    colorsMap[ApplicationKeys.TitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TitleColor),radix: 16);
    colorsMap[ApplicationKeys.TextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TextColor),radix: 16);
    setState(() {});
  }

  void setViewValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      contactEmail = sharedPreferences.getString('ContactEmailId') ;
      contactNo = sharedPreferences.getString('ContactNumber')  ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(map[ApplicationKeys.ContactMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor]))),
          backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
          brightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        drawer: MenuDrawer(),
        body: Container(
            margin: EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
                Text('Contact To Library', textAlign: TextAlign.center,style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.ColorAccent]))),
                Container(
                  margin: EdgeInsets.only(top: 10,left:10),
                  child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            contactMail();
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                                children: <Widget>[
                                  if(contactEmail != null)
                                    RichText(
                                        text: TextSpan(
                                            text: 'Contact Email Id :',
                                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                            children: <TextSpan>[
                                              TextSpan(text: '\t'+ contactEmail,style: TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                            ]
                                        )
                                    ),
                                ]
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: (){
                            callPhone();
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 7),
                            child: Row(
                                children: <Widget>[
                                  if(contactNo != null)
                                    RichText(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                          text: 'Contact Number:',
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                          children: <TextSpan>[
                                            TextSpan(text: '\t\t'+contactNo,style: TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                          ]
                                      )
                                    ),
                                ]
                            ),
                          ),
                        )
                      ]
                  ),
                )
              ],
            )
        )
    );
  }


  contactMail() async{
    final String emailContext = 'mailto:' + contactEmail+ '?subject=' + 'Contact to Library' ;
    try {
      await launch(emailContext);
    } catch (e) {
      print('Exception: '+e.toString());
    }
  }

  callPhone() async {
    final String phoneContext = 'tel:'+contactNo;
    if (await canLaunch(phoneContext)) {
      await launch(phoneContext);
    } else {
      Fluttertoast.showToast(
          msg: 'You Can not Call',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print('cant call');
    }
  }
}