import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:com.knowbees.pnvmlibraryapp/app_screens/home_screen.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ConfigValues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';

class ConfigurationScreen extends StatefulWidget {
  @override
  _ConfigurationScreenState createState() => new _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {

  SharedPreferences sharedPreferences;
  String websiteURL, status;
  final URLEt = TextEditingController();
  bool isLoading, isForeground;

  void initState() {
    isLoading = false;
    isForeground = true;
    doConfigure();    /*Auto Config*/
    super.initState();
  }

  @override
  void dispose() {
    isForeground = true;
    super.dispose();
  }

  Future doConfigure() async {
    sharedPreferences = await SharedPreferences.getInstance();

    /*Auto Config*/
      websiteURL = 'http://punenagarvachan.org';

    setState(() {
      status = 'Please wait...';
      isLoading = true;
    });

    /*Manual Config*/
//    websiteURL = URLEt.text;
//    if(websiteURL.isEmpty){
//      setState(() { status = 'Please Enter Website URL'; });
//      return;
//    }
//
//    setState(() {
//      status = 'Please wait...';
//      isLoading = true;
//    });
//
    try{
      String librarySetUpURL = websiteURL + '/' + KohaURLs.ConfigurationURL;
      print('LibUrl:-'+librarySetUpURL);
      var response = await http.get(librarySetUpURL);
      getValues(utf8.decode(response.bodyBytes));
    } catch(E){
      print('Exception:- '+E.toString());
      setState(() {
        status = 'Enter correct URL';
        isLoading = false;
      });
    }
  }

  void getValues(response) async{
    try{
      Map parsedJson = jsonDecode(response);
      print('Web Response:- \n'+parsedJson.toString());

      HashMap keyHM = new HashMap<String,List>();
      keyHM['SystemDetails'] = ['CompanyName', 'ApplicationID', 'ApplicationVersion','KohaVersion','ApplicationLink'];
      keyHM['LibraryDetails'] =['LibraryName','LibraryIcon','WelcomeMessage','FeedbackEmailId','ContactEmailId','ContactNumber','AboutLibrary'];
      keyHM['WebLinks'] = ['WebLink'];
      keyHM['ThemeColor'] = ['ColorPrimary', 'ColorPrimaryDark', 'ColorAccent'];
      keyHM['ComponentColor'] = ['TitleColor', 'SubTitleColor', 'TextColor', 'TableHeadingColor', 'ProgressBarColor','AppBarTextColor'];
      keyHM['Menus'] = ['NewArrivalMenu','SearchItemMenu', 'ItemDetailsMenu', 'PaymentDetailsMenu', 'IssuedItemsMenu', 'ReadingHistoryMenu', 'ReservedItemsMenu', 'LoginMenu', 'LogoutMenu'];
      keyHM['TableTerminologies'] = ['TitleHeading', 'StatusHeading', 'PlaceOnHeading', 'AmountDueHeading', 'ChargesHeading', 'HoldDateHeading', 'IssuedDateHeading', 'DueDateHeading', 'ReserveItemHeading', 'CurrencySymbol'];

      print('\nParsing Configuration Web Response:-');
      HashMap valueHM = new HashMap<String,String>();
      keyHM.forEach((mainKey, values) {
        values.forEach((key) {
          valueHM[key] = parsedJson[mainKey][key];
          print(key + ':' + valueHM[key]);
        });
      });
      print('\n\t--XXX-\n');

      valueHM.forEach((key, value) {
        sharedPreferences.setString(key, value.toString());
      });

      String imageData = await downloadImage(valueHM['LibraryIcon']);
      sharedPreferences.setString(ApplicationKeys.LibraryIcon,imageData);

      List posters = parsedJson['LibraryDetails']['PosterLinks'];
      for(int n = 0; n < posters.length; n++){
        print('Poster Images:- '+posters[n]);
        String imageData = await downloadImage(posters[n]);
        sharedPreferences.setString(ApplicationKeys.Poster+'-'+n.toString(), imageData);
      }
      sharedPreferences.setString(ApplicationKeys.KohaURL,websiteURL);
      sharedPreferences.setBool(ApplicationKeys.IsConfigured, true);

      print('Website URL:- '+websiteURL);

      status = 'Welcome!';isLoading = false;
      setState(() {});

      Timer(Duration(seconds: 1), () {
        if(isForeground) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        }
      });

    } catch (E){
      print('Exception:- '+E.toString());
      status = 'Something went wrong!';
      isLoading = false;
      setState(() {});
    }
  }

  Future<String> downloadImage(String url) async {
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    var imageBytes = await consolidateHttpClientResponseBytes(response);
    String imageData = base64Encode(imageBytes);
    return imageData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ConfigValues.CompanyName,style: TextStyle(color: Color(ConfigValues.AppBarTextColor))),
        backgroundColor: Color(ConfigValues.ColorPrimary),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[

          /*Manual Configuration*/
//          Container(
//            margin: const EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 5),
//            child:Text('Enter Website URL',textAlign: TextAlign.center,
//                style: TextStyle(fontWeight: FontWeight.bold,fontSize: ConfigValues.SecondaryTextSize, color: Color(ConfigValues.ColorPrimaryDark))),
//          ),

          /*Manual Configuration*/
//          Container(
//            margin: const EdgeInsets.all(10.0),
//            child: Card(
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(25.0),
//              ),
//              child: TextField(
//                cursorColor: Color(ConfigValues.ColorPrimary),
//                controller: URLEt,
//                style: TextStyle(color: Color(ConfigValues.SubTitleColor),fontSize: ConfigValues.SecondaryTextSize),
//                decoration: InputDecoration(
//                  border: InputBorder.none,
//                  focusedBorder: OutlineInputBorder(
//                    borderSide: BorderSide(color: Color(ConfigValues.ColorPrimary)),
//                    borderRadius: BorderRadius.circular(25.0),
//                  ),
//                  hintText: 'http://firstray.in',
//                  hintStyle: TextStyle(color: Color(ConfigValues.TextColor), fontSize: ConfigValues.SecondaryTextSize),
//                  labelText: 'Website URL',
//                  labelStyle: TextStyle(color: Color(ConfigValues.ColorAccent), fontSize: ConfigValues.SecondaryTextSize),
//                  prefixIcon: const Icon(Icons.alternate_email, color: Color(ConfigValues.ColorAccent)),
//                ),
//              ),
//            ),
//          ),

          /*Manual Configuration*/
//          Center(
//            child: RaisedButton(
//                textColor: Color(ConfigValues.AppBarTextColor),
//                color: Color(ConfigValues.ColorPrimaryDark),
//                shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(25.0),
//                ),
//                onPressed: (){
//                  FocusScope.of(context).requestFocus(FocusNode());
//                  doConfigure();
//                },
//                child: SizedBox(
//                  width: 80,
//                  height: 40,
//                  child: Center(
//                    child: Text('Connect', style: TextStyle(fontSize: ConfigValues.ButtonsTextSize,),textAlign: TextAlign.center),
//                  ),
//                )
//            ),
//          ),
//
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if(status != null)Center(
                  child: Text(status, style: TextStyle(fontSize: ConfigValues.SecondaryTextSize, color: Color(ConfigValues.ColorPrimary)),textAlign: TextAlign.center),
                ),
                Container(
                  margin: EdgeInsets.all(25),
                  child: isLoading ? Center(
                    child: CircularProgressIndicator(),
                  ):null,
                )
              ],
            ),
          )
        ],
      )
    );
  }

}