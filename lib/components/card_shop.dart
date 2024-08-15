import 'package:flutter/material.dart';
import 'package:google_map_adv/models/coffee_shop_model.dart';

class CardShop extends StatelessWidget {
  const CardShop(this.shop, {super.key});

  final CoffeeShopModel shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange, width: 1.2),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0.0, 3.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop.name ?? '-:-',
            style: const TextStyle(
                color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          const Divider(height: 26.0, thickness: 1.2, color: Colors.orange),
          Text(
            shop.address ?? '-:-',
            style: const TextStyle(color: Colors.brown, fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
