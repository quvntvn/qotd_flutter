import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/quote.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citation du jour',
      theme: ThemeData(
        primaryColor: Colors.black,
        textTheme: GoogleFonts.georgiaTextTheme(
          Theme.of(context).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF555555),
          ),
        ),
      ),
      home: MyHomePage(title: 'Citation du jour'),
    );
  }
}

// Le reste du code reste inchangé


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _citation = '';
  String _auteur = '';
  String _date_creation = '';
  int _id = 0;
  int _dailyQuoteId = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyQuote();
  }

  void _setIsLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  String getYear(String? dateString) {
    if (dateString == null || !RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(dateString)) {
      return '';
    }
    DateTime date = DateTime.parse(dateString);
    return date.year.toString();
  }

  void _fetchDailyQuote() async {
    try {
      _setIsLoading(true);
      Quote dailyQuote = await getDailyQuote();
      setState(() {
        _citation = dailyQuote.citation;
        _auteur = dailyQuote.auteur;
        _date_creation = dailyQuote.date_creation;
        _dailyQuoteId = dailyQuote.id;
      });
    } catch (error) {
      print("Erreur lors de la récupération de la citation du jour: $error");
    } finally {
      _setIsLoading(false);
    }
  }

  void _fetchRandomQuote() async {
    try {
      _setIsLoading(true);
      Quote randomQuote = await getRandomQuote();
      setState(() {
        _citation = randomQuote.citation;
        _auteur = randomQuote.auteur;
        _date_creation = randomQuote.date_creation;
        _id = randomQuote.id;
      });
    } catch (error) {
      print("Erreur lors de la récupération de la citation aléatoire: $error");
    } finally {
      _setIsLoading(false);
    }
  }

  bool _isCurrentQuoteDailyQuote() {
    return _id == _dailyQuoteId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //  title: Text(widget.title),
      //),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Citation du jour',
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
            if (!_isLoading) ...[
              Text(
                _citation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 
              20),
              Text(
                _auteur,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 20),
              Text(
                getYear(_date_creation),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _fetchRandomQuote,
              child: Text('Voir une autre citation'),
            ),
            SizedBox(height: 10),
            if (!_isCurrentQuoteDailyQuote()) _buildDailyQuoteButton(),
          ],
        ),
      ),
    );
  }

  Future<Quote> getDailyQuote() async {
    final response = await http.get(Uri.parse('https://qotd-api.herokuapp.com/api/daily_quote'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.isNotEmpty) {
        return Quote.fromJson(jsonResponse);
      } else {
        throw Exception('Empty JSON response for daily quote');
      }
    } else {
      throw Exception('Failed to load daily quote');
    }
  }

  Future<Quote> getRandomQuote() async {
    final response = await http.get(Uri.parse('https://qotd-api.herokuapp.com/api/random_quote'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.isNotEmpty) {
        return Quote.fromJson(jsonResponse);
      } else {
        throw Exception('Empty JSON response for random quote');
      }
    } else {
      throw Exception('Failed to load random quote');
    }
  }

  Widget _buildDailyQuoteButton() {
    return ElevatedButton(
      onPressed: _fetchDailyQuote,
      child: Text('Citation du jour'),
    );
  }
}
