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

      final box = await Hive.openBox('historyBox');
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
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Cek Outfit Kamu Sekarang',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20, // Reduced font size for better fit
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
       body: SingleChildScrollView(
         padding: EdgeInsets.only(
           top: appBarHeight + statusBarHeight + 20,
           left: 16,
           right: 16,
           bottom: 20,
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Input Section
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 10,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: Column(
                 children: [
                   TextField(
                     controller: _activityController,
                     decoration: InputDecoration(
                       contentPadding: const EdgeInsets.symmetric(
                           horizontal: 20, vertical: 16),
                       hintText: 'Contoh: pesta malam, cuaca hujan...',
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10),
                         borderSide: BorderSide.none,
                       ),
                       filled: true,
                       fillColor: Colors.grey[100],
                       hintStyle: TextStyle(color: Colors.grey[600]),
                     ),
                   ),
                   const SizedBox(height: 16),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null : generateOutfit,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.lightGreen[700],
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10),
                         ),
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                       child: _isLoading
                           ? const Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 SizedBox(
                                   width: 20,
                                   height: 20,
                                   child: CircularProgressIndicator(
                                     color: Colors.white,
                                     strokeWidth: 2,
                                   ),
                                 ),
                                 SizedBox(width: 8),
                                 Text(
                                   'Generating...',
                                   style: TextStyle(
                                       fontSize: 16, color: Colors.white),
                                 ),
                               ],
                             )
                           : const Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.checkroom, color: Colors.white),
                                 SizedBox(width: 8),
                                 Text(
                                   'Generate Outfit',
                                   style: TextStyle(
                                       fontSize: 16, color: Colors.white),
                                 ),
                               ],
                             ),
                     ),
                   ),
                 ],
               ),
             ),
       
             const SizedBox(height: 24),
       
             // Results Section
             if (topWearPria.isNotEmpty || bottomWearPria.isNotEmpty)
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Center(
                     child: Text(
                       activity,
                       style: const TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                         color: Colors.black87,
                       ),
                       textAlign: TextAlign.center,
                     ),
                   ),
                   const SizedBox(height: 20),
       
                   // Male Outfit Card
                   _buildOutfitCard(
                     context,
                     "Outfit Pria",
                     topWearPria,
                     bottomWearPria,
                     shoesPria,
                     accessoriesPria,
                     Colors.blue[50]!,
                   ),
                   const SizedBox(height: 16),
       
                   // Female Outfit Card
                   _buildOutfitCard(
                     context,
                     "Outfit Wanita",
                     topWearWanita,
                     bottomWearWanita,
                     shoesWanita,
                     accessoriesWanita,
                     Colors.pink[50]!,
                   ),
                 ],
               ),
       
             if (errorMessage != null)
               Padding(
                 padding: const EdgeInsets.only(top: 16.0),
                 child: Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.red[50],
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(
                     errorMessage!,
                     style: TextStyle(
                       color: Colors.red[800],
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
               ),
           ],
         ),
       ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        },
        backgroundColor: Colors.lightGreen[700],
        elevation: 4,
        child: const Icon(Icons.history, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildOutfitCard(
    BuildContext context,
    String title,
    List<String> topWear,
    List<String> bottomWear,
    List<String> shoes,
    List<String> accessories,
    Color cardColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildOutfitItem("Atasan", topWear),
          _buildOutfitItem("Bawahan", bottomWear),
          _buildOutfitItem("Sepatu", shoes),
          _buildOutfitItem("Aksesoris", accessories),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Text(
                  "• $item",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              )),
        ],
      ),
    );
  }
}
