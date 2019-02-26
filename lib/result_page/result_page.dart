import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toy_store/app_bar.dart';
import 'package:toy_store/input_page/input_page.dart';
import 'package:toy_store/input_page/input_page_styles.dart';
import 'package:toy_store/model/gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class ResultPage extends StatefulWidget {
  final int height;
  final int weight;
  final Gender gender;

  final user;

  const ResultPage({Key key, this.height, this.weight, this.gender, this.user})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  double ratingr;
  int starCount = 5;
  var markers=[];
  DatabaseReference _markerRef;


@override
  void initState() {
    super.initState();

    getMarkers();
    getRecommended();
  }
  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    //_scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }


// def pearson(a,b):
//   a1 = a - a.mean()
//   b1 = b - b.mean()
//   return (np.sum(a1 * b1)) / (np.sqrt(np.sum(a1 ** 2) * np.sum(b1 ** 2)))

  getRecommended() {
    List a = [];
    _markerRef = FirebaseDatabase.instance.reference().child('/users');
    _markerRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values=snapshot.value;
        values.forEach((key,values) {
         //print(value.toString());
         //initMarker(values)
         //valuess=values
         Map<dynamic, dynamic> valuess=values;
           valuess.forEach((key,valuess) {
            //print(valuess["name"]);
            String name = valuess["name"];
            String rating = valuess["rating"];
            String latitude = valuess["latitude"];
            String longitude = valuess["longitude"];
            a.add([name,rating,latitude,longitude]);
            //print(a);
          });
        });
      for (var i = 0; i < (a.length-1)/4; i++) {
      double rating = pearson(a[i],a[i+1]);
      //print(a[i]);
      //print('test');
      //print(a[i][0]);
      initMarker(a[i][0], rating.toString(), a[i][2], a[i][3]);

      }
    });

    
  }

  pearson(List a1, List a2) {
    //print(a1[1].toString());
    //debugPrint("test test");
    double n1 = double.parse(a1[1]);
    double n2 = double.parse(a2[1]);
    debugPrint("test");
    debugPrint(a1.toString());
    debugPrint("test");
    double aa1 = n1-n1/2;
    double aa2 = n2-n2/2;
    double r = n1/2 + n2/2;
    double result = r + (aa1*aa2)/sqrt((aa1*aa1)+(aa2*aa2));
    //debugPrint(result.toString());
    return result;
  }
  
  getMarkers()  {
    _markerRef = FirebaseDatabase.instance.reference().child('/users/'+widget.user.uid);
    _markerRef.once().then((DataSnapshot snapshot) {
      // Map<dynamic, dynamic> values=snapshot.value;
      //   values.forEach((key,values) {
         //print(value.toString());
         //initMarker(values)
         //valuess=values
         Map<dynamic, dynamic> valuess=snapshot.value;
           valuess.forEach((key,valuess) {
            //print(valuess["name"]);
            String name = valuess["name"];
            String rating = valuess["rating"];
            String latitude = valuess["latitude"];
            String longitude = valuess["longitude"];
            initMarker(name,rating,latitude,longitude);
         
          });
        // });
    });
  }

  initMarker(String name, String rating, String latitude,String longitude){
    double lat = double.parse(latitude);
    double long = double.parse(longitude);
    rating = rating;
    mapController.addMarker(
            MarkerOptions(
              position: LatLng(lat, long),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindowText: InfoWindowText(name, rating),
              
            )
          );
  }

  updateStarMarker(double rating, String title, String latitude, String longitude) {

    //print(latitude+longitude+rating.toString()+title+uid);
    FirebaseDatabase.instance.reference().child('/users/'+widget.user.uid+'/'+title).update({
      'name': title,
      'rating': rating.toString(),
      'latitude':latitude,
      'longitude': longitude,
    }).then((data){
      showInSnackBar("done");

    }).catchError((onError){
      showInSnackBar(onError.toString());
      debugPrint("onError");
    });

  }
  Widget getMarkersList() {
    List a = [];
    _markerRef = FirebaseDatabase.instance.reference().child('/users');
    _markerRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values=snapshot.value;
        values.forEach((key,values) {
         //print(value.toString());
         //initMarker(values)
         //valuess=values
         Map<dynamic, dynamic> valuess=values;
           valuess.forEach((key,valuess) {
            //print(valuess["name"]);
            String name = valuess["name"];
            String rating = valuess["rating"];
            String latitude = valuess["latitude"];
            String longitude = valuess["longitude"];
            a.add([name,rating,latitude,longitude]);
            //print(a);
          });
        });
      for (var i = 0; i < (a.length-1)/4; i++) {
      double rating = pearson(a[i],a[i+1]);
      //print(a[i]);
      //print('test');
      //print(a[i][0]);
      return new Text(rating.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        child: BmiAppBar(isInputPage: false),
        preferredSize: Size.fromHeight(appBarHeight(context)),
      ),
      drawer: new Drawer(child: new my_drawer()),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: 520.0,
            child: GoogleMap(onMapCreated: onMapCreated,
              options: GoogleMapOptions(
                cameraPosition: CameraPosition(
                  target: LatLng(16.6703, 74.2604),
                  zoom: 15.0,
                )
              ),
            ))          
        ],
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
          mapController = controller;
          // mapController.addMarker(
          //   MarkerOptions(
          //     position: LatLng(16.6743, 74.2624),
          //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          //     infoWindowText: InfoWindowText("Toy Store 7", "4.0"),
              
          //   )
          // );
          mapController.onMarkerTapped.add((Marker){
            String title= Marker.options.infoWindowText.title;
            String desc= Marker.options.infoWindowText.snippet;
            String latitude= Marker.options.position.latitude.toString();
            String longitude= Marker.options.position.longitude.toString();
            double ratingr = double.parse(desc);
            showModalBottomSheet<void>(context: context, builder: (BuildContext context) {
              return Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 24.0
                        )
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5.0),
                    child: Text(desc),
                  ),
                  new StarRating(
                    size: 25.0,
                    rating: ratingr,
                    color: Colors.orange,
                    borderColor: Colors.grey,
                    starCount: starCount,
                    onRatingChanged: (ratingr) => setState(
                    () {
                      this.ratingr = ratingr;
                      updateStarMarker(this.ratingr,title,latitude,longitude);
                      showInSnackBar("done update rating");
                      Navigator.pop(context);
                      desc = this.ratingr.toString();
                      mapController.removeMarker(Marker);
                      initMarker(title, desc, latitude, longitude);
                    },
                    ),
                  ),
                ],
              );
            });
          });
          mapController.addMarker(
            MarkerOptions(
              position: LatLng(27, -132)
            )
          );
        });
  }
}