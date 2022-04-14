import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Team {
  final int id;
  final String nazwa;
  final int miejsce;
  final int punkty;
  final int mecze;
  final String herb;
  final String opis;

  Team(this.id, this.nazwa, this.miejsce, this.punkty, this.mecze, this.herb, this.opis);

}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'TABELA LIGOWA BY Jakub Maciasz ®';

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: Colors.lightGreen,
        ),
      ),
      title: appTitle,
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  Future<List<Team>> _getTeams() async {

    var data = await http.get("https://10.0.2.2/flutter/pobierzMecze/");
    var jsonData = json.decode(data.body);
    List<Team> teams = [];

    for(var u in jsonData){

      Team team = Team(u["id"], u["nazwa"], u["miejsce"], u["punkty"], u["mecze"], "https://10.0.2.2/flutter/assets/teams/${u["id"]}.png", u["opis"]);

      teams.add(team);

    }

    return teams;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        child: FutureBuilder(
          future: _getTeams(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            print(snapshot.data);
            if(snapshot.data == null){
              return const Center(
                  child: Text("Ładowanko...")
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                        child: Image.network(
                          snapshot.data[index].herb,
                          fit: BoxFit.fill,
                        ),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(snapshot.data[index].nazwa),
                    subtitle: Text('Miejsce: ${snapshot.data[index].miejsce.toString()}, Punkty: ${snapshot.data[index].punkty.toString()}, Mecze: ${snapshot.data[index].mecze.toString()}'),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => DetailPage(snapshot.data[index]))
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {

  final Team team;

  DetailPage(this.team);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(team.nazwa),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.table_chart),
              ),
              Tab(
                icon: Icon(Icons.shield),
              ),
              Tab(
                icon: Icon(Icons.description),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Miejsce w tabeli',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Punkty',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Mecze',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text(team.miejsce.toString())),
                      DataCell(Text(team.punkty.toString())),
                      DataCell(Text(team.mecze.toString())),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Image(image: NetworkImage(team.herb)),
            ),
            Center(
              child: Text(team.opis),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
