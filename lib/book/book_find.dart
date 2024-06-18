import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/book.dart';

class BookService {
  static final String API_SERVER = "https://dapi.kakao.com/v3/search/book";
  static final String REST_API_KEY = "79849cd9fe6e22dc9e0507bc893fd93a";

  Future<List<Book>> getBookList(String query, String target, int page) async {
    List<Book> bookList = List.empty(growable: true);

    String strParameterQuery = "query=$query";
    String strParameterTarget = "target=$target";
    String strParameterSize = "size=2";
    String strParameterPage = "page=$page";
    String strUrl = "$API_SERVER?$strParameterQuery&$strParameterTarget&$strParameterSize&$strParameterPage";
    print(strUrl);
    var response = await http.get(Uri.parse(strUrl),
        headers: {"Authorization": "KakaoAK $REST_API_KEY"}
    );

    var documentsMapList =jsonDecode(response.body)['documents'] as List;
    bookList = documentsMapList.map((json) => Book.fromJson(json)).toList();

    return bookList;
  }
}