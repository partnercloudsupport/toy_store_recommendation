import 'package:firebase_auth/firebase_auth.dart';
import 'package:toy_store/app_bar.dart';
import 'package:toy_store/fade_route.dart';
import 'package:toy_store/input_page/Rlistview.dart';
import 'package:toy_store/input_page/gender/gender_card.dart';
import 'package:toy_store/input_page/height/height_card.dart';
import 'package:toy_store/input_page/input_page_styles.dart';
import 'package:toy_store/input_page/pacman_slider.dart';
import 'package:toy_store/input_page/transition_dot.dart';
import 'package:toy_store/input_page/weight/weight_card.dart';
import 'package:toy_store/model/gender.dart';
import 'package:toy_store/result_page/result_page.dart';
import 'package:toy_store/ui/login_page.dart';
import 'package:toy_store/widget_utils.dart';
import 'package:flutter/material.dart';

class InputPage extends StatefulWidget {
  @override
  InputPageState createState() {
    return new InputPageState();
  }
}


class my_drawer extends StatelessWidget {

  Future<Null> signOut() async {
  // Sign out with firebase
  await FirebaseAuth.instance.signOut();
  // Sign out with google
  //await FirebaseAuth.instance._googleSignIn.signOut();
  }
  
   @override
   Widget build(BuildContext context) {
     return new ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountEmail: new FutureBuilder<FirebaseUser>(
              future: FirebaseAuth.instance.currentUser(),
              builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //debugPrint(snapshot.data.displayName);
                  if(snapshot.data.email==null){
                    return new Text(snapshot.data.phoneNumber);

                  } else {
                    return new Text(snapshot.data.email);

                  }
                  
                }
                else {
                  return new Text('Loading...');
                }
              },
            ), 
            accountName: new FutureBuilder<FirebaseUser>(
              future: FirebaseAuth.instance.currentUser(),
              builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if(snapshot.data.displayName==null){
                    return new Text("");

                  } else {
                    return new Text(snapshot.data.displayName);

                  }
                  //return new Text(snapshot.data.displayName);
                }
                else {
                  return new Text('Loading...');
                }
              },
            ),
          ),
           new ListTile(
            title: new Text("Logout"),
            trailing: new Icon(Icons.exit_to_app),
            onTap: (){signOut();},
          ),
          new ListTile(
            title: new Text("Recommended list"),
            
            onTap: (){Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new Rlistview()));},
          )

        ],
      );
   }
 }

class InputPageState extends State<InputPage> with TickerProviderStateMixin {
  AnimationController _submitAnimationController;
  Gender gender = Gender.other;
  int height = 180;
  int weight = 70;
  var user;
  @override
  void initState() {
    super.initState();
    _submitAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _submitAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToResultPage().then((_) => _submitAnimationController.reset());
      }
    });

    FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) {
      user = firebaseUser;
      if(firebaseUser==null){
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
        debugPrint(firebaseUser.toString()+'logout');
      }
    });
  }

  @override
  void dispose() {
    _submitAnimationController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Scaffold(
          
          appBar: PreferredSize(
            child: BmiAppBar(),
            preferredSize: Size.fromHeight(appBarHeight(context)),
          ),
          drawer: new Drawer(child: new my_drawer()),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InputSummaryCard(
                gender: gender,
                weight: weight,
                height: height,
              ),
              Expanded(child: _buildCards(context)),
              _buildBottom(context),
            ],
          ),
        ),
        TransitionDot(animation: _submitAnimationController),
      ],
    );
  }

  Widget _buildCards(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(
                child: GenderCard(
                  gender: gender,
                  onChanged: (val) => setState(() => gender = val),
                ),
              ),
              Expanded(
                child: WeightCard(
                  weight: weight,
                  onChanged: (val) => setState(() => weight = val),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: HeightCard(
            height: height,
            onChanged: (val) => setState(() => height = val),
          ),
        )
      ],
    );
  }

  Widget _buildBottom(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: screenAwareSize(16.0, context),
        right: screenAwareSize(16.0, context),
        bottom: screenAwareSize(22.0, context),
        top: screenAwareSize(14.0, context),
      ),
      child: PacmanSlider(
        submitAnimationController: _submitAnimationController,
        onSubmit: onPacmanSubmit,
      ),
    );
  }

  void onPacmanSubmit() {
    _submitAnimationController.forward();
  }

  _goToResultPage() async {
    return Navigator.of(context).push(FadeRoute(
      builder: (context) => ResultPage(
            weight: weight,
            height: height,
            gender: gender,
            user: user,
          ),
    ));
  }
}

class InputSummaryCard extends StatelessWidget {
  final Gender gender;
  final int height;
  final int weight;

  const InputSummaryCard({Key key, this.gender, this.height, this.weight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(screenAwareSize(16.0, context)),
      child: SizedBox(
        height: screenAwareSize(32.0, context),
        child: Row(
          children: <Widget>[
            Expanded(child: _genderText()),
            _divider(),
            Expanded(child: _text("${weight}")),
            _divider(),
            Expanded(child: _text("${height}")),
          ],
        ),
      ),
    );
  }

  Widget _genderText() {
    String genderText = gender == Gender.other
        ? '-'
        : (gender == Gender.boy ? 'Boy' : 'Girl');
    return _text(genderText);
  }

  Widget _text(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color.fromRGBO(143, 144, 156, 1.0),
        fontSize: 15.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _divider() {
    return Container(
      width: 1.0,
      color: Color.fromRGBO(151, 151, 151, 0.1),
    );
  }
}
