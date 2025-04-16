import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:schedule_generator/model/history_model.dart';
import 'package:schedule_generator/screen/history/history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box historyBox;

  @override
  void initState() {
    super.initState();
    historyBox = Hive.box('historyBox');
  }

  void deleteHistory(int index) {
    setState(() {
      historyBox.deleteAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Riwayat telah dihapus'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Outfit',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: historyBox.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat outfit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: historyBox.length,
              itemBuilder: (context, index) {
                final rawData = historyBox.getAt(index);

                if (rawData == null || rawData is! Map) {
                  return const SizedBox();
                }

                try {
                  final mapData = Map<String, dynamic>.from(rawData);
                  final history = HistoryModel.fromMap(mapData);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 6),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryDetailScreen(history: history),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      history.activity,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () => deleteHistory(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildOutfitItem('Pria', history.pria),
                              const SizedBox(height: 8),
                              _buildOutfitItem('Wanita', history.wanita),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } catch (e) {
                  debugPrint(
                      'Error processing history item at index $index: $e');
                  return const SizedBox();
                }
              },
            ),
    );
  }

  Widget _buildOutfitItem(String gender, GenderOutfit outfit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outfit $gender:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildOutfitChip(outfit.atasan),
            _buildOutfitChip(outfit.bawahan),
            _buildOutfitChip(outfit.sepatu),
            if (outfit.aksesoris.isNotEmpty) _buildOutfitChip(outfit.aksesoris),
          ],
        ),
      ],
    );
  }

  Widget _buildOutfitChip(String item) {
    return Chip(
      label: Text(
        item,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.grey[100],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
