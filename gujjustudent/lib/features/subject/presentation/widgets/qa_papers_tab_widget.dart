import 'package:flutter/material.dart';
import 'package:edustream/features/subject/data/models/subject_models.dart';
import 'package:url_launcher/url_launcher.dart';

class QAPapersTabWidget extends StatelessWidget {
  final List<FolderModel> folders;
  final List<NoteModel> rootPapers;
  final int subjectId;
  final Function(FolderModel) onFolderTap;

  const QAPapersTabWidget({
    super.key,
    required this.folders,
    this.rootPapers = const [],
    required this.subjectId,
    required this.onFolderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty && rootPapers.isEmpty) {
      return const Center(child: Text('No QA papers available yet.'));
    }
    
    final int totalCount = folders.length + rootPapers.length;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < folders.length) {
          return _buildFolderCard(folders[index], context);
        } else {
          return _buildPaperCard(rootPapers[index - folders.length], context);
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
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.history_edu_rounded, color: Color(0xFFC2185B), size: 28),
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
  
  Widget _buildPaperCard(NoteModel paper, BuildContext context) {
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
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFC2185B), size: 28),
            ),
            title: Text(
              paper.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1A1A2E)),
            ),
            trailing: const Icon(Icons.download_rounded, size: 24, color: Color(0xFFC2185B)),
            onTap: () async {
              if (paper.filePath != null && paper.filePath!.isNotEmpty) {
                final uri = Uri.parse(paper.filePath!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open document.')),
                    );
                  }
                }
              }
            },
          ),
          if (paper.isFree)
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
