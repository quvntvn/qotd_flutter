class Quote {
  final int id;
  final String citation;
  final String auteur;
  final String date_creation;

  Quote({required this.id, required this.citation, required this.auteur, required this.date_creation});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'], // Convert the id to String
      citation: json['citation'],
      auteur: json['auteur'],
      date_creation: json['date_creation'],
    );
  }
}
