import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import "dart:async";
import "dart:convert";

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=be7f0ca0";

void main() async {
  print(await getData());

  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          highlightColor: Colors.deepPurple,
          primaryColor: Colors.amber[300],
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple))))));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: Text("Conversor de Moedas",
            style: TextStyle(
                color: Colors.amber[300], fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando Dados...",
                    style: TextStyle(color: Colors.deepPurple, fontSize: 25.0),
                    textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao Carregar Dados...",
                      style:
                          TextStyle(color: Colors.deepPurple, fontSize: 25.0),
                      textAlign: TextAlign.center),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.deepPurple),
                        buildTextFirld(
                            "Real", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextFirld("Dolar", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextFirld("Euro", "\€", euroController, _euroChanged)
                      ],
                    ));
              }
          }
        },
      ),
    );
  }
}

Widget buildTextFirld(String label, String prefix,
    TextEditingController moedaController, Function moedaChanged) {
  return TextField(
    controller: moedaController,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple, fontSize: 25.0),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Colors.deepPurple, fontSize: 25.0)),
    style: TextStyle(color: Colors.deepPurple, fontSize: 25.0),
    onChanged: moedaChanged,
    keyboardType: TextInputType.number,
  );
}
