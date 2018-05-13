import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() => runApp(new MaterialApp(
  title: 'Brinet',
  home: new NetLogin()
));

class Account {
  String number = '';
  String password = '';
  String school = '';
}


class NetLogin extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

class LoginPageState extends State<NetLogin> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  
  Account _account = new Account();

  var _schools = {
    '山东劳动职业技术学院': '668220',
    '青岛大学金家岭校区': '712748',
    '临沂大学本部': '740086',
    '临沂大学沂水校区': '822837',
    '山东旅游职业学院': '566884',
    '山东技师学院': '784864',
    '青岛大学浮山校区': '817982',
    '日照大学城': '1065671',
    '济南大学': '510592',
    '山东蓝翔职业培训学院': '640841',
    '山东财经大学明水校区': '510281',
    '测试学校': '1044729',
  };
  
  String _log = '';

  String _selectschool;
  List<DropdownMenuItem<String>> _dropDownMenuItems;

  List<DropdownMenuItem<String>> buildAndGetDropDownItems(Map schools) {
    List<DropdownMenuItem<String>> items = new List();
    schools.forEach(
      (k, v) => items.add(
        new DropdownMenuItem(
          value: v,
          child: new Text(k),
        )
      )
    );
    return items;
  }
  
  @override
  void initState() {
    _selectschool = '510592';
    this._account.school = '510592';
    _dropDownMenuItems = buildAndGetDropDownItems(_schools);
    super.initState();
  }

  void changedDropDownItem(String selectedSchool) {
    setState(() {
      _selectschool = selectedSchool;
    });
    this._account.school = selectedSchool;
  }
  void updatelog(s) {
    setState(() {
      _log = s;
    });
  }
  void submit() async {
    _formKey.currentState.save();
    updatelog('Connecting...');
    var r = await http.get('http://www.163.com');
    RegExp exp = new RegExp(r'window.location.href="(.*?)"');
    var match = exp.firstMatch(r.body);
    if (match == null) {
      updatelog('Cannot get url');
      // _log = '';
      return;
    }
    var url = match.group(1);
    updatelog(url);
    var u = Uri.parse(url);
    var q = u.queryParameters;
    url = 'http://'+u.host+'/sdjd/protalAction!portalAuth.action';
    var headers = {
        'host': u.host,
        'referer': 'http://'+u.host+'/sdjd/protalAction!index.action?wlanuserip='+q['wlanuserip']+'&basip='+q['basip'],
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36',
        'Cookie': 'JSESSIONID=28DFF62C185671AABE3757B1911A5A8B; lt=1; route=74f51685c56f1c432de12cf91a407795',
    };
    var data = {
        'wlanuserip': q['wlanuserip'],
        'localIp': '',
        'basip': q['basip'],
        'lt': '1',
        'lpsUserName': _account.number,
        'lpsPwd': _account.password,
        'schoolId': _account.school,
        'rmbUser': 'on'
    };

    r = await http.post(url, headers: headers, body: data);
    updatelog(_log + r.body);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Form(
          key: this._formKey,
          child: new ListView(
            children: <Widget>[
              new TextFormField(
                keyboardType: TextInputType.phone,
                decoration : new InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: false,
                  labelText: 'Phone',
                ),
                onSaved: (String value) {
                  this._account.number = value;
                },
              ),
              new TextFormField(
                obscureText: true,
                decoration : new InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: false,
                  // hintText: 'Enter your password',
                  labelText: 'Password',
                ),
                onSaved: (String value) {
                  this._account.password = value;
                },
              ),
              const SizedBox(height: 24.0),
              new DropdownButton(
                value: _selectschool,
                items: _dropDownMenuItems,
                onChanged: changedDropDownItem,
              ),
              const SizedBox(height: 24.0),
              new Text(_log),
            ],
          ),
        )
      ),
      floatingActionButton: new FloatingActionButton(
        // onPressed: submit,
        onPressed: () {
          showDialog(
            context: context,
            child: new AlertDialog(
              content: new Row(
                children: <Widget>[
                  const CircularProgressIndicator(),
                  // const SizedBox(width: 20.0,),
                  // new Expanded(
                  //   child: new Text(_log),
                  // ),
                ],
              ),
          ));
          submit();
          Navigator.pop(context);
        },
        child: new Icon(Icons.navigate_next),
        
      ),
    );
  }
}
