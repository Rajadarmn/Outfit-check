import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class OutfitAIService {
  static const String apiKey = 'AIzaSyCN3hklxq2Fg11gpHv0cdjz4aIlRRIpQgk'; // Ganti dengan API Key kamu

  static Future<Map<String, dynamic>> generateOutfit(
    List<Map<String, dynamic>> outfitPreferences,
  ) async {
    final prompt = _buildPrompt(outfitPreferences);

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(
      history: [
        Content.multi([
TextPart('Kamu adalah AI Konsultan Fashion profesional.\n'
              'Ketika pengguna memberikan informasi tentang preferensi pakaian, acara, atau cuaca, kamu akan memberikan **dua** saran outfit: satu untuk **pria** dan satu untuk **wanita**.\n\n'
              'Output harus dalam format JSON seperti berikut:\n'
              '```json\n'
              '{\n'
              '  "acara": "🌤️ Jalan santai di taman",\n'
              '  "rekomendasi_outfit": {\n'
              '    "pria": {\n'
              '      "atasan": "👕 Kaos putih polos",\n'
              '      "bawahan": "👖 Celana jeans biru",\n'
              '      "sepatu": "👟 Sneakers putih",\n'
              '      "aksesoris": "🧢 Topi hitam"\n'
              '    },\n'
              '    "wanita": {\n'
              '      "atasan": "👚 Blouse lengan pendek",\n'
              '      "bawahan": "👖 Celana high waist",\n'
              '      "sepatu": "👟 Sepatu kasual",\n'
              '      "aksesoris": "👜 Tas selempang kecil"\n'
              '    }\n'
              '  },\n'
              '  "catatan": "Pastikan pakaian nyaman dipakai dan sesuai dengan kondisi cuaca."\n'
              '}\n'
              '```\n'
              '⚠️ Jangan berikan teks lain di luar JSON!'),
        ]),
      ],
    );

    try {
      final response = await chat.sendMessage(Content.text(prompt));
      final responseText =
          (response.candidates.first.content.parts.first as TextPart).text;

      print("Raw API Response: $responseText");

      if (responseText.isEmpty) {
        return {"error": "Respon kosong dari AI."};
      }

      final jsonMatch = RegExp(
        r'```json\n([\s\S]*?)\n```',
      ).firstMatch(responseText);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(1)!);
      }

      return jsonDecode(responseText);
    } catch (e) {
      return {"error": "Gagal menghasilkan outfit: $e"};
    }
  }

  static String _buildPrompt(List<Map<String, dynamic>> preferences) {
    String prefList = preferences
        .map(
          (pref) =>
              "- Acara: ${pref['acara']}\n  Cuaca: ${pref['cuaca']}\n  Style: ${pref['style']}",
        )
        .join("\n\n");

    return "Berikut adalah preferensi pengguna:\n$prefList\n\n"
        "Berikan saran outfit dalam format JSON sesuai template berikut:\n"
        "```json\n"
        "{\n"
        '  "acara": "🌤️ Jalan santai di taman",\n'
              '  "rekomendasi_outfit": {\n'
              '    "pria": {\n'
              '      "atasan": "👕 Kaos putih polos",\n'
              '      "bawahan": "👖 Celana jeans biru",\n'
              '      "sepatu": "👟 Sneakers putih",\n'
              '      "aksesoris": "🧢 Topi hitam"\n'
              '    },\n'
              '    "wanita": {\n'
              '      "atasan": "👚 Blouse lengan pendek",\n'
              '      "bawahan": "👖 Celana high waist",\n'
              '      "sepatu": "👟 Sepatu kasual",\n'
              '      "aksesoris": "👜 Tas selempang kecil"\n'
              '    }\n'
              '  },\n'
              '  "catatan": "Pastikan pakaian nyaman dipakai dan sesuai dengan kondisi cuaca."\n'
              '}\n'
              '```\n'
              '⚠️ Jangan berikan teks lain di luar JSON!';
  }
}
