import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChargingStationCard extends StatelessWidget {
  final String stationId;
  final String stationName;
  final String location;
  final double distance;
  final double rating;
  final double powerOutput;
  final String chargerType;
  final bool isBook;
  final int availablePorts;
  final int totalPorts;
  final VoidCallback onBookNow;

  const ChargingStationCard({
    super.key,
    required this.stationId,
    required this.stationName,
    required this.location,
    required this.distance,
    required this.rating,
    required this.powerOutput,
    required this.chargerType,
    required this.isBook,
    required this.availablePorts,
    required this.totalPorts,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.ev_station,
                  size: 40,
                  color: Colors.blue.shade800,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stationName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        location,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.location_on,
                  text: '${distance.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.star,
                  text: rating.toStringAsFixed(1),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.bolt,
                  text: '${powerOutput.toStringAsFixed(1)} kW',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Charger Type: $chargerType',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: totalPorts > 0 ? availablePorts / totalPorts : 0,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                availablePorts > 0 ? Colors.green : Colors.red,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$availablePorts of $totalPorts ports available',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                ElevatedButton(
                  onPressed: isBook ? onBookNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Chip(
      backgroundColor: Colors.blue.shade50,
      avatar: Icon(icon, size: 18, color: Colors.blue.shade800),
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }
}