import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final Map<String, int> categories = const {
    'General Knowledge': 9,
    'Books': 10,
    'Film': 11,
    'Science & Nature': 17,
    'Computers': 18,
    'Mathematics': 19,
    'Sports': 21,
    'Geography': 22,
    'History': 23,
    'Art': 25,
  };
  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'Books':
        return Icons.book;
      case 'Film':
        return Icons.movie;
      case 'Science & Nature':
        return Icons.science;
      case 'Computers':
        return Icons.computer;
      case 'Mathematics':
        return Icons.functions;
      case 'Sports':
        return Icons.sports_soccer;
      case 'Geography':
        return Icons.public;
      case 'History':
        return Icons.history_edu;
      case 'Art':
        return Icons.palette;
      default:
        return Icons.lightbulb;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AdvancedGradientBg(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with animated logo and title
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(right: 16),
                        child: Hero(
                          tag: 'app_logo',
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage:
                                AssetImage('assets/icon/app_icon.png'),
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quiz Game",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Test Your Knowledge!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Pick a Category",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        String title = categories.keys.elementAt(index);
                        int id = categories[title]!;
                        return GlassFloatingCard(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizLoader(
                                    categoryName: title,
                                    categoryId: id,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.9),
                                  radius: 36,
                                  child: Icon(
                                    _getCategoryIcon(title),
                                    size: 40,
                                    color: const Color(0xFF1E88E5),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 6,
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizLoader extends StatefulWidget {
  final String categoryName;
  final int categoryId;
  const QuizLoader({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });
  @override
  State<QuizLoader> createState() => _QuizLoaderState();
}

class _QuizLoaderState extends State<QuizLoader> {
  bool loading = true;
  String error = '';
  List<dynamic> questions = [];
  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=10&category=${widget.categoryId}&type=multiple';
    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      if (data['response_code'] == 0) {
        setState(() {
          questions = data['results'];
          loading = false;
        });
      } else {
        throw Exception("No questions found.");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E88E5),
                const Color(0xFF42A5F5).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AdvancedGradientBg(),
          Center(
            child: loading
                ? const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                  )
                : error.isNotEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[300],
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error: $error",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: loadQuestions,
                            icon: const Icon(Icons.refresh, size: 22),
                            label: const Text(
                              "Try Again",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      )
                    : QuizPage(questions: questions),
          ),
        ],
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final List<dynamic> questions;
  const QuizPage({super.key, required this.questions});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final HtmlUnescape unescape = HtmlUnescape();

  int currentQuestion = 0;
  int correctAnswers = 0;
  bool answered = false;
  void checkAnswer(String selectedAnswer) {
    if (answered) return;
    setState(() {
      answered = true;
      if (selectedAnswer ==
          widget.questions[currentQuestion]['correct_answer']) {
        correctAnswers++;
        showSnack("Correct!✅", Colors.green[400]!);
      } else {
        showSnack("Incorrect!❌", Colors.red[400]!);
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        if (currentQuestion + 1 < widget.questions.length) {
          currentQuestion++;
          answered = false;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ScorePage(
                score: correctAnswers,
                total: widget.questions.length,
              ),
            ),
          );
        }
      });
    });
  }

  void showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var q = widget.questions[currentQuestion];
    List<String> answers = List<String>.from(q['incorrect_answers']);
    answers.add(q['correct_answer']);
    answers.shuffle();
    double progress = (currentQuestion + 1) / widget.questions.length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: const Color(0xFF1E88E5),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Question ${currentQuestion + 1}/${widget.questions.length}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GlassFloatingCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$correctAnswers Correct",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GlassFloatingCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  unescape.convert(q['question']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...answers.map(
              (ans) => AnimatedCard(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: answered && ans == q['correct_answer']
                            ? Colors.green[400]!
                            : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      backgroundColor: answered && ans == q['correct_answer']
                          ? Colors.green.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: answered ? null : () => checkAnswer(ans),
                    child: Text(
                      unescape.convert(ans),
                      style: TextStyle(
                        color: answered && ans == q['correct_answer']
                            ? Colors.green[200]
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScorePage extends StatelessWidget {
  final int score;
  final int total;
  const ScorePage({super.key, required this.score, required this.total});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AdvancedGradientBg(),
          Center(
            child: GlassFloatingCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 48,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Quiz Completed!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Your Score",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.home, size: 24),
                      label: const Text(
                        "Back to Home",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassFloatingCard extends StatelessWidget {
  final Widget child;
  const GlassFloatingCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedCard extends StatelessWidget {
  final Widget child;
  const AnimatedCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween<double>(begin: 0.95, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, double value, _) {
        return Transform.scale(
          scale: value,
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        );
      },
    );
  }
}

class AdvancedGradientBg extends StatelessWidget {
  const AdvancedGradientBg({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2193b0), // Teal Blue
            Color(0xFF6dd5ed), // Light Cyan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(0.7, -0.7),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.8, 0.8),
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
