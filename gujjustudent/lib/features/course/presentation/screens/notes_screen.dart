import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/core/widgets/custom_button.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("State Management Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // PDF Preview Placeholder
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 80, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      "Flutter_State_Management.pdf",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text("Size: 2.4 MB", style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomButton(
              text: "Download PDF",
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
