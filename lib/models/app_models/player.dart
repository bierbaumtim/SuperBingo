class Player {
  int id;
  String name;
  List<String> cards;

  Player({this.id, this.name, this.cards}) {}

  Future<bool> createGame() async {}

  Future<String> playCard(String card) async {}

  Future<String> getCard() async {}

  Future<String> randomizeCards() async {}
}
