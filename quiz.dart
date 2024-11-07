import 'dart:io';
import 'dart:async';
import 'question.dart';
import 'participant.dart';

const String resetColor = '\x1B[0m';
const String titleColor = '\x1B[35m'; // Magenta
const String promptColor = '\x1B[36m'; // Cyan
const String resultColor = '\x1B[33m'; // Yellow

class Quiz {
  List<Question> questions = [];
  List<Participant> participants = [];
  int quizDuration = 10; // Total quiz duration in seconds

  void addQuestion(Question question) {
    questions.add(question);
  }

  void addParticipant(Participant participant) {
    participants.add(participant);
  }

  Future<void> start() async {
    _displayWelcomeMessage();
    String firstName = _getInput('${promptColor}𝗣𝗹𝗲𝗮𝘀𝗲 𝗲𝗻𝘁𝗲𝗿 𝘆𝗼𝘂𝗿 𝗳𝗶𝗿𝘀𝘁 𝗻𝗮𝗺𝗲:$resetColor');
    String lastName = _getInput('${promptColor}𝗣𝗹𝗲𝗮𝘀𝗲 𝗲𝗻𝘁𝗲𝗿 𝘆𝗼𝘂𝗿 𝗹𝗮𝘀𝘁 𝗻𝗮𝗺𝗲:$resetColor');
    var participant = Participant(firstName, lastName);
    addParticipant(participant);
    _prepareForQuiz(participant);
    questions.shuffle(); // Randomize question order
    var endTime = DateTime.now().add(Duration(seconds: quizDuration));
    List<List<int>> participantAnswers = await _conductQuiz(participant, endTime);
    var remainingTime = endTime.difference(DateTime.now()).inSeconds;
    displayResults(participant, remainingTime);
    saveResultsToFile(participant, questions, participantAnswers, participant.answerTimes, remainingTime);
  }

  void _displayWelcomeMessage() {
    print('''
${titleColor}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                                                                ┃
┃   ██████  ██    ██ ██ ███████     ████████ ██ ███    ███ ███████┃
┃  ██    ██ ██    ██ ██    ███         ██    ██ ████  ████ ██     ┃
┃  ██    ██ ██    ██ ██   ███          ██    ██ ██ ████ ██ █████  ┃
┃  ██ ▄▄ ██ ██    ██ ██  ███           ██    ██ ██  ██  ██ ██     ┃
┃   ██████   ██████  ██ ███████        ██    ██ ██      ██ ███████┃
┃      ▀▀                                                        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛$resetColor
    ''');
  }

  String _getInput(String prompt) {
    print(prompt);
    return stdin.readLineSync() ?? '';
  }

  void _prepareForQuiz(Participant participant) {
    print('\n${promptColor}${participant.firstName},𝗴𝗲𝘁 𝗿𝗲𝗮𝗱𝘆 𝗳𝗼𝗿 𝘆𝗼𝘂𝗿 𝗾𝘂𝗶𝘇❗$resetColor');
    print('${promptColor}𝗬𝗼𝘂 𝗵𝗮𝘃𝗲 $quizDuration 𝘀𝗲𝗰𝗼𝗻𝗱𝘀 𝘁𝗼 𝗰𝗼𝗺𝗽𝗹𝗲𝘁𝗲 𝘁𝗵𝗲 𝗲𝗻𝘁𝗶𝗿𝗲 𝗾𝘂𝗶𝘇 ⌚.$resetColor');
    print('${promptColor}𝙋𝙧𝙚𝙨𝙨 𝙀𝙣𝙩𝙚𝙧 𝙩𝙤 𝙨𝙩𝙖𝙧𝙩 𝙩𝙝𝙚 𝙦𝙪𝙞𝙯 🫡.$resetColor');
    stdin.readLineSync();
  }

  Future<List<List<int>>> _conductQuiz(Participant participant, DateTime endTime) async {
    List<List<int>> participantAnswers = [];
    Timer? countdownTimer;

    for (var i = 0; i < questions.length; i++) {
      var question = questions[i];
      question.answers.shuffle(); // Randomize answer order
      var remainingTime = endTime.difference(DateTime.now()).inSeconds;
      question.display(i + 1, remainingTime: remainingTime);

      countdownTimer = _startCountdown(endTime);

      var questionStartTime = DateTime.now();
      List<int> selectedAnswers = await _askQuestion(question);
      var answerTime = DateTime.now().difference(questionStartTime);
      participantAnswers.add(selectedAnswers);
      participant.answerQuestion(question, selectedAnswers, answerTime);

      countdownTimer.cancel();

      if (selectedAnswers.isEmpty) {
        print('\n${promptColor}Answer is not input!$resetColor');
      }

      if (DateTime.now().isAfter(endTime)) {
        print('\n${promptColor}Time\'s up! The quiz has ended.$resetColor');
        break;
      }
    }

    countdownTimer?.cancel();
    return participantAnswers;
  }

  Timer _startCountdown(DateTime endTime) {
    return Timer.periodic(Duration(seconds: 1), (timer) {
      var remainingTime = endTime.difference(DateTime.now()).inSeconds;
      stdout.write('\r${promptColor}Time remaining: ${remainingTime.toString().padLeft(2, '0')} seconds$resetColor');

      if (remainingTime <= 0) {
        timer.cancel();
      }
    });
  }

  Future<List<int>> _askQuestion(Question question) async {
    var input = stdin.readLineSync() ?? '';
    return input.trim().toUpperCase().split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => e.codeUnitAt(0) - 65)
        .where((e) => e >= 0 && e < question.answers.length)
        .toList();
  }

  void displayResults(Participant participant, int remainingTime) {
    print('\n${resultColor}┌${'─' * 50}┐');
    print('│ QUIZ RESULTS                                    │');
    print('├${'─' * 50}┤');
    print('│ ${participant.firstName} ${participant.lastName}: ${participant.score}/${questions.length}'.padRight(50) + '│');
    print('│ Time Remaining: ${remainingTime.toString().padLeft(2, '0')} seconds'.padRight(50) + '│');

    for (var i = 0; i < questions.length; i++) {
        var isCorrect = i < participant.correctAnswers.length && participant.correctAnswers[i] ? "Correct" : "Incorrect";
        print('│ Question ${i + 1}: $isCorrect'.padRight(50) + '│');
    }

    print('└${'─' * 50}┘$resetColor');
  }

  void saveResultsToFile(Participant participant, List<Question> questions, List<List<int>> participantAnswers, List<Duration> answerTimes, int remainingTime) {
    var file = File('quiz_results.txt');
    var sink = file.openWrite(mode: FileMode.append);
    sink.writeln('________________________________________________________');
    sink.writeln('Quiz Results');
    sink.writeln('Date: ${DateTime.now()}');
    sink.writeln('Participant: ${participant.firstName} ${participant.lastName}');
    sink.writeln('Score: ${participant.score}/${questions.length}');
    sink.writeln('Time Remaining: ${remainingTime.toString().padLeft(2, '0')} seconds');

    sink.writeln('Answers Given:');
    for (var i = 0; i < questions.length; i++) {
        var question = questions[i];
        var givenAnswers = i < participantAnswers.length && participantAnswers[i].isNotEmpty
            ? participantAnswers[i].map((index) => String.fromCharCode(65 + index)).join(', ')
            : 'None';
        var correctAnswers = question.answers
            .asMap()
            .entries
            .where((entry) => entry.value.isCorrect)
            .map((entry) => String.fromCharCode(65 + entry.key))
            .join(', ');
        var timeTaken = i < answerTimes.length ? '${answerTimes[i].inSeconds}s' : 'None';

        sink.writeln('Question ${i + 1}: ${question.title}');
        sink.writeln('  Given: $givenAnswers');
        sink.writeln('  Correct: $correctAnswers');
        sink.writeln('  Time Taken: $timeTaken');
        sink.writeln('  Result: ${givenAnswers == correctAnswers ? 'Correct' : 'Incorrect'}');
        sink.writeln('________________________________________________________');
    }

    sink.close();
  }
}