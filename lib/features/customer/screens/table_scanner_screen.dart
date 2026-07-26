import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';

/// Riverpod provider holding the scanned table number.
final tableNumberProvider = StateProvider<String?>((ref) => null);

/// Real camera-based QR scanner screen.
///
/// Opens the device camera, scans for QR codes containing table info,
/// and navigates to the menu. Handles permissions, torch, and lifecycle.
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
  bool _isProcessing = false;
  bool _torchOn = false;
  String? _errorMessage;
  bool _cameraReady = false;
  late AnimationController _pulseController;
  late AnimationController _scanLineController;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      await _cameraController!.start();
      if (mounted) {
        setState(() {
          _cameraReady = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera unavailable: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _cameraController?.stop();
    _cameraController?.dispose();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final raw = barcode.rawValue!;
    final tableNumber = _extractTableNumber(raw);
    if (tableNumber == null || tableNumber.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isScanning = false;
    });

    // Stop camera
    _cameraController?.stop();
    _torchOn = false;

    // Store table number and navigate
    ref.read(tableNumberProvider.notifier).state = tableNumber;

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        context.go(
          RoutePaths.menuFor('ching-chong', table: tableNumber),
        );
      }
    });
  }

  String? _extractTableNumber(String raw) {
    // Format: https://domain.com/table/8
    // Format: https://domain.com/r/ching-chong/table/8
    // Format: table=8
    // Format: table:8
    // Format: just a number like "8"

    if (raw.contains('table=')) {
      final uri = Uri.tryParse(raw);
      return uri?.queryParameters['table'];
    }

    if (raw.contains('/table/')) {
      final parts = raw.split('/table/');
      if (parts.length > 1) {
        final num = parts.last.split('/').first.split('?').first;
        if (RegExp(r'^\d+$').hasMatch(num)) return num;
      }
    }

    if (raw.contains('table:')) {
      final match = RegExp(r'table[:\s]*(\d+)').firstMatch(raw);
      if (match != null) return match.group(1);
    }

    if (RegExp(r'^\d+$').hasMatch(raw.trim())) {
      return raw.trim();
    }

    return null;
  }

  void _toggleTorch() {
    if (_cameraController == null) return;
    setState(() => _torchOn = !_torchOn);
    _cameraController!.toggleTorch();
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
      _cameraReady = false;
      _isScanning = true;
      _isProcessing = false;
      _torchOn = false;
    });
    _cameraController?.dispose();
    _cameraController = null;
    _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanAreaSize = size.width * 0.65;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_cameraReady && _cameraController != null)
            MobileScanner(
              controller: _cameraController!,
              onDetect: _onDetect,
            ),

          // Loading state
          if (!_cameraReady && _errorMessage == null)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFFC72C),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Starting camera...',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

          // Error state
          if (_errorMessage != null) _ErrorScreen(
            message: _errorMessage!,
            onRetry: _retry,
          ),

          // Dark overlay with cutout
          if (_cameraReady && _errorMessage == null)
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
                  onTap: () {
                    _cameraController?.stop();
                    context.pop();
                  },
                ),
                const Spacer(),
                const Text(
                  'Scan Table QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Torch button — only on mobile, hide on web
                if (!kIsWeb && _cameraReady)
                  GestureDetector(
                    onTap: _toggleTorch,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _torchOn
                            ? const Color(0xFFFFC72C).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _torchOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          key: ValueKey(_torchOn),
                          color: _torchOn
                              ? const Color(0xFF1A1614)
                              : Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Scan frame with animated corners
          if (_cameraReady && _errorMessage == null)
            Center(
              child: SizedBox(
                width: scanAreaSize,
                height: scanAreaSize,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final scale = _isProcessing
                        ? 1.0
                        : (0.97 + 0.03 * _pulseController.value);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isProcessing
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFFFC72C),
                            width: 2.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Stack(
                          children: [
                            // Animated scan line
                            if (_isScanning)
                              AnimatedBuilder(
                                animation: _scanLineController,
                                builder: (context, _) {
                                  return Positioned(
                                    top: _scanLineController.value *
                                        scanAreaSize,
                                    left: 8,
                                    right: 8,
                                    child: Container(
                                      height: 2,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Color(0xFFFFC72C),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            // Corner accents
                            ..._buildCorners(scanAreaSize),
                            // Success checkmark
                            if (_isProcessing)
                              Center(
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Bottom instruction
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 40,
            left: 32,
            right: 32,
            child: Column(
              children: [
                Text(
                  _isProcessing
                      ? 'Table found! Opening menu...'
                      : 'Point your camera at the QR code on your table',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!kIsWeb && _cameraReady) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tap the ⚡ button to toggle flashlight',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners(double size) {
    const len = 24.0;
    const width = 3.0;
    const color = Color(0xFFFFC72C);

    Widget corner(Alignment align, double? left, double? top,
        double? right, double? bottom) {
      return Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: Align(
          alignment: align,
          child: Container(
            width: len,
            height: len,
            decoration: BoxDecoration(
              border: Border(
                top: align.y < 0
                    ? const BorderSide(color: color, width: width)
                    : BorderSide.none,
                bottom: align.y > 0
                    ? const BorderSide(color: color, width: width)
                    : BorderSide.none,
                left: align.x < 0
                    ? const BorderSide(color: color, width: width)
                    : BorderSide.none,
                right: align.x > 0
                    ? const BorderSide(color: color, width: width)
                    : BorderSide.none,
              ),
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft, 0, 0, null, null),
      corner(Alignment.topRight, null, 0, 0, null),
      corner(Alignment.bottomLeft, 0, null, null, 0),
      corner(Alignment.bottomRight, null, null, 0, 0),
    ];
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.scanAreaSize});

  final double scanAreaSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.6);

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize + 16,
      height: scanAreaSize + 16,
    );

    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(
          RRect.fromRectAndRadius(scanRect, Radius.circular(AppRadius.lg)));
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) =>
      old.scanAreaSize != scanAreaSize;
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

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                size: 36,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera Unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC72C),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    color: Color(0xFF1A1614),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
