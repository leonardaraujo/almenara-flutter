import 'package:flutter/material.dart';
import '../../services/cartService.dart';
import '../../services/cardService.dart';
import '../../services/PurchaseService.dart';

enum PaymentMethod { yape, plin, savedCard, newCard }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod? _method;
  List<String> _cards = [];
  String? _selectedCard;

  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await CardService().getCards();
    setState(() => _cards = cards);
  }

  String _maskCard(String card) {
    if (card.length <= 4) return card;
    return '**** **** **** ${card.substring(card.length - 4)}';
  }

  void _completePurchase() async {
    if (_method == PaymentMethod.savedCard && _selectedCard == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona una tarjeta')));
      return;
    }
    if (_method == PaymentMethod.newCard) {
      final number = _cardController.text.trim();
      final expiry = _expiryController.text.trim();
      final cvv = _cvvController.text.trim();
      final valid = RegExp(r'^[0-9]{16}$').hasMatch(number) &&
          RegExp(r'^[0-9]{2}/[0-9]{2}$').hasMatch(expiry) &&
          RegExp(r'^[0-9]{3}$').hasMatch(cvv);
      if (!valid) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Datos inválidos')));
        return;
      }
      await CardService().addCard(number);
    }

    final items = CartService().items.values.toList();
    await PurchaseService().createPurchase('anonimo', items);
    CartService().clearCart();

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Compra realizada con éxito')));
    }
  }

  void _confirmPurchase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar compra'),
        content: const Text('¿Deseas finalizar tu compra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completePurchase();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Método de Pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<PaymentMethod>(
              title: const Text('Yape'),
              value: PaymentMethod.yape,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v),
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('Plin'),
              value: PaymentMethod.plin,
              groupValue: _method,
              onChanged: (v) => setState(() => _method = v),
            ),
            const SizedBox(height: 16),
            if (_cards.isNotEmpty) ...[
              const Text(
                'Tarjetas guardadas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._cards.map(
                (c) => ListTile(
                  title: Text(_maskCard(c)),
                  leading: Radio<String>(
                    value: c,
                    groupValue: _selectedCard,
                    onChanged: (v) {
                      setState(() {
                        _selectedCard = v;
                        _method = PaymentMethod.savedCard;
                      });
                    },
                  ),
                ),
              ),
            ],
            const Divider(),
            ListTile(
              title: const Text('Registrar nueva tarjeta'),
              leading: Radio<PaymentMethod>(
                value: PaymentMethod.newCard,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v),
              ),
            ),
            if (_method == PaymentMethod.newCard) ...[
              TextField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número de tarjeta'),
              ),
              TextField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'MM/AA'),
              ),
              TextField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CVV'),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPurchase,
                child: const Text('Finalizar compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

