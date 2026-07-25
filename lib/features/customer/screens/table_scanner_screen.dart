import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_spacing.dart';

/// Riverpod provider holding the scanned table number.
final tableNumberProvider = StateProvider<String?>((ref) => null);

/// Mock QR scanner screen.
///
/// Shows a premium scanner UI. On "Scan" tap, simulates finding a table
/// and navigates to the menu. No real camera access needed for the demo.
class TableScannerScreen extends ConsumerStatefulWidget {
  const TableScannerScreen({super.key});

  @override
  ConsumerState<TableScannerScreen> createState() =>
      _TableScannerScreenState();
}

class _TableScannerScreenState extends ConsumerState<TableScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanLineController;
  late AnimationController _torchController;
  bool _isScanning = false;
  bool _torchOn = false;
  String? _torchMessage;

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
    _torchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanLineController.dispose();
    _torchController.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    setState(() {
      _torchOn = !_torchOn;
      _torchMessage = _torchOn ? 'Flashlight On' : 'Flashlight Off';
    });
    if (_torchOn) {
      _torchController.forward();
    } else {
      _torchController.reverse();
    }
    // Clear message after 1.5s
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _torchMessage = null);
    });
  }

  void _turnOffTorch() {
    if (_torchOn) {
      setState(() {
        _torchOn = false;
        _torchMessage = null;
      });
      _torchController.reverse();
    }
  }

  void _simulateScan() {
    _turnOffTorch();
    setState(() => _isScanning = true);
    // Simulate scan delay
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ref.read(tableNumberProvider.notifier).state = '8';
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(RoutePaths.menuFor('ching-chong', table: '8'));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scanAreaSize = size.width * 0.65;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera background (dark gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A1614),
                  const Color(0xFF0D0B0A),
                ],
              ),
            ),
          ),

          // Grid pattern to simulate camera viewfinder
          CustomPaint(
            size: size,
            painter: _GridPainter(),
          ),

          // Dark overlay with scan area cutout
          CustomPaint(
            size: size,
            painter: _ScannerOverlayPainter(scanAreaSize: scanAreaSize),
          ),

          // Scan frame with animated corners
          Center(
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final scale =
                      _isScanning ? 1.0 : (0.97 + 0.03 * _pulseController.value);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isScanning
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
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          const Color(0xFF2E7D32),
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
                          if (_isScanning)
                            Center(
                              child: AnimatedOpacity(
                                opacity: _isScanning ? 1.0 : 0.0,
                                duration:
                                    const Duration(milliseconds: 300),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32)
                                        .withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
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
                    _turnOffTorch();
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
                // Torch toggle button with animation
                GestureDetector(
                  onTap: _isScanning ? null : _toggleTorch,
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
                        color: _torchOn ? const Color(0xFF1A1614) : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Torch status message
          if (_torchMessage != null)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _torchMessage != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: AppRadius.brPill,
                    ),
                    child: Text(
                      _torchMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Torch glow effect on camera view
          if (_torchOn)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      const Color(0xFFFFC72C).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Bottom area
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 40,
            left: 32,
            right: 32,
            child: Column(
              children: [
                Text(
                  _isScanning
                      ? 'Table found! Opening menu...'
                      : 'Scan the QR code placed on your table',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                if (!_isScanning)
                  GestureDetector(
                    onTap: _simulateScan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC72C),
                        borderRadius: AppRadius.brMd,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFC72C)
                                .withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Color(0xFF1A1614),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'TAP TO SIMULATE SCAN',
                            style: TextStyle(
                              color: Color(0xFF1A1614),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Demo: Scans as Table 8',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
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

    Widget corner(Alignment align, double? left, double? top, double? right,
        double? bottom) {
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
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.65);

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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
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
