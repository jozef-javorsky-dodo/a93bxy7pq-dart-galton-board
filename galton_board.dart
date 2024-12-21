import 'dart:io';
import 'dart:math';

void main() {
  final board = GaltonBoard();
  final rows = board.getInput(
      prompt: '\nEnter the number of rows (default 9): ', defaultValue: 9);
  final balls = board.getInput(
      prompt: 'Enter the number of balls (default 256): ', defaultValue: 256);

  final distribution = board.simulate(rows, balls);
  final stats = board.calculateStatistics(distribution);

  print('Galton Board Simulation with $balls balls and $rows rows: ');
  print('');
  board.visualize(distribution, stats);

  print('\nStatistics: $stats\n\n');
}

class GaltonBoard {
  int getInput({required String prompt, required int defaultValue}) {
    stdout.write(prompt);
    final input = stdin.readLineSync();
    return int.tryParse(input ?? '') ?? defaultValue;
  }

  List<int> simulate(int rows, int balls) {
    final distribution = List.filled(rows + 1, 0);
    final random = Random();
    for (var i = 0; i < balls; i++) {
      var bin = 0;
      for (var j = 0; j < rows; j++) {
        if (random.nextBool()) {
          bin++;
        }
      }
      distribution[bin]++;
    }
    return distribution;
  }

  Statistics calculateStatistics(List<int> distribution) {
    final totalBalls = distribution.reduce((a, b) => a + b).toDouble();
    if (totalBalls == 0) {
      return Statistics(mean: 0, stdDev: 0, variance: 0);
    }
    final mean = distribution
            .asMap()
            .entries
            .map((e) => e.key * e.value)
            .reduce((a, b) => a + b) /
        totalBalls;
    final variance = distribution
            .asMap()
            .entries
            .map((e) => pow(e.key - mean, 2) * e.value)
            .reduce((a, b) => a + b) /
        totalBalls;
    final stdDev = sqrt(variance);
    return Statistics(mean: mean, stdDev: stdDev, variance: variance);
  }

  void visualize(List<int> distribution, Statistics stats) {
    final maxValue = distribution.reduce(max);
    const width = 40;
    for (var i = 0; i < distribution.length; i++) {
      final barWidth =
          (maxValue > 0) ? ((distribution[i] / maxValue) * width).toInt() : 0;
      final isOutlier = i < stats.mean - 1.5 * stats.stdDev ||
          i > stats.mean + 1.5 * stats.stdDev;
      final bar = List.filled(barWidth, isOutlier ? '~' : '#').join();
      print('$i: $bar (${distribution[i]})');
    }
  }
}

class Statistics {
  final double mean;
  final double stdDev;
  final double variance;

  Statistics(
      {required this.mean, required this.stdDev, required this.variance});

  @override
  String toString() =>
      '\nMean: ${mean.toStringAsFixed(2)}, \nStdDev: ${stdDev.toStringAsFixed(2)}, \nVariance: ${variance.toStringAsFixed(2)}';
}
