import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_adv/components/card_shop.dart';
import 'package:google_map_adv/components/coffee_shop_item.dart';
import 'package:google_map_adv/components/search_box.dart';
import 'package:google_map_adv/gen/assets.gen.dart';
import 'package:google_map_adv/models/coffee_shop_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  // controller dieu khien

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  // doi tuong geolocator de lay vi tri hien tai

  TextEditingController searchController = TextEditingController();
  List<CoffeeShopModel> searchCoffeeShops = [];
  CoffeeShopModel selectedShop = CoffeeShopModel();
  bool showCardShop = false;

  Position? currentPosition;
  bool isCurrentPosition = false;

  Set<Circle> circles = {};
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addMarker();
    _addPolyLines(); // online polyline encoder
  }

  void _addMarker() {
    markers.addAll(
      coffeeShops.map(
        (e) => Marker(
          onTap: () {
            setState(() {
              selectedShop.name = e.name;
              selectedShop.address = e.address;
              showCardShop = true;
            });
          },
          zIndex: coffeeShops.indexOf(e).toDouble(),
          markerId: MarkerId(e.id ?? ''),
          position: LatLng(e.latitude ?? 0.0, e.longitude ?? 0.0),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      ),
    );
  }

  void _createCicles(Position? currentPosition) {
    setState(() {
      circles = {
        Circle(
          strokeColor: Colors.pink.withOpacity(0.12), // vien ben ngoai
          strokeWidth: 2,
          circleId: const CircleId('a'),
          center: LatLng(
            currentPosition?.latitude ?? 0.0,
            currentPosition?.longitude ?? 0.0,
          ),
          radius: 1600,
          fillColor: Colors.pink.withOpacity(0.10),
        ),
        Circle(
          strokeColor: Colors.pink.withOpacity(0.12), // vien ben ngoai
          strokeWidth: 2,
          circleId: const CircleId('b'),
          center: LatLng(
            currentPosition?.latitude ?? 0.0,
            currentPosition?.longitude ?? 0.0,
          ),
          radius: 1000,
          fillColor: Colors.pink.withOpacity(0.08),
        ),
      };
    });
  }

  void _addPolyLines() {
    // online polyline encoder
    polyLines.add(
      Polyline(
        polylineId: const PolylineId("route1"),
        color: Colors.transparent,
        // color: Colors.red,
        // patterns: [PatternItem.dash(20.0), PatternItem.gap(10.0)],
        patterns: [PatternItem.dot, PatternItem.gap(10.0)],
        width: 4,
        points: PolylinePoints()
            .decodePolyline("skbaBa{dsSeD{w@dUql@hYpVkJhh@bBtf@{ZwJ")
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
      ),
    );
    
  }

  void _search(String searchText) {
    searchText = searchText.toLowerCase();
    searchCoffeeShops = coffeeShops
        .where((e) => (e.name ?? '').toLowerCase().contains(searchText))
        .toList();
    showCardShop = false;
    setState(() {});
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // su dung _geolocatorPlatform khai bao o tren de xin quyen
    // Test if location services are enabled
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void _getCurrentLocation() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return;

    try {
      currentPosition = await _geolocatorPlatform.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _createCicles(currentPosition); // setState o day

      // khi da lay duoc currentPosition thi remove Marker
      // cua currentPosition truoc do va dua mot Marker moi vao currentPosition vua lay duoc
      markers.removeWhere((e) => e.mapsId == const MarkerId('currentId'));
      markers.add(Marker(
        zIndex: 9999,
        markerId: const MarkerId('currentId'),
        position: LatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        // infoWindow: const InfoWindow(title: "Hello World"),
        onTap: () {
          if (circles.length >= 2) {
            circles.removeWhere((e) => e.mapsId == const CircleId('a'));
            setState(() {});
          } else {
            // _createCicles(currentPosition);
            final a = Circle(
              strokeColor: Colors.pink.withOpacity(0.12), // vien ben ngoai
              strokeWidth: 2,
              circleId: const CircleId('a'),
              center: LatLng(
                currentPosition?.latitude ?? 0.0,
                currentPosition?.longitude ?? 0.0,
              ),
              radius: 1600,
              fillColor: Colors.pink.withOpacity(0.10),
            );
            circles.add(a);
            setState(() {});
          }

          for (var element in circles) {
            print('object ${element.circleId}');
          }
        },
      ));

      onCamera();
    } on TimeoutException catch (e) {
      print('onError $e');
    }
  }

  // camera move
  void onCamera() async {
    // tao doi tuong googleMapController, khoi tao camera va dua ve vi tri hien tai
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(
            currentPosition?.latitude ?? 0.0,
            currentPosition?.longitude ?? 0.0,
          ),
          zoom: 13.2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        showCardShop = false;
        setState(() {});
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1.2),
              ),
              child: GoogleMap(
                minMaxZoomPreference: const MinMaxZoomPreference(8.0, 16.0),
                scrollGesturesEnabled: true, // di chuyen
                rotateGesturesEnabled: false, // xoay
                polylines: polyLines,
                circles: circles,
                markers: markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentPosition?.latitude ?? 0.0,
                      currentPosition?.longitude ?? 0.0),
                  zoom: 13.2, // max = 16, 18
                ),
                onCameraMove: (position) {
                  // so sanh position cua google map tra ve
                  // va vi tri hien tai (position cua geolocator tra ve)
                  if ((position.target.latitude.toStringAsFixed(3) ==
                          currentPosition!.latitude.toStringAsFixed(3)) &&
                      (position.target.longitude.toStringAsFixed(3) ==
                          currentPosition!.longitude.toStringAsFixed(3))) {
                    isCurrentPosition = true;
                  } else {
                    isCurrentPosition = false;
                  }
                  setState(() {});
                },
                onTap: (position) {
                  markers = {
                    ...markers,
                    Marker(
                      markerId: MarkerId(position.latitude.toString()),
                      position: position,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueYellow,
                      ),
                      consumeTapEvents: true,
                      // khi remove marker camera ko di chuyen
                      onTap: () {
                        setState(() {
                          markers.removeWhere((e) =>
                              e.mapsId == MarkerId('${position.latitude}'));
                        });
                      },
                    ),
                  };
                  setState(() {});
                },
              ),
            ),
            Positioned(
              left: 8.0,
              top: MediaQuery.of(context).padding.top + 8.0,
              right: 8.0,
              child: Visibility(
                visible: searchCoffeeShops.isNotEmpty,
                child: Stack(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 236.0),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.orange),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 12.0),
                        shrinkWrap: true,
                        itemCount: searchCoffeeShops.length,
                        itemBuilder: (context, index) {
                          final shop = searchCoffeeShops[index];
                          return CoffeeShopItem(
                            shop,
                            onPressed: () async {
                              final GoogleMapController controller =
                                  await _controller.future;
                              await controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      shop.latitude ?? 0.0,
                                      shop.longitude ?? 0.0,
                                    ),
                                    zoom: 13.2,
                                  ),
                                ),
                              );
                              selectedShop.name = shop.name;
                              selectedShop.address = shop.address;
                              showCardShop = true;
                              setState(() {});
                            },
                          );
                        },
                        separatorBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          height: 1.0,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0.0,
                      right: 4.0,
                      child: SizedBox.square(
                        dimension: 36.0,
                        child: IconButton(
                          onPressed: () {
                            searchCoffeeShops.clear();
                            searchController.clear();
                            setState(() {});
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.cancel_outlined,
                              size: 28.0, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16.0,
              bottom: 36.0,
              child: InkWell(
                onTap: () {
                  _getCurrentLocation();
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 1.6),
                  ),
                  child: SvgPicture.asset(
                    isCurrentPosition
                        ? Assets.icons.menuVector
                        : Assets.icons.menuVectorBorder,
                    width: 28.0,
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 76.0,
              right: 16.0,
              bottom: 16.0,
              child: Visibility(
                visible: showCardShop,
                child: CardShop(selectedShop),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SearchBox(
          controller: searchController,
          onChanged: _search,
          hintText: 'Search Coffee Shops',
        ),
      ),
    );
  }
}
