/**
 * Player Controls Widget
 * 
 * Reusable widget for player control buttons.
 * Includes previous, play/pause, and next buttons.
 */

import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isLoading;

  const PlayerControls({
    Key? key,
    required this.isPlaying,
    required this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 40,
          onPressed: onPrevious,
          color: onPrevious != null ? Colors.white : Colors.white38,
        ),
        
        const SizedBox(width: 20),
        
        // Play/Pause button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.green,
                  ),
            iconSize: 48,
            onPressed: isLoading ? null : onPlayPause,
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Next button
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 40,
          onPressed: onNext,
          color: onNext != null ? Colors.white : Colors.white38,
        ),
      ],
    );
  }
}
