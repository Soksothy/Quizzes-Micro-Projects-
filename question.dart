import 'answer.dart';

const String resetColor = '\x1B[0m';
const String questionColor = '\x1B[34m';
const String answerColor = '\x1B[32m';
const String timeColor = '\x1B[31m';

abstract class Question {
  String title;
  List<Answer> answers;

  Question(this.title, this.answers);

  bool checkAnswer(List<int> selectedAnswers);
  void display(int questionNumber, {int? remainingTime});
}

class SingleChoice extends Question {
  SingleChoice(String title, List<Answer> answers)
      : super(title, answers);

  @override
  bool checkAnswer(List<int> selectedAnswers) {
    if (selectedAnswers.length != 1) return false;
    return answers[selectedAnswers[0]].isCorrect;
  }

  @override
  void display(int questionNumber, {int? remainingTime}) {
    print('\n${questionColor}┌${'─' * 54}┐');
    print('│ Question $questionNumber: $title'.padRight(55) + '│');
    if (remainingTime != null) {
      print('│ Time Remaining: ${remainingTime.toString().padLeft(2, '0')}s'.padRight(55) + '│');
    }
    print('├${'─' * 54}┤');
    for (var i = 0; i < answers.length; i++) {
      print('│ ${String.fromCharCode(65 + i)}. ${answers[i].text}'.padRight(55) + '│');
    }
    print('└${'─' * 54}┘$resetColor');
    print('|Select one answer|');
  }
}

class MultipleChoice extends Question {
  MultipleChoice(String title, List<Answer> answers)
      : super(title, answers);

  @override
  bool checkAnswer(List<int> selectedAnswers) {
    for (var i = 0; i < answers.length; i++) {
      if (answers[i].isCorrect != selectedAnswers.contains(i)) {
        return false;
      }
    }
    return true;
  }

  @override
  void display(int questionNumber, {int? remainingTime}) {
    print('\n${questionColor}┌${'─' * 54}┐');
    print('│ Question $questionNumber: $title'.padRight(55) + '│');
    if (remainingTime != null) {
      print('│ Time Remaining: ${remainingTime.toString().padLeft(2, '0')}s'.padRight(55) + '│');
    }
    print('├${'─' * 54}┤');
    for (var i = 0; i < answers.length; i++) {
      print('│ ${String.fromCharCode(65 + i)}. ${answers[i].text}'.padRight(55) + '│');
    }
    print('└${'─' * 54}┘$resetColor');
    print('|Select multiple answers by separating with commas like A,C |');
  }
}