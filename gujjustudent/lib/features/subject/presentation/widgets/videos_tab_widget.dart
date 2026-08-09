import 'package:flutter/material.dart';
import 'package:edustream/features/subject/data/models/subject_models.dart';
import 'package:edustream/features/subject/presentation/screens/video_player_screen.dart';

class VideosTabWidget extends StatelessWidget {
  final List<FolderModel> folders;
  final List<VideoModel> rootVideos;
  final int subjectId;
  final Function(FolderModel) onFolderTap;

  const VideosTabWidget({
    super.key,
    required this.folders,
    this.rootVideos = const [],
    required this.subjectId,
    required this.onFolderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty && rootVideos.isEmpty) {
      return const Center(child: Text('No videos available yet.'));
    }
    
    final int totalCount = folders.length + rootVideos.length;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < folders.length) {
          return _buildFolderCard(folders[index], context);
        } else {
          return _buildVideoCard(rootVideos[index - folders.length], context);
        }
      },
    );
  }

  Widget _buildFolderCard(FolderModel folder, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.folder_rounded, color: Color(0xFF1565C0), size: 28),
            ),
            title: Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1A2E)),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${folder.itemCount} items',
                style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCCCCCC)),
            onTap: () => onFolderTap(folder),
          ),
          if (folder.isFree)
            Positioned(
              top: 12,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('FREE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF1565C0), size: 28),
            ),
            title: Text(
              video.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1A2E)),
            ),
            subtitle: video.duration != null ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                video.duration!,
                style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ) : null,
            trailing: const Icon(Icons.play_arrow_rounded, size: 24, color: Color(0xFF1565C0)),
            onTap: () {
              if (video.processingStatus != 'completed') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video is still processing. Please try again later.')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoId: video.id,
                    videoName: video.name,
                  ),
                ),
              );
            },
          ),
          if (video.isFree)
            Positioned(
              top: 12,
              right: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('FREE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }
}
