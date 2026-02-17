import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LibraryScreen extends StatelessWidget {
  final void Function(String title, String url) onSessionSelected;

  const LibraryScreen({super.key, required this.onSessionSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Text('Explore Bali', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        _libCard(
          title: 'Lower Back Relief',
          url: 'https://assets.mixkit.co/videos/preview/mixkit-top-view-of-a-beach-resort-with-palm-trees-1551-large.mp4',
        ),
        _libCard(
          title: 'Deep Neck Stretch',
          url: 'https://assets.mixkit.co/videos/preview/mixkit-waterfall-in-the-forest-1553-large.mp4',
        ),
      ],
    );
  }

  Widget _libCard({required String title, required String url}) {
    return Builder(
      builder: (context) => Card(
        child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.play_arrow_rounded),
          onTap: () {
            HapticFeedback.selectionClick();
            onSessionSelected(title, url);
          },
        ),
      ),
    );
  }
}
