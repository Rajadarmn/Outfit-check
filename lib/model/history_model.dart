class HistoryModel {
  final String activity;
  final GenderOutfit pria;
  final GenderOutfit wanita;

  HistoryModel({
    required this.activity,
    required this.pria,
    required this.wanita,
  });

  Map<String, dynamic> toMap() {
    return {
      'activity': activity, // Konsisten dengan property name
      'rekomendasi_outfit': {
        'pria': pria.toMap(),
        'wanita': wanita.toMap(),
      },
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    try {
      final outfit = map['rekomendasi_outfit'] as Map<String, dynamic>? ?? {};

      return HistoryModel(
        activity: map['activity']?.toString() ?? 'Unknown Activity',
        pria:
            GenderOutfit.fromMap(outfit['pria'] as Map<String, dynamic>? ?? {}),
        wanita: GenderOutfit.fromMap(
            outfit['wanita'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      // Fallback untuk error parsing
      return HistoryModel(
        activity: 'Invalid Activity',
        pria: GenderOutfit.unknown(),
        wanita: GenderOutfit.unknown(),
      );
    }
  }
}

class GenderOutfit {
  final String atasan;
  final String bawahan;
  final String sepatu;
  final String aksesoris;

  GenderOutfit({
    required this.atasan,
    required this.bawahan,
    required this.sepatu,
    required this.aksesoris,
  });

  // Constructor untuk data unknown
  factory GenderOutfit.unknown() {
    return GenderOutfit(
      atasan: 'Unknown atasan',
      bawahan: 'Unknown bawahan',
      sepatu: 'Unknown sepatu',
      aksesoris: 'Unknown aksesoris',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'atasan': atasan,
      'bawahan': bawahan,
      'sepatu': sepatu,
      'aksesoris': aksesoris,
    };
  }

  factory GenderOutfit.fromMap(Map<String, dynamic> map) {
    return GenderOutfit(
      atasan: map['atasan']?.toString() ?? 'Unknown atasan',
      bawahan: map['bawahan']?.toString() ?? 'Unknown bawahan',
      sepatu: map['sepatu']?.toString() ?? 'Unknown sepatu',
      aksesoris: map['aksesoris']?.toString() ?? 'Unknown aksesoris',
    );
  }
}
