import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';

class PaymentDetailsScreen extends StatefulWidget {
  @override
  _PaymentDetailsState createState() => new _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetailsScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  SharedPreferences sharedPreferences;
  bool isLoading,isForeground;
  String status,totalDue;
  List paymentList;
  Map map;
  Map<String,int> colorsMap;
  int totalIndex;

  @override
  void initState() {
    isForeground = true;
    initializeUIValues();
    setUIValues();
    manage();
    super.initState();
  }

  initializeUIValues(){
    totalIndex = 0;
    isLoading = true;
    map = Map();
    map[ApplicationKeys.PaymentDetailsMenu] = ConfigValues.PaymentDetailsMenu;

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
    map[ApplicationKeys.PaymentDetailsMenu] = sharedPreferences.getString(ApplicationKeys.PaymentDetailsMenu);
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

  @override
  void dispose() {
    isForeground = false;
    super.dispose();
  }

  Future manage() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isLoading = true; status = null;
    setState(() { });
    showInSnackBar('Fetching records!');
    String paymentDetails = sharedPreferences.getString(ApplicationKeys.PaymentDetails)??'';
    if(paymentDetails.isNotEmpty){
      displayList(paymentDetails);
    }

    String response = await FetchAPI().fetchData(KohaURLs.PaymentDetailsURL, null);
    if(response != null){
      sharedPreferences.setString(ApplicationKeys.PaymentDetails, response);
    }

    isLoading = false;
    displayList(response);
  }

  void displayList(String response){
    try{
      Map parsedJson = jsonDecode(response);
      int totalDue = parsedJson['Total'];
      paymentList = parsedJson['PaymentDetails'];
      totalIndex = paymentList.length;
      if(totalIndex > 0){ status = null;
        if(totalDue == 0){ this.totalDue = 'NIL'; }
        else { this.totalDue = totalDue.toString();} }
      else {status = 'No rocords!'; this.totalDue = null;}
    } catch(E) {
      print('Exception:- '+E.toString());
      status = 'Something went wrong!';
    }

    if(isForeground){
      if(response == null){ showInSnackBar('Fetching failed!'); }
      else { showInSnackBar('Recods are updated!'); }
      setState(() {});
    }
  }

  void onRefresh() async{
    manage();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(map[ApplicationKeys.PaymentDetailsMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
        backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
      ),
      drawer: MenuDrawer(),
      body: Stack(
        children: <Widget>[

          Container(
            child: SmartRefresher(
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: onRefresh,
              child:  CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Container(
                          margin: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                          child: totalDue != null ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 7,
                                      child: Text(ConfigValues.AmountDueHeading,textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: ConfigValues.PageTitlesSize, color: Color(colorsMap[ApplicationKeys.TableHeadingColor]))
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(totalDue,textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: ConfigValues.PageTitlesSize, color: Color(colorsMap[ApplicationKeys.TitleColor]),)
                                      ),
                                    )
                                  ],
                                ),
                              )
                          ):null
                      ),
                    ),

                    SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        return Card(
                          margin: EdgeInsets.only(left: 10, right: 10, top:5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Container(
                                margin: EdgeInsets.all(5),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex : 7,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            paymentList[index]['Date'],
                                            style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor])),
                                          ),

                                          Text(
                                            paymentList[index]['Description'],
                                            style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TextColor])),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                        flex : 3,
                                        child: Center(
                                          child: Text(
                                            ConfigValues.CurrencySymbol+double.parse(paymentList[index]['Amount']).round().toString(),
                                            style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor])),
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                        childCount: totalIndex,
                      ),
                    ),

                    SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                            height: 100
                        ),
                      ]),
                    ),
                  ]
              ),
            ),
          ),

          if(status != null)SliverFillRemaining(
              child: Center(
                  child: GestureDetector(
                    onTap: (){ manage(); },
                    child: Text(status, textAlign: TextAlign.center,),
                  )
              )
          ),

          if(isLoading) Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  void showInSnackBar(String value) {
    if(isForeground){
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(value),
            duration: Duration(seconds: 3),
          )
      );
    }
  }

}
