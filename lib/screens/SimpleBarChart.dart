// Archivo: SimpleBarChart.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SimpleBarChart extends StatelessWidget {
  final int totalMedics;
  final int lowStock;
  final int totalUsers;

  const SimpleBarChart({
    super.key,
    required this.totalMedics,
    required this.lowStock,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    final data = [
      _ChartData("Productos", totalMedics),
      _ChartData("Stock Bajo", lowStock),
      _ChartData("Usuarios", totalUsers),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 5),
              child: Text(
                'Distribución de Métricas Clave',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  majorGridLines: const MajorGridLines(width: 0), // Quitar líneas verticales
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.black54),
                ),
                tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                series: <CartesianSeries>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (data, _) => data.label,
                    yValueMapper: (data, _) => data.value,
                    pointColorMapper: (data, index) {
                      switch (index) {
                        case 0:
                          return const Color(0xFF007AFF); // Azul
                        case 1:
                          return const Color(0xFFFF9800); // Naranja
                        case 2:
                          return const Color(0xFF6B7A99); // Gris/Azul
                        default:
                          return Colors.blue;
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String label;
  final int value;

  _ChartData(this.label, this.value);
}