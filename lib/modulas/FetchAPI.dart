import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/defaults/ApplicationKeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FetchAPI {

  Future<String> fetchData(String operation, Map extras) async {
    String extra = '' ;
    if(extras != null){
      for(String key in extras.keys){
        extra = extra+'&'+key+'='+extras[key];
      }
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String websiteURL = sharedPreferences.getString(ApplicationKeys.KohaURL);

    String url = websiteURL + operation + '?' + extra ;

    String borrowernumber = sharedPreferences.getString(ApplicationKeys.BorrowerNumber);
    if(borrowernumber != null){
      url = websiteURL + operation + '?borrowernumber=' + borrowernumber + extra ;
    }

    print('URL:- '+url);

    var response;
    try{
      response = await http.get(url);
      response = utf8.decode(response.bodyBytes);
    }catch(E){
      print('Exception:- '+E.toString());
    }
    print('\nWeb Response:-\n'+response.toString());
    print('\n\t--XXX-\n');
    return response;
  }

}
