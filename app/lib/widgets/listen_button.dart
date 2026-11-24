import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

class ListenButton extends StatefulWidget {
  final String audioPath;
  final String label;
  final IconData icon;
  final Color? color;

  const ListenButton({
    super.key,
    required this.audioPath,
    this.label = 'Listen',
    this.icon = Icons.volume_up,
    this.color,
  });

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton> {
  final AudioService _audio = AudioService();
  bool _isPlaying = false;

  Future<void> _onPressed() async {
    if (_isPlaying) {
      await _audio.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _audio.playAsset(widget.audioPath);
      _audio._player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onPressed,
        icon: Icon(_isPlaying ? Icons.stop : widget.icon, size: 24),
        label: Text(
          _isPlaying ? 'Playing...' : widget.label,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color ?? const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}