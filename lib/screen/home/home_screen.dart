import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_generator/model/history_model.dart';
import 'package:schedule_generator/network/gemini_service.dart';
import 'package:schedule_generator/screen/history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _inputs = [];
  final TextEditingController _activityController = TextEditingController();
  String? errorMessage;

  String activity = '';
  List<String> topWearPria = [];
  List<String> bottomWearPria = [];
  List<String> shoesPria = [];
  List<String> accessoriesPria = [];

  List<String> topWearWanita = [];
  List<String> bottomWearWanita = [];
  List<String> shoesWanita = [];
  List<String> accessoriesWanita = [];

  Future<void> generateOutfit() async {
    if (_activityController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      errorMessage = null;
      _inputs.clear();
      _inputs.add({
        'acara': _activityController.text,
        'atasan': ['atasan'],
        'bawahan': ['bawahan'],
        'sepatu': ['sepatu'],
        'aksesoris': ['aksesoris'],
      });
      _activityController.clear();
    });

    try {
      final result = await OutfitAIService.generateOutfit(_inputs);

      if (result.containsKey('error')) {
        setState(() {
          _isLoading = false;
          errorMessage = result['error'];
        });
        return;
      }

      setState(() {
        activity = result['acara'] ?? 'Unknown Activity';

        // Untuk pria
        topWearPria = [
          result['rekomendasi_outfit']['pria']['atasan'] ?? 'Unknown atasan'
        ];
        bottomWearPria = [
          result['rekomendasi_outfit']['pria']['bawahan'] ?? 'Unknown bawahan'
        ];
        shoesPria = [
          result['rekomendasi_outfit']['pria']['sepatu'] ?? 'Unknown sepatu'
        ];
        accessoriesPria = [
          result['rekomendasi_outfit']['pria']['aksesoris'] ??
              'Unknown aksesoris'
        ];

        // Untuk wanita
        topWearWanita = [
          result['rekomendasi_outfit']['wanita']['atasan'] ?? 'Unknown atasan'
        ];
        bottomWearWanita = [
          result['rekomendasi_outfit']['wanita']['bawahan'] ?? 'Unknown bawahan'
        ];
        shoesWanita = [
          result['rekomendasi_outfit']['wanita']['sepatu'] ?? 'Unknown sepatu'
        ];
        accessoriesWanita = [
          result['rekomendasi_outfit']['wanita']['aksesoris'] ??
              'Unknown aksesoris'
        ];

        _isLoading = false;
      });

      // Membuka Hive box dengan await
      final box = await Hive.openBox('historyBox');

      // Membuat model HistoryModel dan memastikan data valid
      final history = HistoryModel(
        activity: result['acara'] ?? 'Unknown Activity',
        pria: GenderOutfit(
          atasan: result['rekomendasi_outfit']['pria']['atasan'] ??
              'Unknown atasan',
          bawahan: result['rekomendasi_outfit']['pria']['bawahan'] ??
              'Unknown bawahan',
          sepatu: result['rekomendasi_outfit']['pria']['sepatu'] ??
              'Unknown sepatu',
          aksesoris: result['rekomendasi_outfit']['pria']['aksesoris'] ??
              'Unknown aksesoris',
        ),
        wanita: GenderOutfit(
          atasan: result['rekomendasi_outfit']['wanita']['atasan'] ??
              'Unknown atasan',
          bawahan: result['rekomendasi_outfit']['wanita']['bawahan'] ??
              'Unknown bawahan',
          sepatu: result['rekomendasi_outfit']['wanita']['sepatu'] ??
              'Unknown sepatu',
          aksesoris: result['rekomendasi_outfit']['wanita']['aksesoris'] ??
              'Unknown aksesoris',
        ),
      );

      // Menambahkan history ke box Hive
      await box.add(history.toMap());
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorMessage = 'Gagal menghasilkan rekomendasi outfit\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cek Outfit Kamu Sekarang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 63),
              TextField(
                controller: _activityController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 30, vertical: 23),
                  hintText:
                      'Contoh: pesta malam, cuaca hujan, interview kerja...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.lightGreen.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : generateOutfit,
                label: Text(
                  _isLoading ? 'Generating ...' : 'Generate Outfit',
                  style: const TextStyle(color: Colors.white),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                        ),
                      )
                    : const Icon(Icons.checkroom, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              if (topWearPria.isNotEmpty || bottomWearPria.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        activity,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Outfit untuk pria
                    _buildGlassCard("Outfit Pria", topWearPria, bottomWearPria,
                        shoesPria, accessoriesPria),
                    const SizedBox(height: 16),
                    // Outfit untuk wanita
                    _buildGlassCard("Outfit Wanita", topWearWanita,
                        bottomWearWanita, shoesWanita, accessoriesWanita),
                  ],
                ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        },
        backgroundColor: Colors.lightGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.history, color: Colors.white),
      ),
    );
  }

  Widget _buildGlassCard(String title, List<String> topWear,
      List<String> bottomWear, List<String> shoes, List<String> accessories) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              _buildOutfitItem("Atasan", topWear),
              _buildOutfitItem("Bawahan", bottomWear),
              _buildOutfitItem("Sepatu", shoes),
              _buildOutfitItem("Aksesoris", accessories),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitItem(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title:",
          style: const TextStyle(color: Colors.black),
        ),
        ...items.map((item) =>
            Text("- $item", style: const TextStyle(color: Colors.black))),
        const SizedBox(height: 8),
      ],
    );
  }
}
