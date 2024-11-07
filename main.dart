import 'dart:io';
import 'quiz.dart';
import 'question.dart';
import 'answer.dart';

void main() async {
  var quiz = Quiz();
  quiz.addQuestion(SingleChoice(
      "What is the capital of France?",
      [
        Answer("London", false),
        Answer("Berlin", false),
        Answer("Paris", true),
        Answer("Madrid", false),
      ]
  ));
  quiz.addQuestion(MultipleChoice(
      "Which of these are programming languages?",
      [
        Answer("Python", true),
        Answer("Cobra", false),
        Answer("Java", true),
        Answer("Coffee", false),
      ]
  ));
  quiz.addQuestion(SingleChoice(
      "Who painted the Mona Lisa?",
      [
        Answer("Vincent van Gogh", false),
        Answer("Leonardo da Vinci", true),
        Answer("Pablo Picasso", false),
        Answer("Claude Monet", false),
      ]
  ));
  quiz.addQuestion(SingleChoice("What is boy",
      [
        Answer("Girl", false),
        Answer("Boy", true),
      ]
  ));

  await quiz.start();

  // Wait for user input before closing
  print('Press Enter to exit...');
  stdin.readLineSync();
}