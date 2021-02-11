import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchAPI.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchBookImageURL.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/details_screen.dart';


class ReadingHistoryScreen extends StatefulWidget {
  @override
  _ReadingHistoryScreenState createState() => new _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool isLoading,isForeground;
  String status;
  List readingHistoryList;
  int totalIndex;
  Map map;
  Map<String,int> colorsMap;
  SharedPreferences sharedPreferences;

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
    map[ApplicationKeys.ReadingHistoryMenu] = ConfigValues.ReadingHistoryMenu;
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
    map[ApplicationKeys.ReadingHistoryMenu] = sharedPreferences.getString(ApplicationKeys.ReadingHistoryMenu);
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
    showInSnackBar('Fetching records!');
    isLoading = true; status = null;
    setState(() { });
    String readingHistory = sharedPreferences.getString(ApplicationKeys.ReadingHistory)??'';  /*Stored Data*/
    if(readingHistory.isNotEmpty){
      displayList(readingHistory);
    }
    String response = await FetchAPI().fetchData(KohaURLs.ReadingHistoryURL, null);
    if(response != null){
      sharedPreferences.setString(ApplicationKeys.ReadingHistory, response);
    }
    isLoading = false;

    displayList(response);
    await showBookImages();
  }

  void displayList(String response){
    try{
      Map parsedJson = jsonDecode(response);
      readingHistoryList = parsedJson['ReadingHistory'];
      totalIndex = readingHistoryList.length;
      if(totalIndex > 0){ status = null; }
      else { status = 'Checkout your first book!'; }
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

  showBookImages() async {
    print('Getting Images...');
    FetchBookImageURL fetchBookImageURL = FetchBookImageURL();
    for(int index = 0; index < readingHistoryList.length; index++){
      String isbn = readingHistoryList[index]['ISBN'];
      if(isbn != null){
        readingHistoryList[index]['BookImageURL'] = await fetchBookImageURL.getBookImageURLs(isbn);
        if(isForeground){
          setState(() { });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(map[ApplicationKeys.ReadingHistoryMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
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
                  child: ListView.builder(
                    itemCount: totalIndex,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute( builder: (context) => DetailsScreen(readingHistoryList[index])));
                        },
                        child: Card(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Image(
                                    width: 100,
                                    height: 130,
                                    image: readingHistoryList[index]['BookImageURL'] == null ? AssetImage(ConfigValues.DefaultBookImage) : NetworkImage(readingHistoryList[index]['BookImageURL'])
                                ),
                                flex: 3,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text( readingHistoryList[index]['Title'], style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),overflow: TextOverflow.ellipsis, maxLines: 2,),
                                    RichText(
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        text: 'Status : '+' ',
                                        style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor]),),
                                        children: <TextSpan>[
                                          TextSpan(text:readingHistoryList[index]['Status'],style: (TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                flex: 7,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
              ),
            ),

            if(isLoading) Center(
              child: CircularProgressIndicator(),
            ),

            if(status != null)Center(
              child: Text(status,style:TextStyle(color: Color(ConfigValues.ColorPrimary)),textAlign: TextAlign.center,),
            )
          ]
      ),
    );
  }

  void onRefresh() async{
    manage();
    _refreshController.refreshCompleted();
  }

  showInSnackBar(String text) {
    if(isForeground){
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(text),
            duration: Duration(seconds: 3),
          )
      );
    }
  }
}

