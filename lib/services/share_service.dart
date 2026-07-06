import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../models/leyenda.dart';

class ShareService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  // ──────────────────────────────────────────
  // 1. Compartir como texto plano
  // ──────────────────────────────────────────
  static Future<void> shareAsText(Leyenda leyenda) async {
    final text = '${leyenda.imagen} ${leyenda.titulo}\n\n'
        '${leyenda.descripcionLarga}\n\n'
        '📍 Origen: ${leyenda.origen}\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📲 Descubre más leyendas bolivianas en "Leyendas de Bolivia"';

    await SharePlus.instance.share(
      ShareParams(text: text, title: leyenda.titulo),
    );
  }

  // ──────────────────────────────────────────
  // 2. Compartir como PDF
  // ──────────────────────────────────────────
  static Future<void> shareAsPdf(Leyenda leyenda) async {
    final pdf = pw.Document();

    final headerColor = PdfColor.fromHex('#2F6B5F');
    final accentColor = PdfColor.fromHex('#9E4F2E');
    final goldColor = PdfColor.fromHex('#D39A52');
    final textDark = PdfColor.fromHex('#2F241F');
    final textBody = PdfColor.fromHex('#4C3E36');
    final bgLight = PdfColor.fromHex('#F7F1E8');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // ── Header con título ──
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: headerColor,
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    leyenda.departamento.replaceAll('_', ' ').toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  leyenda.titulo,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  leyenda.descripcionCorta,
                  style: const pw.TextStyle(
                    fontSize: 13,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // ── La Historia ──
          _buildPdfSection(
            'La Historia',
            leyenda.descripcionLarga,
            accentColor,
            textDark,
            textBody,
          ),
          pw.SizedBox(height: 16),

          // ── Origen ──
          _buildPdfSection(
            'Origen',
            leyenda.origen,
            accentColor,
            textDark,
            textBody,
          ),
          pw.SizedBox(height: 16),

        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          padding: const pw.EdgeInsets.symmetric(vertical: 14),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: goldColor, width: 2),
            ),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                'Leyendas de Bolivia',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: headerColor,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Descarga la app para descubrir mas leyendas bolivianas',
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final fileName =
        'leyenda_${leyenda.titulo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        title: leyenda.titulo,
        text: 'Descubre "${leyenda.titulo}" - Leyendas de Bolivia',
      ),
    );
  }

  static pw.Widget _buildPdfSection(
    String title,
    String content,
    PdfColor accentColor,
    PdfColor titleColor,
    PdfColor bodyColor,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: PdfColor.fromHex('#E0D5C8')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: accentColor,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            content,
            style: pw.TextStyle(
              fontSize: 13,
              color: bodyColor,
              lineSpacing: 5,
            ),
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // 3. Compartir como imagen (tarjeta visual)
  // ──────────────────────────────────────────
  static Future<void> shareAsImage(
    Leyenda leyenda,
    BuildContext context,
  ) async {
    final cardWidget = _buildShareCard(leyenda);

    final image = await _screenshotController.captureFromWidget(
      cardWidget,
      delay: const Duration(milliseconds: 100),
      pixelRatio: 3.0,
      context: context,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/leyenda_${leyenda.id}.png');
    await file.writeAsBytes(image);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        title: leyenda.titulo,
      ),
    );
  }

  /// Tarjeta visual para compartir en redes sociales
  static Widget _buildShareCard(Leyenda leyenda) {
    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A3D35),
            Color(0xFF2F6B5F),
            Color(0xFF1A3D35),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── App branding top ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD39A52),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'LEYENDAS DE BOLIVIA',
                style: TextStyle(
                  color: Color(0xFFD39A52),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD39A52),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: 120,
            color: const Color(0xFFD39A52).withOpacity(0.4),
          ),
          const SizedBox(height: 32),

          // ── Emoji grande ──
          Text(
            leyenda.imagen,
            style: const TextStyle(
              fontSize: 88,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),

          // ── Título ──
          Text(
            leyenda.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.3,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),

          // ── Badge departamento ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Text(
              leyenda.departamento.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Línea decorativa ──
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.auto_stories,
                  color: const Color(0xFFD39A52).withOpacity(0.6),
                  size: 18,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Descripción corta ──
          Text(
            leyenda.descripcionCorta,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 32),

          // ── Footer ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD39A52).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD39A52).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'Descarga la app para leer la leyenda completa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD39A52),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
