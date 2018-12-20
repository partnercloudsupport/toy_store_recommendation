import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toy_store/ui/login_page.dart';

class MainPage extends StatefulWidget {
  MainPageState createState() => new MainPageState();
  
  }
  
  class MainPageState extends State<MainPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('First Screen'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Logout'),
          onPressed: () {
            signOut();
          },
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) {
      if(firebaseUser==null){
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
        debugPrint(firebaseUser.toString()+'logout');
      }
    });
  }

  Future<Null> signOut() async {
  // Sign out with firebase
  await FirebaseAuth.instance.signOut();
  // Sign out with google
  //await FirebaseAuth.instance._googleSignIn.signOut();
}


}