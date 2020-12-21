import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'bloc/anasayfa_bloc.dart';

class Harita extends StatefulWidget {
  @override
  _HaritaState createState() => _HaritaState();
}

class _HaritaState extends State<Harita> {
  double baslaLat, baslaLong;
  final _scrollController = ScrollController();
  GoogleMapController _controller;
  AnasayfaBloc _anasayfaBloc;
  List<Marker> markerlar = [];
  double _scrollPos;

  var _mySelection;

  @override
  initState() {
    super.initState();
    _anasayfaBloc = AnasayfaBloc();
  }

  _markerGuncelle() {
    _scrollPos = _scrollController.position.pixels;
    if (_scrollPos / MediaQuery.of(context).size.width > 5) {
      Marker marker = Marker(
        markerId: markerlar[5].markerId,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        position: markerlar[5].position,
        infoWindow: markerlar[5].infoWindow,
        zIndex: 1.0,
        onTap: () {
          _anasayfaBloc.anasayfaCardSink.add(_anasayfaBloc.mekanListesi[5]);
          atla(5);
        },
      );
      markerlar[5] = marker;
    }
  }

  atla(int index) {
    _scrollController.animateTo(index * MediaQuery.of(context).size.width,
        duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  konumBul() async {
    geo.Position pos = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    baslaLat = pos.latitude;
    baslaLong = pos.longitude;
  }

  List<Polyline> polylines = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: konumBul(),
              builder: (BuildContext contex, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return StreamBuilder(
                    stream: _anasayfaBloc.rotalarStream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        polylines.add(Polyline(
                            polylineId: PolylineId("poly"),
                            width: 6,
                            color: Colors.blue.shade700,
                            geodesic: true,
                            points: snapshot.data));
                        markerlar = List.generate(
                          _anasayfaBloc.mekanListesi.length,
                          (index) => Marker(
                              markerId: MarkerId(index.toString()),
                              infoWindow: InfoWindow(
                                title: index.toString(),
                                snippet:
                                    _anasayfaBloc.mekanListesi[index].lngTitle,
                              ),
                              position: LatLng(
                                double.parse(
                                    _anasayfaBloc.mekanListesi[index].placeLat),
                                double.parse(_anasayfaBloc
                                    .mekanListesi[index].placeLong),
                              ),
                              onTap: () {
                                _anasayfaBloc.anasayfaCardSink
                                    .add(_anasayfaBloc.mekanListesi[index]);
                                atla(index);
                              }),
                        );

                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: LatLng(baslaLat, baslaLong), zoom: 16),
                          polylines: Set<Polyline>.of(polylines),
                          markers: Set<Marker>.of(markerlar),
                          myLocationEnabled: true,
                          onTap: (argument) {
                            _anasayfaBloc.anasayfaCardSink.add(null);
                          },
                        );
                      } else {
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: LatLng(baslaLat, baslaLong), zoom: 16),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                        );
                      }
                    },
                  );
                } else {
                  return Container();
                }
              }),
          StreamBuilder(
              stream: _anasayfaBloc.kategorilerStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Positioned(
                    bottom: 100,
                    child: DropdownButton(
                      items: List.generate(
                        snapshot.data.length,
                        (index) => DropdownMenuItem(
                          child: Text(snapshot.data[index].lngTitle),
                          value: snapshot.data[index].categoryId,
                        ),
                      ),
                      onChanged: (newVal) {
                        setState(() {
                          _mySelection = newVal;
                          _anasayfaBloc.kategorilereGoreMekan(newVal);
                          _anasayfaBloc.anasayfaCardSink.add(null);
                        });
                      },
                      value: _mySelection,
                    ),
                  );
                } else {
                  return Container();
                }
              }),
          StreamBuilder(
              stream: _anasayfaBloc.anasayfaCardStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Positioned(
                    height: MediaQuery.of(context).size.height * 0.25,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                        child: Stack(
                      children: [
                        Positioned(
                            bottom: 0,
                            top: 0,
                            left: 5,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.network(
                                snapshot.data.thumb,
                                fit: BoxFit.fill,
                              ),
                            )),
                        Positioned(
                          right: 0,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data.lngTitle,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(snapshot.data.lngContent)
                            ],
                          ),
                        ),
                      ],
                    )),
                  );
                } else {
                  return Container();
                }
              }),
          StreamBuilder(
            stream: _anasayfaBloc.anasayfaCardStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Positioned(
                    top: 0,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _anasayfaBloc.mekanListesi.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          _scrollController.addListener(_markerGuncelle());
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              child: Image.network(
                                _anasayfaBloc.mekanListesi[index].thumb,
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        }));
              } else {
                return Container();
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        _anasayfaBloc.kategorilereGoreMekan("47");
      }),
    );
  }
}
