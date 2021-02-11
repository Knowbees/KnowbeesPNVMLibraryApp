import 'dart:convert';
import 'package:com.knowbees.pnvmlibraryapp/defaults/KohaURLs.dart';
import 'package:http/http.dart' as http;

class FetchBookImageURL {

  Future<String> getBookImageURLs(String isbn) async {
    isbn = isbn.replaceAll(' ', '');
    String bookImageURL = KohaURLs.BookImageURL + isbn;
    try{
      var response = await http.get(bookImageURL);
      bookImageURL = fetchBookImageURL(response.body);
    } catch(E){
      print('\n ImageURLError:- '+E.toString());
      bookImageURL = null;
    }

    print('BookImageURL:-'+bookImageURL.toString());
    return bookImageURL;
  }

  String fetchBookImageURL(var response){
    Map jsonResponse = jsonDecode(response);
    List items = jsonResponse['items'];
    var bookImageURL = items[0]['volumeInfo'];
    bookImageURL = bookImageURL['imageLinks'];
    bookImageURL = bookImageURL['thumbnail'];
    return bookImageURL.toString();
  }
}