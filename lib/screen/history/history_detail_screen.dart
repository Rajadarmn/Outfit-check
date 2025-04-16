import 'package:flutter/material.dart';
import 'package:schedule_generator/model/history_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  final HistoryModel history;

  const HistoryDetailScreen({super.key, required this.history});

  Icon _getIconForTitle(String title) {
    switch (title) {
      case "Atasan":
        return Icon(Icons.checkroom, color: Colors.black54);
      case "Bawahan":
        return Icon(Icons.shopping_bag, color: Colors.black54);
      case "Sepatu":
        return Icon(Icons.directions_walk, color: Colors.black54);
      case "Aksesoris":
        return Icon(Icons.watch, color: Colors.black54);
      default:
        return Icon(Icons.style, color: Colors.black54);
    }
  }

  Widget buildDetailCard(String title, String content, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getIconForTitle(title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGenderSection(
      String genderTitle, GenderOutfit outfit, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          genderTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        buildDetailCard("Atasan", outfit.atasan, context),
        buildDetailCard("Bawahan", outfit.bawahan, context),
        buildDetailCard("Sepatu", outfit.sepatu, context),
        buildDetailCard("Aksesoris", outfit.aksesoris, context),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          history.activity,
          style: const TextStyle(
            fontSize: 19,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildGenderSection(
                  "Rekomendasi Outfit Pria", history.pria, context),
              buildGenderSection(
                  "Rekomendasi Outfit Wanita", history.wanita, context),
            ],
          ),
        ),
      ),
    );
  }
}
