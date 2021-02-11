import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchAPI.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchBookImageURL.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/login_screen.dart';

class DetailsScreen extends StatefulWidget {

  final Map map;
  DetailsScreen(this.map) : super();

  @override
  _DetailsScreenState createState() => new _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  SharedPreferences sharedPreferences;
  String imageURL, holdStatus;
  bool isImageVisible,isLoading,isForeground,isError,isHolding;
  Map bookDetails;
  Map map;
  Map<String,int> colorsMap;

  @override
  void initState() {
    isForeground = true;
    initializeUIValues();
    manage();
    super.initState();
  }

  @override
  void dispose() {
    isForeground = false;
    super.dispose();
  }

  initializeUIValues(){
    map = Map();
    map[ApplicationKeys.ItemDetailsMenu] = ConfigValues.ItemDetailsMenu;

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

  manage() async {
    setUIValues();
    fetchDetails();
  }

  setUIValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    map[ApplicationKeys.ItemDetailsMenu] = sharedPreferences.getString(ApplicationKeys.ItemDetailsMenu);

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

  Future fetchDetails() async {
    isLoading = true;
    isImageVisible = false;
    isError = false;
    isHolding = false;

    Map params = widget.map;
    print('Data:- '+params.toString());

    Map extras = Map();
    extras['biblionumber'] = params['Biblionumber'];
    String bookDetailsURL = await FetchAPI().fetchData(KohaURLs.DetailsURL, extras);
    print('\n BookDetails URL:- '+bookDetailsURL);

    try{
      bookDetails = jsonDecode(bookDetailsURL);
      Map bookInformation = bookDetails['BookDetails']['BookInformation'];
      int noOfCopies = bookDetails['BookDetails']['NoOfCopies'];

      isLoading = false;
      isImageVisible = true;
      bookDetails[ApplicationKeys.Biblionumber] = params['Biblionumber'];
      bookDetails[ApplicationKeys.BookTitle] = params['Title'] ?? null;
      bookDetails[ApplicationKeys.AuthorName] = params['Author'] ?? null;
      bookDetails[ApplicationKeys.NoOfCopies] = noOfCopies ?? null;
      bookDetails[ApplicationKeys.Barcode] = bookInformation['barcode'] ?? null;
      bookDetails[ApplicationKeys.AvailableAt] = bookInformation['branchname'] ?? null;
      bookDetails[ApplicationKeys.Description] = bookInformation['description'] ?? null;
      bookDetails[ApplicationKeys.AboutBook] = bookInformation['abstract'] ?? null;
      bookDetails[ApplicationKeys.ISBN] = bookInformation['isbn'] ?? null;
      getBookImageURLs(bookDetails[ApplicationKeys.ISBN]);
    } catch(E){
      print('\n Exception:- '+E.toString());
      isError = true;
      isLoading = false;
    }
    if(isForeground) {
      setState(() { });
    }
  }

  getBookImageURLs(String isbn) async {
    if(isbn != null){
      isbn = isbn.replaceAll(' ', '');
      try{
        var response = await http.get(KohaURLs.BookImageURL + isbn);
        imageURL = FetchBookImageURL().fetchBookImageURL(response.body);
        print('BookImageURL:-'+imageURL);
      } catch(E){
        print('\n ImageURLError:- '+E.toString());
        imageURL = null;
      }
      if(isForeground){
        setState(() { });
      }
    }
  }

  void onRefresh() async{
    fetchDetails();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(map[ApplicationKeys.ItemDetailsMenu],style: TextStyle(color: Color(colorsMap[ApplicationKeys.AppBarTextColor])),),
        backgroundColor: Color(colorsMap[ApplicationKeys.ColorPrimary]),
      ),
      drawer: MenuDrawer(),
      body: Stack(
        children: <Widget>[

          if(!isLoading && !isError)
            Container(
              child: SmartRefresher(
                enablePullDown: true,
                controller: _refreshController,
                onRefresh: onRefresh,
                child:  SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[

                        Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[

                              Container(
                                margin: EdgeInsets.all(10),
                                child: Text(bookDetails[ApplicationKeys.BookTitle],
                                  style: TextStyle(fontSize: ConfigValues.ParagraphTextSize,color: Color(colorsMap[ApplicationKeys.TitleColor])),
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(10),
                                      child: SizedBox(
                                        height: 250.0,
                                        child: Container(
                                          margin: EdgeInsets.all(10),
                                          child: Image(
                                              image: imageURL == null ? AssetImage(ConfigValues.DefaultBookImage) : NetworkImage(imageURL)
                                          ),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(top: 20.0, left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('About this book:\n',style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TableHeadingColor]),fontWeight:FontWeight.bold),
                                              textAlign: TextAlign.start),

                                          if(bookDetails[ApplicationKeys.AuthorName] != null)
                                            RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                  text: 'By ',
                                                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                                  children: <TextSpan>[
                                                    TextSpan(text: bookDetails[ApplicationKeys.AuthorName], style: TextStyle(color: Color(colorsMap[ApplicationKeys.TextColor])),),
                                                  ],
                                                )
                                            ),

                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              if(bookDetails[ApplicationKeys.Description] != null)
                                                RichText(
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                      text: bookDetails[ApplicationKeys.Description] +' '+'Barcode'+' ',
                                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                                      children: <TextSpan>[
                                                        if(bookDetails[ApplicationKeys.Barcode] != null)
                                                          TextSpan(text: bookDetails[ApplicationKeys.Barcode],style: TextStyle(fontWeight: FontWeight.bold,color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                                      ],
                                                    )
                                                ),
                                            ],
                                          ),

                                          if(bookDetails[ApplicationKeys.AvailableAt] != null)
                                            RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                    text: ConfigValues.BranchNameHeading +' ',
                                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                                    children: <TextSpan>[
                                                      TextSpan(text: bookDetails[ApplicationKeys.AvailableAt],style: TextStyle(fontWeight: FontWeight.bold,color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                                    ]
                                                )
                                            ),

                                          if(bookDetails[ApplicationKeys.ISBN] != null)
                                            RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                    text: 'ISBN ',
                                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                                    children: <TextSpan>[
                                                      TextSpan(text: bookDetails[ApplicationKeys.ISBN],style: TextStyle(fontWeight: FontWeight.bold,color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                                    ]
                                                )
                                            ),

                                          if(bookDetails[ApplicationKeys.NoOfCopies] != null)
                                            RichText(
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                text: TextSpan(
                                                    text: 'Number of copies ',
                                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                                    children: <TextSpan>[
                                                      TextSpan(text: bookDetails[ApplicationKeys.NoOfCopies].toString(),style: TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                                    ]
                                                )
                                            ),

                                          if(bookDetails[ApplicationKeys.AboutBook] != null)
                                            RichText(
                                                text: TextSpan(
                                                    text: '\nSummary\n\t\t\t',
                                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),),
                                                    children: <TextSpan>[
                                                      TextSpan(text: bookDetails[ApplicationKeys.AboutBook],style: TextStyle(color:Color(colorsMap[ApplicationKeys.TextColor]))),
                                                    ]
                                                )
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 15,left: 5,right: 5),
                          child: !isHolding ? Container(
                              child: RaisedButton(
                                onPressed: (){reserveBook();},
                                textColor: Color(ConfigValues.whiteColor),
                                color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),
                                child: Text(ConfigValues.ReserveItemHeading, style: TextStyle(fontSize: ConfigValues.ButtonsTextSize),textAlign: TextAlign.center),
                              )
                          ): Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),

                        if(holdStatus != null) Container(
                          margin: EdgeInsets.all(15),
                          child: Text(holdStatus,
                              style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.TextColor])),
                              textAlign: TextAlign.center
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if(isLoading) Center(
            child: CircularProgressIndicator(),
          ),

          if(isError) Center(
            child:Text('Something went wrong!',
                style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,color: Color(colorsMap[ApplicationKeys.ColorPrimary])),
                textAlign: TextAlign.center),
          ),
        ],
      ),

    );
  }

  Future reserveBook() async {
    bool isLogin = sharedPreferences.getBool(ApplicationKeys.IsLogin) ?? false;
    if(!isLogin){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => LoginScreen()));
      return;
    }

    isHolding = true;
    holdStatus = null;
    setState(() {});

    try{
      Map params = Map();
      params['biblionumber'] = bookDetails[ApplicationKeys.Biblionumber];
      String response = await FetchAPI().fetchData(KohaURLs.SetReserveURL, params);
      Map map = jsonDecode(response);
      if(map['IsReserve'] == 'True'){
        holdStatus = 'Hold Successful!';
      } else {
        holdStatus = map['Error'];
      }
    } catch(E) {
      holdStatus = 'Something went wrong!';
    }

    isHolding = false;
    setState(() { });
  }

}
