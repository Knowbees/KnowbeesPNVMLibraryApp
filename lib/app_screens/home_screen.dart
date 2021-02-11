import 'dart:convert';
import 'dart:typed_data';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/search_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  SharedPreferences sharedPreferences;
  bool isLogin, isLoading;
  String  logInOutMenu, userName, cardNumber, status;
  List bannerList;
  Map map;
  Map<String,int> colorsMap;
  int totalIndex;

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
    map[ApplicationKeys.WelcomeMessage] = ConfigValues.WelcomeMessage;
    map[ApplicationKeys.AboutLibrary] = '';

    map[ApplicationKeys.NewArrivalMenu] = ConfigValues.NewArrivalMenu;
    map[ApplicationKeys.PaymentDetailsMenu] = ConfigValues.PaymentDetailsMenu;
    map[ApplicationKeys.IssuedItemsMenu] = ConfigValues.IssuedItemsMenu;
    map[ApplicationKeys.ReadingHistoryMenu] = ConfigValues.ReadingHistoryMenu;
    map[ApplicationKeys.ReservedItemsMenu] = ConfigValues.ReservedItemsMenu;
    map[ApplicationKeys.LoginMenu] = ConfigValues.LoginMenu;
    map[ApplicationKeys.LogoutMenu] = ConfigValues.LogoutMenu;
    logInOutMenu = map[ApplicationKeys.LoginMenu];
    map[ApplicationKeys.WebLinkMenu] = ConfigValues.WebLinkMenu;
    map[ApplicationKeys.ShareMenu] = ConfigValues.ShareMenu;
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

  Future manage() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setUI();
    setLoginUser();
  }

  setUI(){
    map[ApplicationKeys.LibraryName] = sharedPreferences.getString(ApplicationKeys.LibraryName);
    map[ApplicationKeys.WelcomeMessage] = sharedPreferences.getString(ApplicationKeys.WelcomeMessage);
    map[ApplicationKeys.AboutLibrary] = sharedPreferences.getString(ApplicationKeys.AboutLibrary);

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

    colorsMap[ApplicationKeys.ColorPrimary] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimary),radix: 16);
    colorsMap[ApplicationKeys.ColorPrimaryDark] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimaryDark),radix: 16);
    colorsMap[ApplicationKeys.ColorAccent] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorAccent),radix: 16);
    colorsMap[ApplicationKeys.AppBarTextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.AppBarTextColor),radix: 16);
    colorsMap[ApplicationKeys.SubTitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.SubTitleColor),radix: 16);
    colorsMap[ApplicationKeys.TextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.TextColor),radix: 16);
    setState(() {});

    bannerList = List();
    int n = 0;
    while(true){
      try{
        Uint8List bytes = base64.decode(sharedPreferences.getString(ApplicationKeys.Poster+'-'+n.toString()));
        bannerList.add(bytes);
        n++;
      } catch(E){
        print('1.Exception:- '+E.toString());
        break;
      }
    }
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

  @override
  Widget build(BuildContext context) {

    if(isLogin != null){
      setLoginUser();
    }

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(map[ApplicationKeys.WelcomeMessage],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor]))),
          backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SearchScreen()));
              },
            ),
          ],
        ),
        body: CustomScrollView(

            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                    margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                    child:Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: bannerList != null? CarouselSlider(
                                height: 280.0,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration: Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                pauseAutoPlayOnTouch: Duration(seconds: 10),
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index){
                                  setState(() {});
                                },
                                viewportFraction: 1.0,
                                items: bannerList.map((image) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                                        decoration: BoxDecoration(
                                        ),
                                        child: Image.memory(image,fit: BoxFit.cover,),
                                      );
                                    },
                                  );
                                }).toList(),
                              ):Container(height: 200),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 70),
                            child: Text('\t'+ map[ApplicationKeys.AboutLibrary],textAlign: TextAlign.justify,style: TextStyle(height:1.5,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.SubTitleColor]),),),
                          )
                        ],
                      ),
                    )
                ),
              ),

            ],

        ),
        drawer: MenuDrawer(),
      ),
    );
  }

  Future<bool> onWillPop() {
    SystemNavigator.pop();
  }
}

