import 'package:flutter/material.dart';
import 'package:myapp/MainFrameAuth.dart';
import 'package:myapp/src/model/User.dart';

class EmailRegistry extends StatefulWidget {
  @override
  _EmailRegistryState createState() => new _EmailRegistryState();
}

class _EmailRegistryState extends State<EmailRegistry> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String pwd = "";
  User _user;

  @override
  void initState() {
    super.initState();
    _user = new User(null, null, null, null, null, null, null, null);
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    form.save();
    registerEmail(_user.email, pwd).then((usr) => Navigator.of(context).pushNamed("/profilesetup-1"));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text("Main Frame Dance Studio")),
        body: new Form(
            key: _formKey,
            child: new Container(
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                        icon: const Icon(Icons.email),
                        hintText: 'Enter Email...',
                        labelText: 'Email'
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (String val) => _user.email = val
                  ),
                  new TextFormField(
                      decoration: const InputDecoration(
                          icon: const Icon(Icons.lock),
                          hintText: 'Enter Password...',
                          labelText: 'Password'
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      onSaved: (String val) => pwd = val
                  ),
                  new Container(
                    padding: const EdgeInsets.all(20.0),
                    alignment: Alignment.bottomCenter,
                    child: new RaisedButton(
                      child: const Text('NEXT'),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }
}