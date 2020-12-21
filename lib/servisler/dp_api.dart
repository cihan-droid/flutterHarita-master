import '../model/kategori.dart';
import '../model/mekan.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DbApi {
  String url = "http://yeni.bursa.com.tr/json.php?part=places";
  Future<List<Mekan>> mekanlariGetir(String id) async {
    String sorgu = url + "&cat=$id";
    http.Response response = await http.get(sorgu);
    List responseJson = json.decode(response.body);
    return responseJson.map((m) => new Mekan.fromJson(m)).toList();
  }

  Future<List<Kategori>> kategorileriGetir() async {
    http.Response response = await http.get(url);
    List responseJson = json.decode(response.body);
    return responseJson.map((m) => new Kategori.fromJson(m)).toList();
  }
}
