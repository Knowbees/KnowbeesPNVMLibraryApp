import 'dart:async';
import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/menus.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/multichoice.dart';
import 'package:com.knowbees.pnvmlibraryapp/modulas/FetchBookImageURL.dart';
import 'details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/recentsearch_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => new _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  SharedPreferences sharedPreferences;
  String  selectedCatlog,selectedBranch,selectedcatlogItem,selectedbranchItems, searchCategory, searchWord, searchStatus, status;
  int totalIndex, currentPageNo, totalPageNo, totalBooksCount;
  List bookList;
  List<String> catlogItemList,catlogItemsValueList,branchItemsList,branchItemsCodeList;
  Map<String,int> colorsMap;
  final searchWordEt = TextEditingController();
  bool isPageLayout,isBackVisible,isNextVisible,isLoading,isStatus,isForeground,isFilter,isSelectedBranch,isSelectedCatlog,isbranch,isDivider;
  StreamSubscription<List> streamSubscription;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void initState() {
    isForeground = true;
    initializeUIValues();
    setUIValues();
    manage();
    super.initState();
  }

  @override
  void dispose() {
    isForeground = false;
    super.dispose();
  }

  initializeUIValues() {
    totalIndex = currentPageNo = totalPageNo = totalBooksCount = 0;
    isPageLayout = isBackVisible = isNextVisible = isLoading = isStatus = isFilter = false;
    isSelectedBranch = isSelectedCatlog  = false;
    searchStatus = 'Search for something';

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
    setState(() { });
  }

  manage() async {
    setCatlogList();
    _showSearch();
  }

  setCatlogList(){
    catlogItemList = KohaURLs.SearchCategoriesKeys;
    catlogItemsValueList = KohaURLs.ItemSearchCategoriesValues;

    selectedcatlogItem = catlogItemList[0];
    int index1 = catlogItemList.indexOf(selectedcatlogItem);
    selectedcatlogItem = catlogItemsValueList.elementAt(index1);

  }

  setBranch(){
    if(selectedbranchItems == null){
      selectedbranchItems = selectedbranchItems.toString().replaceAll('null', '');
      setState(() { });
    }
  }


  void changeCatlogItem(String selectedcatlogItem){
    Navigator.of(context).pop();
    isSelectedCatlog = true;
    int index = catlogItemList.indexOf(selectedcatlogItem);
    selectedcatlogItem = catlogItemsValueList.elementAt(index);
    if(this.selectedcatlogItem.compareTo(selectedcatlogItem) != 0){
      searchBook();
    }
    this.selectedcatlogItem = selectedcatlogItem;
    setState(() { });
  }

  void changebranchItem( String selectedbranchItems){
    Navigator.of(context).pop();
    isSelectedBranch = true;
    int index = branchItemsList.indexOf(selectedbranchItems);
    selectedbranchItems = branchItemsCodeList.elementAt(index);
    if(this.selectedbranchItems.compareTo(selectedbranchItems) != 0){
      searchBook();
    }
    this.selectedbranchItems = selectedbranchItems;
    setState(() { });
  }

  Future searchBook() async {
    String websiteURL = sharedPreferences.getString(ApplicationKeys.KohaURL);
    if(searchWord == null || searchWord.isEmpty){ return; }
    else{
      await saveToRecentSearches(searchWord);
      isPageLayout = isStatus = false; isLoading = true;
      totalIndex = 0; searchStatus = 'Searching...';
      setState(() { });
    }

    setBranch();

    String searchBookURL = websiteURL + '/' + KohaURLs.SearchScript.toString() + selectedcatlogItem.toString() + searchWord.toString()+ KohaURLs.BranchCategoryValue +selectedbranchItems.toString() + KohaURLs.SearchOffset.toString() +(currentPageNo * 20).toString() + KohaURLs.SearchSortBy.toString();
    print('\n Search URL:- '+searchBookURL);

    try{
      var response = await http.get(searchBookURL);
      String responseBody = utf8.decode(response.bodyBytes);
      print('\nParsing Search Word Web Response:-\n'+responseBody);
      print('\n\t--XXX-\n');
      Map parsedJson = jsonDecode(responseBody);
      totalBooksCount = parsedJson['TotalBooksCount'];
      totalPageNo = (totalBooksCount/20).ceil();
      List bookList = parsedJson['ItemsList'];
      List branchList = parsedJson['Branches'];
      List<String> branchNameList =  new List();
      List<String> branchCodeList = new List();

      for( var i=0;i<branchList.length;i++) {
        Map branchListMap = branchList[i];
        branchNameList.add(branchListMap['BranchName'].toString());
        branchCodeList.add(branchListMap['BranchCode'].toString());
      }
      if(branchNameList.length == 1){
        isbranch = false;
        isDivider = false;
      }else {
        isbranch = true;
        isDivider = true;
      }
      branchItemsList = branchNameList;
      branchItemsCodeList = branchCodeList;
      this.bookList = bookList;
      totalIndex = bookList.length;
      isFilter = true;

      print('Total Book Count:- '+totalBooksCount.toString());
      print('Total Page Nos:- '+totalPageNo.toString());
      print('Current Page:- '+currentPageNo.toString());
      print('Total Books On Page:- '+totalIndex.toString());

      try{ streamSubscription.cancel(); } catch(E){ }

      setPageLayout();
      streamSubscription = getBookImageURLs(bookList).asStream().listen((List books) async {
        this.bookList = books;
        if(isForeground){
          setState(() { });
        }
      });
    } catch(E){
      print('\nException:- '+E.toString());
      if(isForeground){
        isLoading  = isFilter = false;
        isStatus = true;
        status = 'Something went wrong!';
        setState(() { });
      }
    }
  }

  Future<List> getBookImageURLs(List parsedJson) async {
    print('Getting Images...');
    for(int index = 0; index < parsedJson.length; index++) {
      String isbn = parsedJson[index]['isbn'];
      String bookImageURL = KohaURLs.BookImageURL + isbn.toString();
      bookImageURL = bookImageURL.replaceAll(' ', '');
      try{
        var response = await http.get(bookImageURL);
        bookImageURL = FetchBookImageURL().fetchBookImageURL(response.body);
      } catch(E){
        print('ImageUrlError:- '+E.toString());
        bookImageURL = null;
      }
      parsedJson[index]['BookImageURL'] = bookImageURL;
//      print(index.toString()+'. ISBN:- '+isbn.toString()+ ', BookImageURL:- '+bookImageURL.toString());
    }
    return parsedJson;
  }

  setPageLayout(){
    if(currentPageNo > 0){ isBackVisible = true; } else { isBackVisible = false; }
    if(currentPageNo < totalPageNo-1){ isNextVisible = true;} else { isNextVisible = false; }
    if(totalPageNo > 1){ isPageLayout = true; } else { isPageLayout = false; }
    if(totalIndex == 0){ isStatus = true; status = 'No book found!'; };
    if(isForeground){
      searchStatus = 'Found ' + totalBooksCount.toString() +' result of '+"'"+searchWord+"'";
      isLoading = false;
      setState(() { });
    }
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Catalog Filter",style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,fontWeight: FontWeight.bold),),
            content: Container(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: MultiSelectChip(
                          catlogItemList ,
                         onSelectionChanged: (selectedList) {
                            setState(() {
                              selectedcatlogItem = selectedList;
                            });
                            selectedCatlog = selectedList.toString();
                            changeCatlogItem(selectedcatlogItem);
                          },
                        ),
                      ),
                      Container(
                        child:Visibility(
                          visible: isSelectedCatlog,
                          child:
                          selectedCatlog != null ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text('Selected Catalog ',style: TextStyle(color: Colors.blue),),
                              RaisedButton(
                                color: Colors.lightBlue.shade100,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                onPressed: () {},
                                child: Text(selectedCatlog,style: TextStyle(color: Colors.blue),),
                              )
                            ],
                          ):Text(''),
                        )
                      ),
                  ],
                ),
                ),

                Container(
                  child: Visibility(
                    visible: isDivider,
                    child: Divider(
                      height: 50,
                      color: Colors.black,
                    ),
                  )
                ),

                    Container(
                      child: Visibility(
                        visible: isbranch,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text('Branch Filter',style: TextStyle(fontSize: ConfigValues.SecondaryTextSize,fontWeight: FontWeight.bold),),
                            ),
                            Container(
                              child: Center(
                                child: Container(
                                  child: MultiSelectChip(
                                    branchItemsList ,
                                    onSelectionChanged: (selectedList) {
                                      setState(() {
                                        selectedbranchItems = selectedList;
                                      });
                                      selectedBranch = selectedList.toString();
                                      changebranchItem(selectedbranchItems);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child:Visibility(
                                visible: isSelectedBranch,
                                child: selectedBranch != null ?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text('Selected Branch ',style: TextStyle(color: Colors.blue),),
                                    Expanded(
                                      child: RaisedButton(
                                        color: Colors.lightBlue.shade100,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        onPressed: () {},
                                        child: Text(selectedBranch,textAlign:TextAlign.center ,style: TextStyle(color: Colors.blue),) ,
                                      ),
                                    ),
                                  ],
                                ):Text(''),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Clear Filter'),
                onPressed: () => clearFilter(),
              ),
              FlatButton(
                child: Text("Done"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  void _onRefresh() async{
    searchBook();
    _refreshController.refreshCompleted();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      body: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor:Color(colorsMap[ApplicationKeys.ColorPrimary]),
              snap: true,
              title: searchWord != null ? Text(searchWord,style: TextStyle(fontSize: ConfigValues.PageTitlesSize,),):Text('Search'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _showSearch();
                  },
                ),
              ],
            ),

            SliverToBoxAdapter(
              child:  Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                         Container(
                           child: Visibility(
                             visible: isFilter,
                             child:  RaisedButton(
                               textColor: Colors.white,
                               color: Color(colorsMap[ApplicationKeys.ColorPrimaryDark]),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(25.0),
                               ),
                               child: SizedBox(
                                 width: 80,
                                 height: 40,
                                 child: Center(
                                   child: Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                     children: <Widget>[

                                       Container(
                                         child: Text('Filter', style: TextStyle(fontSize: ConfigValues.ButtonsTextSize),textAlign: TextAlign.center),
                                       ),
                                       Container(
                                         child: Icon(Icons.arrow_drop_down),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                               onPressed: (){
                                 _showDialog();
                               },
                             ),
                           ),
                         ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(searchStatus, textAlign: TextAlign.start, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize, color: Colors.blue)),
                    ),
                  ]
              ),
            ),

            if(isLoading)SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                )
            ),

            if(isStatus)SliverFillRemaining(
                child:  Center(
                  child: Text(status,textAlign: TextAlign.center, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize, color: Color(colorsMap[ApplicationKeys.ColorAccent]))),
                )
            ),

            if(!isLoading && !isStatus) SliverGrid(
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

            if(isPageLayout) SliverList(
              delegate: SliverChildListDelegate([

                Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Visibility(
                              visible: isBackVisible,
                              child:GestureDetector(
                                  onTap: (){currentPageNo--; searchBook();},
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.navigate_before, color: Colors.blue),
                                        Text('Previous',textAlign: TextAlign.center,style: TextStyle(fontSize: ConfigValues.ButtonsTextSize,fontWeight: FontWeight.bold ,color: Color(colorsMap[ApplicationKeys.TitleColor])),),
                                      ]
                                  )
                              )
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Text((currentPageNo+1).toString()+' of '+totalPageNo.toString(), style: TextStyle(fontSize: ConfigValues.ButtonsTextSize,fontWeight: FontWeight.bold ,color: Color(colorsMap[ApplicationKeys.TitleColor])), textAlign: TextAlign.center),
                        ),

                        Expanded(
                          flex: 1,
                          child: Visibility(
                              visible: isNextVisible,
                              child: GestureDetector(
                                onTap: (){currentPageNo++; searchBook();},
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text('Next',textAlign: TextAlign.center,style: TextStyle(fontSize: ConfigValues.ButtonsTextSize,fontWeight: FontWeight.bold,color: Color(colorsMap[ApplicationKeys.TitleColor])),),
                                    Icon(Icons.navigate_next, color: Colors.blue),
                                  ],
                                ),
                              )
                          ),
                        )
                      ],
                    )
                ),

              ]),
            ),

          ],
        ),
      ),
    );
  }

  goToDetails(bookList) {
    Navigator.push(context, MaterialPageRoute( builder: (context) => DetailsScreen(bookList)));
  }

  clearFilter(){
    Navigator.of(context).pop();
    isSelectedCatlog = false;
    isSelectedBranch = false;
    setCatlogList();
    if(selectedbranchItems != null){
      selectedbranchItems = selectedbranchItems.toString().replaceAll(selectedbranchItems, '');
      setState(() { });
    }
    searchBook();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = List();
    for (String category in KohaURLs.SearchCategoriesKeys) {
      items.add(DropdownMenuItem(
          value: category,
          child: Text(category, style: TextStyle(color: Color(colorsMap[ApplicationKeys.TableHeadingColor])),)
      ));
    }
    return items;
  }

  Future<void> _showSearch() async {
    searchWord = await showSearch<String>(
      context: context,
      delegate: SearchWithSuggestionDelegate(
        onSearchChanged: await getRecentSearches,
      ),
    );
    searchBook();
  }

  Future<List<String>> getRecentSearches(String query) async {
    final allSearches = sharedPreferences.getStringList(ApplicationKeys.RecentSearches);
    return allSearches.where((search) => search.startsWith(query)).toList();
  }

  Future<void> saveToRecentSearches(String searchWord) async {
    Set<String> allSearches = sharedPreferences.getStringList(ApplicationKeys.RecentSearches)?.toSet() ?? {};
    allSearches = {searchWord, ...allSearches};
    sharedPreferences.setStringList(ApplicationKeys.RecentSearches, allSearches.toList());
  }

}
