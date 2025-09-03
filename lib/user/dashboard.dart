import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';

// === Fungsi ambil last reboot (Linux/Android) ===
// === Fungsi ambil last reboot (Linux/Android) ===
Future<Map<String, dynamic>> getLastReboot() async {
  try {
    final result = await Process.run("uptime", ["-s"]);
    if (result.exitCode == 0) {
      String raw = result.stdout.toString().trim();
      try {
        DateTime rebootTime = DateTime.parse(raw);
        DateTime now = DateTime.now();
        Duration diff = now.difference(rebootTime);

        int days = diff.inDays;
        int hours = diff.inHours % 24;
        int minutes = diff.inMinutes % 60;

        String formatted;
        if (days > 0) {
          formatted = "$days hari $hours jam $minutes menit lalu";
        } else {
          formatted = "$hours jam $minutes menit lalu";
        }

        // return data dalam Map
        return {
          "text": formatted,
          "needRestart": diff.inHours >= 8, // cek lebih dari 8 jam
        };
      } catch (e) {
        return {"text": raw, "needRestart": false};
      }
    } else {
      return {"text": "Gagal ambil uptime", "needRestart": false};
    }
  } catch (e) {
    return {"text": "Error: $e", "needRestart": false};
  }
}

// === Dashboard Page ===
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String lastReboot = "Loading...";
  bool needRestart = false;

  @override
  void initState() {
    super.initState();
    getLastReboot().then((value) {
      setState(() {
        lastReboot = value["text"];
        needRestart = value["needRestart"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 48) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8, // semakin kecil -> card makin kecil/pendek
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _buildInfoCard(
              title: "Last Reboot",
              value: lastReboot,
              icon: Icons.restart_alt,
              color: Colors.blue,
              showWarning: needRestart,
            ),
            _buildInfoCard(
              title: "General",
              value: "Images, Videos",
              icon: Icons.folder,
              color: Colors.green,
            ),
            _buildInfoCard(
              title: "Notification",
              value: "All",
              icon: Icons.notifications,
              color: Colors.orange,
            ),
            _buildChartCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool showWarning = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (showWarning) ...[
              const SizedBox(height: 6),
              const Text(
                "⚠️ Disarankan untuk restart",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  "Revenue",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "Last 7 days",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(1, 2.5),
                        FlSpot(2, 2),
                        FlSpot(3, 3.5),
                        FlSpot(4, 3),
                        FlSpot(5, 4),
                        FlSpot(6, 4.5),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
