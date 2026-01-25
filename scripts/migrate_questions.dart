import 'dart:convert';
import 'dart:io';

// Enum simulation
const String runner = 'runner';
const String swipe = 'swipe';
const String stack = 'stack';
const String match = 'match';

void main() async {
  final file = File('assets/data/sample_questions.json');
  if (!await file.exists()) {
    print('File not found');
    return;
  }

  final String content = await file.readAsString();
  final List<dynamic> questions = jsonDecode(content);
  final List<dynamic> updatedQuestions = [];

  for (var q in questions) {
    final Map<String, dynamic> newQ = Map.from(q);
    final String id = newQ['id'];
    final String type = newQ['type'];
    final String prompt = newQ['prompt'];

    List<String> modes = [];

    // Inference Logic
    if (id.startsWith('sys_stack_') || prompt.startsWith('Category:')) {
      modes.add(stack);
    } else if (id.startsWith('sys_match_') || type == 'matchPair') {
      modes.add(match);
    } else if (id.startsWith('sys_bin_') || type == 'binary') {
      modes.add(swipe);
      modes.add(runner); // Binary works for runner too
    } else if (id.startsWith('sys_mcq_') || type == 'mcq') {
      modes.add(runner);
    } else {
      // Fallback based on type
      if (type == 'binary') {
        modes.add(swipe);
        modes.add(runner);
      } else if (type == 'mcq') {
        modes.add(runner);
      } else if (type == 'matchPair') {
        modes.add(match);
      }
    }

    newQ['compatibleModes'] = modes;
    updatedQuestions.add(newQ);
  }

  // Write back
  final encoder = JsonEncoder.withIndent('    ');
  await file.writeAsString(encoder.convert(updatedQuestions));
  print('Updated ${updatedQuestions.length} questions.');
}
