import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/accessibility_utils.dart';
import '../l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAccessibilityEnabled = false;
  final _promptController = TextEditingController();
  String? _functionResult;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final enabled = await AccessibilityUtils.isAccessibilityServiceEnabled();
    setState(() => _isAccessibilityEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          t.t('app_title'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _refreshStatus();
              _showSnackBar(t.t('status_refreshed'));
            },
            tooltip: t.t('status_refreshed'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(t),
            const SizedBox(height: 24),
            _buildAccessibilitySection(t),
            if (_functionResult != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(_functionResult!),
            ],
            const SizedBox(height: 24),
            _buildInstructionsCard(t),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAccessibilityEnabled
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE94560),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isAccessibilityEnabled ? Icons.check_circle : Icons.warning,
            size: 48,
            color: _isAccessibilityEnabled
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE94560),
          ),
          const SizedBox(height: 16),
          Text(
            _isAccessibilityEnabled
                ? t.t('status_active')
                : t.t('status_inactive'),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isAccessibilityEnabled
                ? t.t('status_ready')
                : t.t('status_enable'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Column(
            children: [
              const Icon(
                Icons.accessibility,
                color: Color(0xFFE94560),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                t.t('accessibility'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            t.t('accessibility_desc'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await AccessibilityUtils.openAccessibilitySettings();
                  _showSnackBar(t.t('open_settings'));
                } catch (e) {
                  _showSnackBar(_friendlyError(e), error: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAccessibilityEnabled
                    ? const Color(0xFFE94560)
                    : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isAccessibilityEnabled
                    ? t.t('manage_in_settings')
                    : t.t('enable_service'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    );
  }

  Widget _buildInstructionsCard(AppLocalizations t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline,
                  color: Color(0xFFE94560), size: 48),
              const SizedBox(width: 12),
              Text(
                t.t('how_to_use'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(t.t('1'), t.t('step_1_t'), t.t('step_1_d')),
          _buildInstructionStep(t.t('2'), t.t('step_2_t'), t.t('step_2_d')),
          _buildInstructionStep(t.t('3'), t.t('step_3_t'), t.t('step_3_d')),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
      String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE94560),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool error = false}) {
    final text = _friendlyError(message);
    final bg = error ? const Color(0xFFB00020) : const Color(0xFF0F3460);
    final icon = error ? Icons.error_outline : Icons.check_circle_outline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.replaceFirst('Exception: ', '') : s;
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
