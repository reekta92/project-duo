import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'quiz_service.dart';

class ReportService {
  final QuizService _quizService = QuizService();

  /// Generate and print a PDF report
  Future<void> generatePdfReport(String userId) async {
    final pdf = pw.Document();

    // Collect data
    final masteredCount = await _quizService.getMasteredCount(userId);
    final inProgressCount = await _quizService.getInProgressCount(userId);
    final accuracy = await _quizService.getOverallAccuracy(userId);
    final sessions = await _quizService.getSessionHistory(userId, limit: 20);
    final totalWords = masteredCount + inProgressCount;

    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('6 Sefer Kelime Oyunu - İlerleme Raporu',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                )),
          ),
          pw.SizedBox(height: 20),

          // Overall stats
          pw.Header(level: 1, text: 'Genel İstatistikler'),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _statBox('Toplam Kelime', '$totalWords', PdfColors.blue),
              _statBox('Ustalaşılan', '$masteredCount', PdfColors.green),
              _statBox('Öğrenilen', '$inProgressCount', PdfColors.orange),
              _statBox('Başarı Oranı', '%${accuracy.round()}', PdfColors.purple),
            ],
          ),
          pw.SizedBox(height: 30),

          // Session history
          pw.Header(level: 1, text: 'Quiz Geçmişi'),
          if (sessions.isEmpty)
            pw.Paragraph(text: 'Henüz quiz tamamlanmamış.')
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue,
              ),
              headers: ['Tarih', 'Soru', 'Doğru', 'Yanlış', 'Başarı', 'Süre'],
              data: sessions.map((s) {
                final date = s.startedAt != null
                    ? '${s.startedAt!.day}.${s.startedAt!.month}.${s.startedAt!.year}'
                    : '-';
                final dur = s.durationSeconds != null
                    ? '${(s.durationSeconds! / 60).round()}dk'
                    : '-';
                return [
                  date,
                  '${s.totalQuestions}',
                  '${s.correctAnswers}',
                  '${s.wrongAnswers}',
                  '%${s.accuracy.round()}',
                  dur,
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 20),
          pw.Paragraph(
            text:
                'Rapor oluşturulma: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
            style: const pw.TextStyle(
              color: PdfColors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );

    // Print or share
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'kelime_oyunu_raporu.pdf',
    );
  }

  pw.Container _statBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}
