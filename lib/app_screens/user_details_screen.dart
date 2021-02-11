import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:flutter/material.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserDetailsScreen extends StatefulWidget {
  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {

  SharedPreferences sharedPreferences;
  Map map;
  Map map1;
  Map<String,int> colorsMap;

  @override
  void initState() {
    initializeUIValues();
    setUIValues();
    setViewValues();
    super.initState();
  }

  initializeUIValues(){
    map1 = Map();
    map1[ApplicationKeys.UserDetailsMenu] = ConfigValues.UserDetailsMenu;
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
    map = new Map();

    List keys = [ApplicationKeys.CardNumber, ApplicationKeys.FirstName,
      ApplicationKeys.LastName, ApplicationKeys.BranchCode,
      ApplicationKeys.Category, ApplicationKeys.UserEmailId,
      ApplicationKeys.UserPhoneNo, ApplicationKeys.State, ApplicationKeys.City,
      ApplicationKeys.Country, ApplicationKeys.Address, ApplicationKeys.ZipCode,
      ApplicationKeys.DateOfExpiry, ApplicationKeys.BorrowerNumber];

    for(String key in keys){
      map[key] = sharedPreferences.getString(key);
    }
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(map1[ApplicationKeys.UserDetailsMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor]))),
          backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
          brightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        drawer: MenuDrawer(),
        body: map != null ? Container(
            margin: EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
                Icon( Icons.account_circle, size: 100),
                Text(map[ApplicationKeys.FirstName]+'\t\t'+ map[ApplicationKeys.LastName]+'\n', textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.ParagraphTextSize,color: Colors.black)),

                Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('User Library Details: \n', textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.ParagraphTextSize,color: Colors.black)),

                                RichText(
                                    text: TextSpan(
                                      text: 'Card Number ',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                      children: <TextSpan>[
                                        TextSpan(text: map[ApplicationKeys.CardNumber], style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                      ],
                                    )
                                ),

                                RichText(
                                    text: TextSpan(
                                      text: 'Branch Name ',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                      children: <TextSpan>[
                                        TextSpan(text: ApplicationKeys.BranchCode, style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                      ],
                                    )
                                ),

                                RichText(
                                    text: TextSpan(
                                      text: 'Category Description ',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                      children: <TextSpan>[
                                        TextSpan(text: ApplicationKeys.Category, style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                      ],
                                    )
                                ),

                                RichText(
                                    text: TextSpan(
                                      text: 'Date Of Expiry ',
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                      children: <TextSpan>[
                                        TextSpan(text: map[ApplicationKeys.DateOfExpiry], style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                      ],
                                    )
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 3),
                                  child: Text('User Contact Details:', style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Colors.black,),),
                                ),

                                if(map[ApplicationKeys.Address] != null)
                                  RichText(
                                      text: TextSpan(
                                        text: 'Address ',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                        children: <TextSpan>[
                                          TextSpan(text: map[ApplicationKeys.Address]+ ', '+map[ApplicationKeys.State]+' '+map[ApplicationKeys.ZipCode]+', '+map[ApplicationKeys.Country], style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                        ],
                                      )
                                  ),

                                if(map[ApplicationKeys.UserEmailId] != null)
                                  RichText(
                                      text: TextSpan(
                                        text: 'Email Id ',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                        children: <TextSpan>[
                                          TextSpan(text: map[ApplicationKeys.UserEmailId], style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                        ],
                                      )
                                  ),

                                if(map[ApplicationKeys.UserPhoneNo] != null)
                                  RichText(
                                      text: TextSpan(
                                        text: 'Contact Number ',
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                        children: <TextSpan>[
                                          TextSpan(text: map[ApplicationKeys.UserPhoneNo], style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                        ],
                                      )
                                  ),

                              ],
                            ),
                        )
                      ],
                    ),
                ),
              ],
            )
        ) : Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}