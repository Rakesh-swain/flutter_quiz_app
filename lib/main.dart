import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/quiz.dart';
import "package:http/http.dart" as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Quiz? quiz;
  List<Results>? results;

  Future<void> fetchQuestions() async {
    final url = Uri.parse('https://opentdb.com/api.php?amount=20');
    var res = await http.get(url);
    var decres = jsonDecode(res.body);
    quiz = Quiz.fromJson(decres);
    results = quiz!.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz App"),
      ),
      body: FutureBuilder(
          future: fetchQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text("Press button to start");
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) return Container();
                return questionList();
            }
          }),
    );
  }

  ListView questionList() {
    return ListView.builder(
        itemCount: results!.length,
        itemBuilder: (context, index) => Card(
              color: Colors.white,
              elevation: 0.0,
              child: ExpansionTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      results![index].question!,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilterChip(
                            backgroundColor: Colors.grey[100],
                            label: Text(results![index].category!),
                            onSelected: (b) {},
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          FilterChip(
                            backgroundColor: Colors.grey[100],
                            label: Text(results![index].difficulty!),
                            onSelected: (b) {},
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child:
                      Text(results![index].type!.startsWith("m") ? "M" : "B"),
                ),
                children: [],
              ),
            ));
  }
}
