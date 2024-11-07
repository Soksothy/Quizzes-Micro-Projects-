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
  quiz.addQuestion(SingleChoice("What is CADT?",
      [
        Answer("University", true),
        Answer("High school", false),
      ]
  ));
  quiz.addQuestion(MultipleChoice(
      "Which countries are in Europe?",
      [
        Answer("France", true),
        Answer("Germany", true),
        Answer("Cambodia", false),
        Answer("India", false),
      ]
  ));
  await quiz.start();


  print('Good Luck 🍀!');
  stdin.readLineSync();
}