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

class ReservedBooksScreen extends StatefulWidget {
  @override
  _ReservedBooksScreenState createState() => new _ReservedBooksScreenState();
}

class _ReservedBooksScreenState extends State<ReservedBooksScreen> with WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  SharedPreferences sharedPreferences;
  bool isLoading,isForeground;
  String userName,cardNumber,status, isReserved,loginMenu,webLink,appShareLink;
  List reservedBooksList;
  Map map;
  Map<String,int> colorsMap;
  int totalIndex;

  @override
  void initState() {
    isForeground = true;
    initializeUIValues();
    setUIValues();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    manage();
  }

  initializeUIValues(){
    isLoading = false;
    totalIndex = 0;
    map = Map();
    map[ApplicationKeys.ReservedItemsMenu] = ConfigValues.ReservedItemsMenu;

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
    map[ApplicationKeys.ReservedItemsMenu] = sharedPreferences.getString(ApplicationKeys.ReservedItemsMenu);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future manage() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isLoading = true; status = null;
    setState(() { });
    showInSnackBar('Fetching records!');
    String response = await FetchAPI().fetchData(KohaURLs.GetReservedURL, null);
    displayList(response);
    await showBookImages();
  }

  void displayList(String response){
    try{
      Map parsedJson = jsonDecode(response);
      reservedBooksList = parsedJson['Reserves'];
      isLoading = false;
      if(reservedBooksList.length != 0){
        status = null;
        totalIndex = reservedBooksList.length;
      } else {
        status = 'No Holds!';
      }
    } catch(E) {
      print('Exception:- '+E.toString());
      isLoading = false;
      status = 'Something went wrong!\nTap to refresh.';
    }
    if(isForeground){
      setState(() { });
    }
  }


  showBookImages() async {
    print('Getting Images...');
    FetchBookImageURL fetchBookImageURL = FetchBookImageURL();
    for(int index = 0; index < reservedBooksList.length; index++){
      String isbn = reservedBooksList[index]['ISBN'];
      if(isbn != null){
        reservedBooksList[index]['BookImageURL'] = await fetchBookImageURL.getBookImageURLs(isbn);
        if(isForeground){
          setState(() { });
        }
      }
    }
  }

  gotoScreen(var screen){
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => screen));
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
        title: Text(map[ApplicationKeys.ReservedItemsMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
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
                  onRefresh: onRefresh,
                  child: ListView.builder(
                    itemCount: totalIndex,
                    itemBuilder: (context, index) {
                      return status == null ? GestureDetector(
                          onTap: (){goToDetails(reservedBooksList[index]);},
                          child: Card(
                            margin: EdgeInsets.all(5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Image(
                                      width: 100,
                                      height: 130,
                                      image: reservedBooksList[index]['BookImageURL'] == null ? AssetImage(ConfigValues.DefaultBookImage) : NetworkImage(reservedBooksList[index]['BookImageURL'])
                                  ),
                                  flex: 3,
                                ),

                                Expanded(
                                  child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(reservedBooksList[index]['Title'], style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),overflow: TextOverflow.ellipsis, maxLines: 2,),
                                      RichText(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          text: ConfigValues.ReserveDateHeading+' ',
                                          style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor]),),
                                          children: <TextSpan>[
                                            TextSpan(text:reservedBooksList[index]['ReserveDate'],style: (TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),)
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          text: ConfigValues.BranchNameHeading +':'+' ',
                                          style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor]),),
                                          children: <TextSpan>[
                                            TextSpan(text:reservedBooksList[index]['BranchName'],style: (TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),)
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: AlignmentDirectional.bottomEnd,
                                        child: RaisedButton(
                                          textColor: Color(ConfigValues.whiteColor),
                                          color: Color(ConfigValues.redColor),
                                          onPressed: (){showDialogBox(reservedBooksList[index]);},
                                          child: Text('Cancel',style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,)),
                                        ),
                                      )
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
                  child: Text(status, style:TextStyle(color: Color(colorsMap[ApplicationKeys.ColorPrimary])),textAlign: TextAlign.center,),
                )
            )
          ]
      ),
    );
  }

  void showDialogBox(reservedBooksList){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          content: new Text('Are you sure to cancel hold?',style: TextStyle(fontSize: ConfigValues.ParagraphTextSize ,color: Color(colorsMap[ApplicationKeys.TableHeadingColor])),),
          actions: <Widget>[
            new FlatButton(
              child: new Text('No',style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Yes',style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),),
              onPressed: (){
                cancelReserved(reservedBooksList);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  cancelReserved(Map cancelBookDetails) async {
    isLoading = true;
    setState(() { });

    Map extras = Map();
    extras['biblionumber'] = cancelBookDetails['Biblionumber'];
    extras['reserve_id'] = cancelBookDetails['ReserveId'];

    try{
      String response = await FetchAPI().fetchData(KohaURLs.CancelReservedURL, extras);
      Map map = jsonDecode(response);
      String cancelBiblionumber = map['CancelledItem']['Biblionumber'];
      String cancelReserveId = map['CancelledItem']['ReserveId'];

      if(cancelBookDetails['ReserveId'] == cancelReserveId && cancelBookDetails['Biblionumber'] == cancelBiblionumber){
        manage();
      } else {
        setState(() {
          isLoading = false;
          status = 'Something went wrong!\nTap to refresh.';
        });
      }
    }catch(E){
      print('\n Exception:- '+E.toString());
    }
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
