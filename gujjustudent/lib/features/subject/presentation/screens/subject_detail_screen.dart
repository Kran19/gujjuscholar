import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:edustream/features/subject/presentation/providers/subject_providers.dart';
import 'package:edustream/features/subject/data/models/subject_models.dart';
import 'package:edustream/features/cart/presentation/providers/cart_controller.dart';
import 'package:edustream/features/subject/presentation/widgets/videos_tab_widget.dart';
import 'package:edustream/features/subject/presentation/widgets/notes_tab_widget.dart';
import 'package:edustream/features/subject/presentation/widgets/quizzes_tab_widget.dart';
import 'package:edustream/features/subject/presentation/widgets/qa_papers_tab_widget.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final int subjectId;
  final String subjectName;
  const SubjectDetailScreen({super.key, required this.subjectId, required this.subjectName});

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<FolderModel> _navigationStack = [];
  String? _navigationType;

  void _pushFolder(FolderModel folder, String type) {
    setState(() {
      _navigationStack.add(folder);
      _navigationType = type;
    });
  }

  void _popFolder() {
    setState(() {
      if (_navigationStack.isNotEmpty) {
        _navigationStack.removeLast();
        if (_navigationStack.isEmpty) _navigationType = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectAsync = ref.watch(subjectDetailsProvider(widget.subjectId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () {
            if (_navigationStack.isNotEmpty) {
              _popFolder();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          subjectAsync.hasValue ? (subjectAsync.value!.courseName ?? 'Subject') : 'Loading...',
          style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800),
        ),
      ),
      body: subjectAsync.when(
        data: (subject) => _buildBody(context, subject),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      bottomNavigationBar: subjectAsync.hasValue ? _buildBottomBar(subjectAsync.value!) : null,
    );
  }

  Widget _buildBody(BuildContext context, SubjectDetailModel subject) {
    if (_navigationStack.isNotEmpty && _navigationType != null) {
      return _buildFolderContent(context, subject);
    }
    return _buildMainContent(context, subject);
  }

  Widget _buildMainContent(BuildContext context, SubjectDetailModel subject) {
    return Column(
      children: [
        // 1. Subject Identifier Header
        _buildHeader(subject.name),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

        // 2. Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: const Color(0xFF1565C0),
            indicatorWeight: 3,
            labelColor: const Color(0xFF1565C0),
            unselectedLabelColor: Colors.black.withValues(alpha: 0.4),
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: const [
              Tab(icon: Icon(Icons.play_circle_outline_rounded), text: 'Videos'),
              Tab(icon: Icon(Icons.description_outlined), text: 'Notes'),
              Tab(icon: Icon(Icons.quiz_outlined), text: 'Tests'),
              Tab(icon: Icon(Icons.history_edu_outlined), text: 'QA Papers'),
            ],
          ),
        ),

        // 3. Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              VideosTabWidget(
                folders: subject.videoFolders,
                rootVideos: subject.rootVideos,
                subjectId: subject.id,
                onFolderTap: (folder) => _pushFolder(folder, 'video'),
              ),
              NotesTabWidget(
                folders: subject.noteFolders,
                rootNotes: subject.rootNotes,
                subjectId: subject.id,
                onFolderTap: (folder) => _pushFolder(folder, 'note'),
              ),
              QuizzesTabWidget(quizzes: subject.quizzes),
              QAPapersTabWidget(
                folders: subject.paperFolders,
                rootPapers: subject.rootPapers,
                subjectId: subject.id,
                onFolderTap: (folder) => _pushFolder(folder, 'paper'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFolderContent(BuildContext context, SubjectDetailModel subject) {
    final currentFolder = _navigationStack.last;
    final folderContentAsync = ref.watch(folderContentProvider(FolderContentParam(
      subjectId: subject.id,
      folderId: currentFolder.id,
      type: _navigationType!,
    )));

    return Column(
      children: [
        _buildHeader(currentFolder.name),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: folderContentAsync.when(
            data: (content) {
              if (_navigationType == 'video') {
                return VideosTabWidget(
                  folders: content.folders,
                  rootVideos: content.items.cast<VideoModel>(),
                  subjectId: subject.id,
                  onFolderTap: (folder) => _pushFolder(folder, 'video'),
                );
              } else if (_navigationType == 'paper') {
                return QAPapersTabWidget(
                  folders: content.folders,
                  rootPapers: content.items.cast<NoteModel>(),
                  subjectId: subject.id,
                  onFolderTap: (folder) => _pushFolder(folder, 'paper'),
                );
              } else {
                return NotesTabWidget(
                  folders: content.folders,
                  rootNotes: content.items.cast<NoteModel>(),
                  subjectId: subject.id,
                  onFolderTap: (folder) => _pushFolder(folder, 'note'),
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.visibility_outlined, color: Color(0xFF1565C0), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Currently Viewing: ',
                      style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.check_rounded, color: Color(0xFF1565C0), size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF1565C0), fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomBar(SubjectDetailModel subject) {
    if (subject.isEnrolled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final cartState = ref.watch(cartControllerProvider);
          final bool inCart = cartState.items.any((item) => 
              item['item_id'].toString() == subject.id.toString() && 
              item['item_type'].toString().contains('Subject'));
          
          return ElevatedButton(
            onPressed: inCart || cartState.isLoading ? null : () async {
              try {
                await ref.read(cartControllerProvider).addItem(type: 'subject', itemId: subject.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD600),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: cartState.isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Text(inCart ? 'Already in Cart' : 'Buy Full Subject Course', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          );
        }
      ),
    );
  }
}
