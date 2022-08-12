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
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
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
                  if (snapshot.hasError) return errorData(snapshot);
                  return questionList();
              }
            }),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error: ${snapshot.error}"),
          const SizedBox(
            height: 20,
          ),
          RaisedButton(
              child: const Text("Try Again"),
              onPressed: () {
                setState(() {
                  fetchQuestions();
                });
              }),
        ],
      ),
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
                children: results![index].allAnswers!.map((a) {
                  return AnswerWidget(results!, index, a);
                }).toList(),
              ),
            ));
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String a;

  AnswerWidget(this.results, this.index, this.a);
  @override
  State<AnswerWidget> createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        setState(() {
          if (widget.a == widget.results[widget.index].correctAnswer) {
            c = Colors.green;
          } else {
            c = Colors.red;
          }
        });
      },
      title: Text(
        widget.a,
        textAlign: TextAlign.center,
        style: TextStyle(color: c, fontWeight: FontWeight.bold),
      ),
    );
  }
}
