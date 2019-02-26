import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Rlistview extends StatefulWidget {
  @override
  Rlistviewstate createState() {
    return new Rlistviewstate();
  }

}
class Rlistviewstate extends State<Rlistview>{

  DatabaseReference _markerRef;
  List data = [];

  @override
  void initState() {
        // TODO: implement initState
        super.initState();
        this.getMarkersList();
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended List'),
      ),
      body: new ListView.builder(
        itemCount: data == null? 0:data.length,
        itemBuilder: (BuildContext context,int index) {
          return new ListTile(
            title: new Text(data[index]),
          ,
          );
        },        
      )
    );
  }

  pearson(List a1, List a2) {
    //print(a1[1].toString());
    //debugPrint("test test");
    double n1 = double.parse(a1[1]);
    double n2 = double.parse(a2[1]);
    //debugPrint("test");
    //debugPrint(a1.toString());
    //debugPrint("test");
    double aa1 = n1-n1/2;
    double aa2 = n2-n2/2;
    double r = n1/2 + n2/2;
    double result = r + (aa1*aa2)/sqrt((aa1*aa1)+(aa2*aa2));
    //debugPrint(result.toString());
    return result;
  }

    getMarkersList() {
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
      print(a[i]);
      print('test');
      print(a[i][0]);
      //return new Text(rating.toString());
      this.setState((){
        data.add('Name: '+a[i][0]+' rating: '+rating.toString());
      });
      }
    });
  }

}