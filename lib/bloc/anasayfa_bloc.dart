import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as direction;
import 'package:flutterHarita/model/kategori.dart';
import 'package:flutterHarita/model/mekan.dart';
import 'package:flutterHarita/servisler/dp_api.dart';
import 'package:geolocator/geolocator.dart' as geo;

class AnasayfaBloc {
  direction.GoogleMapsDirections directions = direction.GoogleMapsDirections(
      apiKey: "AIzaSyC2TRVqnMgCx5b2pFm3Cn88io8lsp6NGu4");
  List<Mekan> mekanListesi;
  DbApi _dbApi;
  StreamController<List<Kategori>> _kategoriStreamController =
      StreamController<List<Kategori>>.broadcast();
  Sink<List<Kategori>> get kategorilerSink => _kategoriStreamController.sink;
  Stream<List<Kategori>> get kategorilerStream =>
      _kategoriStreamController.stream;

  StreamController<List<Mekan>> _mekanStreamController =
      StreamController<List<Mekan>>.broadcast();
  Sink<List<Mekan>> get _mekanlarSink => _mekanStreamController.sink;
  Stream<List<Mekan>> get mekanlarStream => _mekanStreamController.stream;

  StreamController<List<LatLng>> _rotaStreamController =
      StreamController<List<LatLng>>.broadcast();
  Sink<List<LatLng>> get _rotalarSink => _rotaStreamController.sink;
  Stream<List<LatLng>> get rotalarStream => _rotaStreamController.stream;

  StreamController<Mekan> _anasayfaCardStreamController =
      StreamController<Mekan>.broadcast();
  Sink<Mekan> get anasayfaCardSink => _anasayfaCardStreamController.sink;
  Stream<Mekan> get anasayfaCardStream => _anasayfaCardStreamController.stream;

  StreamController<int> _anasayfaScrollStreamController =
      StreamController<int>.broadcast();
  Sink<int> get anasayfaScrollSink => _anasayfaScrollStreamController.sink;
  Stream<int> get anasayfaScrollStream =>
      _anasayfaScrollStreamController.stream;

  AnasayfaBloc() {
    _dbApi = DbApi();
    verileriGetir();
  }
  double _originLatitude;
  double _originLongitude;

  Future<geo.Position> konumIste() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    _originLatitude = position.latitude;
    _originLongitude = position.longitude;
    return position;
  }

  void dispose() {
    _kategoriStreamController.close();
    _mekanStreamController.close();
    _rotaStreamController.close();
    _anasayfaCardStreamController.close();
    _anasayfaScrollStreamController.close();
  }

  void verileriGetir() {
    _dbApi.kategorileriGetir().then((value) {
      kategorilerSink.add(value);
    });
    _dbApi.mekanlariGetir("67").then((value) => _mekanlarSink.add(value));
  }

  List<direction.Waypoint> waypointListe = List<direction.Waypoint>();

  void kategorilereGoreMekan(String id) {
    waypointListe.clear();

    _dbApi.mekanlariGetir(id).then((value) {
      _mekanlarSink.add(value);
      mekanListesi = value;
      // List<direction.Waypoint> noktalar = [];
      for (Mekan item in mekanListesi) {
        direction.Waypoint waypoint = direction.Waypoint.fromLocation(
            direction.Location(
                double.parse(item.placeLat), double.parse(item.placeLong)));
        // noktalar.add(waypoint);
        waypointListe.add(waypoint);
      }
      konumIste().then((geo.Position value) {
        directions
            .directionsWithLocation(
              direction.Location(value.latitude, value.longitude),
              direction.Location(
                double.parse(mekanListesi[mekanListesi.length - 1].placeLat),
                double.parse(mekanListesi[mekanListesi.length - 1].placeLong),
              ),
              waypoints: waypointListe,
            )
            .then((value) => _polyLineCiz(value));
      });
    });
  }

  void _polyLineCiz(direction.DirectionsResponse value) {
    List<LatLng> keskinNoktalar = List<LatLng>();

    for (var i = 0; i < waypointListe.length; i++) {
      for (var item in value.routes[0].legs[i].steps) {
        keskinNoktalar.addAll(decodeEncodedPolyline(item.polyline.points));
      }
    }
    _rotalarSink.add(keskinNoktalar);
  }

//decode metodu
  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
