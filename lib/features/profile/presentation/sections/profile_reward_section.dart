import 'package:flutter/material.dart';

class ProfileRewardSection extends StatefulWidget {
  const ProfileRewardSection({super.key});

  @override
  State<ProfileRewardSection> createState() => _ProfileRewardSectionState();
}

class _ProfileRewardSectionState extends State<ProfileRewardSection> {
  late final List<Map<String, dynamic>> rewards;

  @override
  void initState() {
    super.initState();
    // Data Dummy (Sesuai kode lama)
    rewards = [
      {"icon": Icons.local_drink, "name": "Tumbler", "code": "TMBL-8273"},
      {"icon": Icons.shopping_bag, "name": "Tote Bag", "code": "TOTE-2931"},
      {"icon": Icons.key, "name": "Gantungan Kunci", "code": "KEYC-9812"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          "Riwayat Penukaran",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Agar tombol back berwarna putih
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final r = rewards[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    r["icon"] as IconData,
                    color: const Color(0xFF1565C0),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Text Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r["name"] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kode: ${r["code"]}",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Check Icon
                const Icon(Icons.check_circle, color: Colors.green, size: 26),
              ],
            ),
          );
        },
      ),
    );
  }
}