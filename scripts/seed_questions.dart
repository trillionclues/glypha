import 'dart:convert';
import 'dart:io';
import 'package:firedart/firedart.dart';

const projectId = 'edusync-hub-62d3c';

Future<void> main() async {
  print('🚀 Starting Glypha Firestore Seeder...');

  // If you run the Firebase Emulator suite, this tells Firedart to use it
  // Platform.environment['FIRESTORE_EMULATOR_HOST'] = '127.0.0.1:8080';

  Firestore.initialize(projectId);

  // Read sample questions from assets/data/sample_questions.json
  final file = File('assets/data/sample_questions.json');
  if (!await file.exists()) {
    print('❌ Error: assets/data/sample_questions.json not found.');
    return;
  }

  final String content = await file.readAsString();
  final List<dynamic> questions = jsonDecode(content);

  print('📦 Found ${questions.length} questions to seed.');

  final collection = Firestore.instance.collection('allQuestions');

  for (final q in questions) {
    try {
      final id = q['id'];
      // Standardize for new schema
      final data = Map<String, dynamic>.from(q)..remove('id');
      data['ownerId'] = 'SYSTEM';
      data['isPublic'] = true;
      data['createdAt'] = DateTime.now().toIso8601String();
      data.remove('createdBy');

      await collection.document(id).set(data);
      print('✅ Seeded: ${id}');
    } catch (e) {
      print('❌ Failed to seed ${q['id']}: $e');
    }
  }

  print('\n✨ Seeding completed!');
  print(
      '💡 Note: If you get permission errors, ensure your Firestore rules allow writes to "allQuestions" or use a Service Account.');
}


// PS: dart scripts/seed_questions.dart to run command