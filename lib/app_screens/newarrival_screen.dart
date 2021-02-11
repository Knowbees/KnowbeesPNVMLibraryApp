import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchAPI.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchBookImageURL.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/details_screen.dart';


class NewArrivalsScreen extends StatefulWidget {
  @override
  _NewArrivalsScreenState createState() => new _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen>{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences sharedPreferences;
  bool isLoading, isForeground;
  String status;
  List bookList;
  int totalIndex;
  Map map;
  Map<String,int> colorsMap;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void initState() {
    isForeground = true;
    initializeUIValues();
    manage();
    super.initState();
  }

  initializeUIValues(){
    isLoading = false;
    totalIndex = 0;

    map = Map();
    map[ApplicationKeys.NewArrivalMenu] = ConfigValues.NewArrivalMenu;

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

  setValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    map[ApplicationKeys.NewArrivalMenu] = sharedPreferences.getString(ApplicationKeys.NewArrivalMenu);
    colorsMap[ApplicationKeys.ColorPrimary] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimary),radix: 16);
    colorsMap[ApplicationKeys.ColorPrimaryDark] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorPrimaryDark),radix: 16);
    colorsMap[ApplicationKeys.ColorAccent] = int.parse(sharedPreferences.getString(ApplicationKeys.ColorAccent),radix: 16);
    colorsMap[ApplicationKeys.AppBarTextColor] = int.parse(sharedPreferences.getString(ApplicationKeys.AppBarTextColor),radix: 16);
    colorsMap[ApplicationKeys.SubTitleColor] = int.parse(sharedPreferences.getString(ApplicationKeys.SubTitleColor),radix: 16);
    setState(() { });
  }

  @override
  void dispose() {
    isForeground = false;
    super.dispose();
  }

  Future manage() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setValues();
    isLoading = true;
    status = null;
    setState(() { });

    String newArrivals = sharedPreferences.getString(ApplicationKeys.NewArrivalList)??'';  /*Stored Data*/
    if(newArrivals.isNotEmpty){
      displayList(newArrivals,true);
    }
    String response = await FetchAPI().fetchData(KohaURLs.NewArrivalURL, null);
    displayList(response,false);

    isLoading = false;
    if(isForeground){
      setState(() { });
    }
    getBookImageURLs();
  }

  void displayList(String response,bool isData){
    try{
      List parsedJson = jsonDecode(response);
      bookList = new List(parsedJson.length);
      for(int n = 0; n < parsedJson.length; n++){
        Map bookMap = new Map();
        bookMap['Biblionumber'] = parsedJson[n]['biblionumber'];
        bookMap['ISBN'] = parsedJson[n]['isbn'];
        bookMap['Title'] = parsedJson[n]['title'];
        bookMap['Author'] = parsedJson[n]['author'];
        bookList[n] = bookMap;
      }
      totalIndex = bookList.length;
      sharedPreferences.setString(ApplicationKeys.NewArrivalList,response);
    } catch(E) {
      print('Exception:- '+E.toString());
      if(!isData){
        status = 'Something went wrong!';
      }
    }
  }

  getBookImageURLs() async {
    print('Getting Images...');
    for(int index = 0; index < bookList.length; index++) {
      String bookImageURL = KohaURLs.BookImageURL + bookList[index]['ISBN'].toString();
      print('BookImageURL:- ' + bookImageURL);
      bookImageURL = bookImageURL.replaceAll(' ', '');
      try {
        var response = await http.get(bookImageURL);
        bookImageURL = FetchBookImageURL().fetchBookImageURL(response.body);
      } catch (E) {
        print('ImageUrlError:- ' + E.toString());
        bookImageURL = null;
      }
      bookList[index]['BookImageURL'] = bookImageURL;
      if(isForeground){
        setState(() { });
      }
    }
  }

  goToDetails(bookList) {
    Navigator.push(context, MaterialPageRoute( builder: (context) => DetailsScreen(bookList)));
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
          title: Text(map[ApplicationKeys.NewArrivalMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
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
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 2,crossAxisSpacing: 10.0, childAspectRatio: 0.55),
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        return Container(
                          child: GestureDetector(
                            onTap: (){goToDetails(bookList[index]);},
                            child: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[

                                  Expanded(
                                    flex: 8,
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      child: Image(
                                          width: 150,
                                          fit: BoxFit.fill,
                                          image: bookList[index]['BookImageURL'] == null ? AssetImage(ConfigValues.DefaultBookImage) : NetworkImage(bookList[index]['BookImageURL'])
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              bookList[index]['Title'],
                                              style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: bookList[index]['Author'] != null ? Text(
                                              'By '+bookList[index]['Author'],
                                              style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorAccent])),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ):Text(''),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: totalIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if(status != null)SliverFillRemaining(
                child: Center(
                  child: Text(status, textAlign: TextAlign.center,),
                )
            ),

            if(isLoading)Center(
              child: CircularProgressIndicator(),
            ),

          ],
        ),
    );
  }

}

