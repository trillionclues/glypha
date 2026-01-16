import 'dart:convert';
import 'dart:io';
import 'package:firedart/firedart.dart';

const projectId = 'edusync-hub-62d3c';

Future<void> main() async {
  print('🚀 Starting Glypha Firestore Seeder...');

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

  final collection = Firestore.instance.collection('questionBanks');

  for (final q in questions) {
    try {
      final id = q['id'];
      // Remove id from map before saving as document data
      final data = Map<String, dynamic>.from(q)..remove('id');

      // additive: check if exists or just overwrite
      await collection.document(id).set(data);
      print('✅ Seeded: ${id}');
    } catch (e) {
      print('❌ Failed to seed ${q['id']}: $e');
    }
  }

  print('\n✨ Seeding completed!');
  print(
      '💡 Note: If you get permission errors, ensure your Firestore rules allow writes to "questionBanks" or use a Service Account.');
}
