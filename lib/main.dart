import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ',
              theme: ThemeData(
          primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );

  }
}

class MyHomePage extends StatefulWidget {
  
  @override
  MyHomePageState createState() {
    return new MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {

  String myText;
  StreamSubscription<DocumentSnapshot> subscription;


  final documentReference=Firestore.instance.document("mydata/dummy");
  final FirebaseAuth _auth=FirebaseAuth.instance;

final GoogleSignIn googleSignIn=new GoogleSignIn();

Future<FirebaseUser> _signIn() async{
    GoogleSignInAccount googleUser= await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
 
  final FirebaseUser user= (await _auth.signInWithCredential(credential)) as FirebaseUser;
  assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    return user;

  }

  void _signOut(){
    googleSignIn.signOut();
    print("User Signed Out");
  }


  void _add(){
      Map<String,String> data= <String,String>{
        "name": "Teekam Singh",
        "desc": "App Developer"
      };
      documentReference.setData(data).whenComplete((){
        print("Document Added");
      }).catchError((e)=>print(e));
  }

  // void _delete(){
  //     documentReference.delete().whenComplete((){
  //       print("Deleted Successfully");
  //       setState((){});

  //     }).catchError((e)=>print(e));
  // }

  void _update(){
      Map<String,String> data= <String,String>{
        "name": "Teekam",
        "desc": "Flutter Developer"
      };
      documentReference.updateData(data).whenComplete((){
        print("Document Updated");
      }).catchError((e)=>print(e));
  }

  // void _fetch(){
  //     documentReference.get().then((datasnapshot){

  //       if(datasnapshot.exists){
  //         setState((){
  //           myText=datasnapshot.data['desc'];
  //         });
  //       }
  //     });
  // }

  @override
  void initState(){

    super.initState();
    subscription= documentReference.snapshots().listen((datasnapshot){
      if(datasnapshot.exists){
          setState((){
            myText=datasnapshot.data['desc'];
          });
        }
        });
      }
    @override
    void dispose(){
      super.dispose();
      subscription.cancel();
    }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Sign In With Google"),
      ),

      body: new Padding(
          padding:const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
              child: new Text("Sign in"),
              color: Colors.blue,
              onPressed: ()=>_signIn(),
            ),
            new Padding(
                padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
              onPressed: _signOut,
              child: new Text("Sign Out"),
              color: Colors.red,
            ),
            new Padding(
                padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
              onPressed: _add,
              child: new Text("Add"),
              color: Colors.orangeAccent,
            ),
            new Padding(
                padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
              onPressed: _update,
              child: new Text("Update"),
              color: Colors.green,
            ),
            new Padding(
                padding: const EdgeInsets.all(10.0),
            ),
            // new RaisedButton(
            //   onPressed: _delete,
            //   child: new Text("Delete"),
            //   color: Colors.purpleAccent,
            // ),
            // new Padding(
            //     padding: const EdgeInsets.all(10.0),
            // ),
            // new RaisedButton(
            //   onPressed: _fetch,
            //   child: new Text("Fetch"),
            //   color: Colors.blueAccent,
            // ),
            new Padding(
                padding: const EdgeInsets.all(10.0),
            ),

            myText==null?new Container():new Text(myText,textAlign: TextAlign.center,
            style:new TextStyle(fontSize:25,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


