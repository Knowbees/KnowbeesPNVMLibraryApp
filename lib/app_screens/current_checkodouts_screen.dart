import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchAPI.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchBookImageURL.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/details_screen.dart';


class CurrentCheckedOutsScreen extends StatefulWidget {
  @override
  _CurrentCheckedOutsState createState() => new _CurrentCheckedOutsState();
}

class _CurrentCheckedOutsState extends State<CurrentCheckedOutsScreen> with WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  SharedPreferences sharedPreferences;
  bool isLoading,isForeground;
  String status;
  List issuedBooksList;
  Map map;
  Map<String,int> colorsMap;
  int totalIndex;

  get keyboardDismissBehavior => null;

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
    isLoading = false;

    map = Map();
    map[ApplicationKeys.IssuedItemsMenu] = ConfigValues.IssuedItemsMenu;

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
    map[ApplicationKeys.IssuedItemsMenu] = sharedPreferences.getString(ApplicationKeys.IssuedItemsMenu);

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
    showInSnackBar('Fetching Records...');
    String response = await FetchAPI().fetchData(KohaURLs.IssuedURL, null);
    displayList(response);
    await showBookImages();
  }

  void displayList(String response){
    try{
      Map parsedJson = jsonDecode(response);
      issuedBooksList = parsedJson['Issues'];
      totalIndex = issuedBooksList.length;
      if(totalIndex > 0){status = null;}
      else {status = 'No Checkout!';}
    } catch(E) {
      print('Exception:- '+E.toString());
      status = 'Something went wrong!';
    }
    isLoading = false;
    if(isForeground){
      setState(() {});
    }
  }

  showBookImages() async {
    print('Getting Images...');
    FetchBookImageURL fetchBookImageURL = FetchBookImageURL();
    for(int index = 0; index < issuedBooksList.length; index++){
      String isbn = issuedBooksList[index]['ISBN'];
      if(isbn != null){
        issuedBooksList[index]['BookImageURL'] = await fetchBookImageURL.getBookImageURLs(isbn);
        if(isForeground){
          setState(() { });
        }
      }
    }
  }


  void _onRefresh() async{
    manage();
    _refreshController.refreshCompleted();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(map[ApplicationKeys.IssuedItemsMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
        backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
      ),
      drawer: MenuDrawer(),
      body: Stack(
          children: <Widget>[
            if(!isLoading)
              Container(
                child: SmartRefresher(
                  enablePullDown: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    itemCount: totalIndex,
                    itemBuilder: (context, index) {
                      return status == null ? GestureDetector(
                          onTap: (){goToDetails(issuedBooksList[index]);},

                          child: Card(
                            margin: EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Image(
                                      width: 100,
                                      height: 130,
                                      image: issuedBooksList[index]['BookImageURL'] == null ? AssetImage(ConfigValues.DefaultBookImage) : NetworkImage(issuedBooksList[index]['BookImageURL'])
                                  ),
                                  flex: 3,
                                ),

                                Expanded(
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(issuedBooksList[index]['Title'], style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),overflow: TextOverflow.ellipsis, maxLines: 2,),
                                      RichText(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          text: ConfigValues.IssuedDateHeading,
                                          style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor]),),
                                          children: <TextSpan>[
                                            TextSpan(text:issuedBooksList[index]['IssueDate'],style: (TextStyle(fontSize: ConfigValues.SecondaryTextSize,color:Color(colorsMap[ApplicationKeys.TextColor]))),)
                                          ],
                                        ),
                                      ),

                                      RichText(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          text: ConfigValues.DueDateHeading,
                                          style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor]),),
                                          children: <TextSpan>[
                                            TextSpan(text:issuedBooksList[index]['DueDate'],
                                              style: (TextStyle(fontSize: ConfigValues.SecondaryTextSize,color:Color(colorsMap[ApplicationKeys.TextColor]))),
//                                                  overflow: TextOverflow.ellipsis, maxLines: 2,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  flex: 7,
                                )
                              ],
                            ),
                          )

                      ): null;
                    },
                  ),
                ),
              ),


            if(isLoading) Center(
              child: CircularProgressIndicator(),
            ),

            if(status != null)Center(
                child: GestureDetector(
                  onTap: (){ manage(); },
                  child: Text(status, textAlign: TextAlign.center,style: TextStyle(color: Color(colorsMap[ApplicationKeys.ColorPrimary])),),
                )
            )
          ]
      ),
    );
  }

  goToDetails(bookList) {
    Navigator.push(context, MaterialPageRoute( builder: (context) => DetailsScreen(bookList)));
  }


  showInSnackBar(String value) {
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
