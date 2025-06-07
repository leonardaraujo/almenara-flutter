import 'package:shared_preferences/shared_preferences.dart';

class CardService {
  static const _cardsKey = 'saved_cards';
  static final CardService _instance = CardService._internal();
  factory CardService() => _instance;
  CardService._internal();

  Future<List<String>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cardsKey) ?? [];
  }

  Future<void> addCard(String cardNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = prefs.getStringList(_cardsKey) ?? [];
    cards.add(cardNumber);
    await prefs.setStringList(_cardsKey, cards);
  }
}
