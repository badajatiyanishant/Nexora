import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';

/// Riverpod provider holding the scanned table number.
final tableNumberProvider = StateProvider<String?>((ref) => null);

/// QR-based table scanner screen.
///
/// Opens the device camera and scans for a QR code containing the restaurant
/// and table info (e.g. `/r/ching-chong/menu?table=8`). After a successful
/// scan, navigates to the menu with the table stored in state.
class TableScannerScreen extends ConsumerStatefulWidget {
  const TableScannerScreen({super.key});

  @override
  ConsumerState<TableScannerScreen> createState() =>
      _TableScannerScreenState();
}

class _TableScannerScreenState extends ConsumerState<TableScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _cameraController;
  bool _isScanning = true;
  bool _showManualEntry = false;
  final _tableInputController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tableInputController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;

    // Parse table number from various QR formats:
    // /r/ching-chong/menu?table=8
    // /r/ching-chong/table/8
    // table=8
    String? tableNumber;

    if (raw.contains('table=')) {
      final uri = Uri.tryParse(raw);
      tableNumber = uri?.queryParameters['table'];
    } else if (raw.contains('/table/')) {
      tableNumber = raw.split('/table/').last.split('/').first;
    } else if (RegExp(r'^\d+$').hasMatch(raw)) {
      tableNumber = raw;
    }

    if (tableNumber != null && tableNumber.isNotEmpty) {
      setState(() => _isScanning = false);
      ref.read(tableNumberProvider.notifier).state = tableNumber;

      // Success animation then navigate
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          context.go(
            RoutePaths.menuFor('ching-chong', table: tableNumber),
          );
        }
      });
    }
  }

  void _manualEntry() {
    final table = _tableInputController.text.trim();
    if (table.isNotEmpty && RegExp(r'^\d+$').hasMatch(table)) {
      ref.read(tableNumberProvider.notifier).state = table;
      context.go(RoutePaths.menuFor('ching-chong', table: table));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanAreaSize = size.width * 0.65;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          if (!_showManualEntry)
            MobileScanner(
              controller: _cameraController,
              onDetect: _onDetect,
            ),

          // Dark overlay with cutout
          if (!_showManualEntry)
            CustomPaint(
              size: size,
              painter: _ScannerOverlayPainter(scanAreaSize: scanAreaSize),
            ),

          // Top bar
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.pop(),
                ),
                const Spacer(),
                Text(
                  'Scan Table QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (!_showManualEntry)
                  _CircleButton(
                    icon: Icons.flash_on_rounded,
                    onTap: () => _cameraController?.toggleTorch(),
                  ),
              ],
            ),
          ),

          // Scan frame indicator
          if (!_showManualEntry)
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final scale = 0.95 + 0.05 * _pulseController.value;
                  return Transform.scale(
                    scale: _isScanning ? scale : 1.0,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isScanning
                              ? const Color(0xFFFFC72C)
                              : const Color(0xFF2E7D32),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: _isScanning
                          ? null
                          : const Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 64,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

          // Bottom instructions
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 40,
            left: 32,
            right: 32,
            child: Column(
              children: [
                Text(
                  _isScanning
                      ? 'Point your camera at the QR code on your table'
                      : 'Table found! Opening menu...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _showManualEntry = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brPill,
                    ),
                    child: const Text(
                      'Enter table number manually',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Manual entry overlay
          if (_showManualEntry)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.table_restaurant_rounded,
                        size: 48,
                        color: const Color(0xFFFFC72C),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter your table number',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Found on the table stand or wall',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _tableInputController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '#',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 32,
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.1),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.brMd,
                              borderSide: BorderSide(
                                color: const Color(0xFFFFC72C),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.brMd,
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.brMd,
                              borderSide: const BorderSide(
                                color: Color(0xFFFFC72C),
                                width: 2,
                              ),
                            ),
                          ),
                          autofocus: true,
                          onSubmitted: (_) => _manualEntry(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showManualEntry = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: AppRadius.brMd,
                              ),
                              child: const Text(
                                'Back to Scanner',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _manualEntry,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC72C),
                                borderRadius: AppRadius.brMd,
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  color: Color(0xFF1A1614),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Paints a dark overlay with a transparent cutout for the scan area.
class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.scanAreaSize});

  final double scanAreaSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw full-screen overlay
    canvas.drawRect(Offset.zero & size, paint);

    // Cut out the scan area
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, Radius.circular(AppRadius.lg)),
      clearPaint,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanAreaSize != scanAreaSize;
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
