import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  String selectedSubject = "All";

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> liveClasses = [
      {
        "title": "Standard 10 - Mathematics",
        "topic": "Algebraic Equations Mastery",
        "instructor": "Pro. Kalp Shah",
        "time": "LIVE NOW",
        "isLive": true,
        "subject": "Mathematics",
        "thumbnail": "https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&q=80&w=600"
      },
      {
        "title": "Standard 10 - Science",
        "topic": "Molecular Physics Basics",
        "instructor": "Dr. Sarah Lee",
        "time": "04:30 PM",
        "isLive": false,
        "subject": "Science",
        "thumbnail": "https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&q=80&w=600"
      },
      {
        "title": "Standard 9 - English",
        "topic": "Grammar & Composition",
        "instructor": "Ms. Jane Smith",
        "time": "Tomorrow, 10:00 AM",
        "isLive": false,
        "subject": "English",
        "thumbnail": "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?auto=format&fit=crop&q=80&w=600"
      },
    ];

    final subjects = ["All", "Mathematics", "Science", "English"];
    final filteredClasses = selectedSubject == "All"
        ? liveClasses
        : liveClasses.where((element) => element['subject'] == selectedSubject).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Classes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSubjectFilter(subjects),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filteredClasses.length,
              itemBuilder: (context, index) {
                return _buildLiveClassCard(context, filteredClasses[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter(List<String> subjects) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final isSelected = selectedSubject == subjects[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(subjects[index]),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  selectedSubject = subjects[index];
                });
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? Colors.transparent : AppColors.primary.withValues(alpha: 0.25)),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveClassCard(BuildContext context, Map<String, dynamic> live) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    live['thumbnail'],
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: live['isLive'] ? AppColors.error : AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (live['isLive'])
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
                          ),
                        Text(
                          live['isLive'] ? "LIVE NOW" : live['time'],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          live['subject'],
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          live['title'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    live['topic'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(live['instructor'], style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: live['isLive'] ? AppColors.success : AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            live['isLive'] ? "Join Now" : "Remind Me",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
