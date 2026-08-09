class LessonModel {
  final String id;
  final String title;
  final String duration;
  final bool isLocked;
  final String type; // video, quiz, notes

  LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    this.isLocked = false,
    this.type = 'video',
  });
}

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String price;
  final String description;
  final double rating;
  final String thumbnail;
  final List<LessonModel> lessons;

  CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.price,
    required this.description,
    required this.rating,
    required this.thumbnail,
    required this.lessons,
  });
  
  // Dummy Data Generator
  static CourseModel get dummy {
    return CourseModel(
      id: "1", 
      title: "Flutter Masterclass: Zero to Hero", 
      instructor: "Kalp Shah", 
      price: "₹499", 
      description: "Learn Flutter from scratch and build real-world apps. This course covers everything from Dart basics to advanced state management.", 
      rating: 4.8, 
      thumbnail: "https://dummyimage.com/600x400/000/fff&text=Flutter+Masterclass",
      lessons: [
        LessonModel(id: "1", title: "Introduction to Flutter", duration: "10:00", isLocked: false, type: 'video'),
        LessonModel(id: "2", title: "Dart Basics", duration: "25:00", isLocked: true, type: 'video'),
        LessonModel(id: "3", title: "Building UI Layouts", duration: "40:00", isLocked: true, type: 'video'),
        LessonModel(id: "4", title: "State Management", duration: "15:00", isLocked: true, type: 'notes'),
        LessonModel(id: "5", title: "Final Quiz", duration: "20 Mins", isLocked: true, type: 'quiz'),
      ]
    );
  }
}
