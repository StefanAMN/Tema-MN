#!/usr/bin/env python3
"""
scripts/generate_pdf.py
Generates docs/Tema_Restaurarea_Inscriptiilor_Oracol.pdf in the visual and editorial style of Homework.pdf:
- Uses LiberationSerif TrueType font with full UTF-8 Romanian diacritic support (ă, î, ș, ț, â)
- Clean academic LaTeX-style typography
- No narrative introduction (straight to technical specifications, tasks, datasets, scoring, and strict anti-built-in constraints)
"""

import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# Register TrueType Liberation fonts for perfect Romanian diacritics
FONT_DIR = "/usr/share/fonts/truetype/liberation"
pdfmetrics.registerFont(TTFont('LibSerif', os.path.join(FONT_DIR, 'LiberationSerif-Regular.ttf')))
pdfmetrics.registerFont(TTFont('LibSerif-Bold', os.path.join(FONT_DIR, 'LiberationSerif-Bold.ttf')))
pdfmetrics.registerFont(TTFont('LibSerif-Italic', os.path.join(FONT_DIR, 'LiberationSerif-Italic.ttf')))
pdfmetrics.registerFont(TTFont('LibSerif-BoldItalic', os.path.join(FONT_DIR, 'LiberationSerif-BoldItalic.ttf')))
pdfmetrics.registerFont(TTFont('LibMono', os.path.join(FONT_DIR, 'LiberationMono-Regular.ttf')))

DOCS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "docs"))
PDF_PATH = os.path.join(DOCS_DIR, "Tema_Restaurarea_Inscriptiilor_Oracol.pdf")

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        self.setFont("LibSerif", 9)
        self.setFillColor(colors.HexColor("#333333"))

        # Header (pages > 1)
        if self._pageNumber > 1:
            self.drawString(54, 11 * inch - 36, "METODE NUMERICE — RESTAURAREA & CLASIFICAREA INSCRIPȚIILOR ORACOL")
            self.setStrokeColor(colors.HexColor("#cccccc"))
            self.setLineWidth(0.5)
            self.line(54, 11 * inch - 42, 8.5 * inch - 54, 11 * inch - 42)

        # Footer (all pages)
        page_text = f"{self._pageNumber}"
        self.drawCentredString(8.5 * inch / 2.0, 36, page_text)
        self.restoreState()

def build_pdf():
    os.makedirs(DOCS_DIR, exist_ok=True)
    doc = SimpleDocTemplate(
        PDF_PATH,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Custom styles using Liberation Serif
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='LibSerif-Bold',
        fontSize=20,
        leading=24,
        alignment=1, # Center
        spaceAfter=6
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='LibSerif',
        fontSize=13,
        leading=16,
        alignment=1,
        spaceAfter=4
    )

    version_style = ParagraphStyle(
        'DocVersion',
        parent=styles['Normal'],
        fontName='LibSerif-Italic',
        fontSize=10,
        leading=12,
        alignment=1,
        spaceAfter=16
    )

    header_tag_style = ParagraphStyle(
        'HeaderTag',
        parent=styles['Normal'],
        fontName='LibSerif',
        fontSize=11,
        leading=14,
        alignment=1,
        spaceAfter=8
    )

    h1_style = ParagraphStyle(
        'CustomH1',
        parent=styles['Normal'],
        fontName='LibSerif-Bold',
        fontSize=13,
        leading=17,
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'CustomH2',
        parent=styles['Normal'],
        fontName='LibSerif-Bold',
        fontSize=11,
        leading=15,
        spaceBefore=8,
        spaceAfter=4,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['Normal'],
        fontName='LibSerif',
        fontSize=9.5,
        leading=13.5,
        spaceAfter=5,
        alignment=4 # Justified
    )

    bullet_style = ParagraphStyle(
        'CustomBullet',
        parent=styles['Normal'],
        fontName='LibSerif',
        fontSize=9.5,
        leading=13.5,
        leftIndent=12,
        spaceAfter=4
    )

    table_header_style = ParagraphStyle(
        'TableHeader',
        parent=styles['Normal'],
        fontName='LibSerif-Bold',
        fontSize=9,
        leading=11,
        alignment=1
    )

    table_cell_style = ParagraphStyle(
        'TableCell',
        parent=styles['Normal'],
        fontName='LibSerif',
        fontSize=8.5,
        leading=11.5,
        alignment=0
    )

    table_cell_center = ParagraphStyle(
        'TableCellCenter',
        parent=styles['Normal'],
        fontName='LibSerif',
        fontSize=8.5,
        leading=11.5,
        alignment=1
    )

    story = []

    # Title Block
    story.append(Paragraph("METODE NUMERICE", header_tag_style))
    story.append(Paragraph("Restaurarea și Clasificarea Inscripțiilor Oracol", title_style))
    story.append(Paragraph("Proiect Practic | Enunț al Problemei & Specificație Tehnică", subtitle_style))
    story.append(Paragraph("Versiunea 2.0 — Bază de Date Reală & Clasificare pe Tiers", version_style))
    story.append(Spacer(1, 6))

    # Table of Contents
    story.append(Paragraph("<b>Cuprins</b>", h2_style))
    toc_data = [
        [Paragraph("<b>1</b>", table_cell_center), Paragraph("<b>Configurația Problemei & Date de Intrare</b>", table_cell_style), Paragraph("<b>1</b>", table_cell_center)],
        [Paragraph("<b>2</b>", table_cell_center), Paragraph("<b>Task 1: Filtrarea Frecvențelor Spațiale (Fourier 2D) — 30p</b>", table_cell_style), Paragraph("<b>1</b>", table_cell_center)],
        [Paragraph("<b>3</b>", table_cell_center), Paragraph("<b>Task 2: Decuplarea Caracteristicilor (Wavelet Haar 2D) — 20p</b>", table_cell_style), Paragraph("<b>2</b>", table_cell_center)],
        [Paragraph("<b>4</b>", table_cell_center), Paragraph("<b>Task 3: Extragerea Asimetrică & Gradientul Direcțional — 20p</b>", table_cell_style), Paragraph("<b>2</b>", table_cell_center)],
        [Paragraph("<b>5</b>", table_cell_center), Paragraph("<b>Task 4: SVD, Hashing Binar & Clasificare Hamming — 20p</b>", table_cell_style), Paragraph("<b>2</b>", table_cell_center)],
        [Paragraph("<b>6</b>", table_cell_center), Paragraph("<b>Structura Testelor & Setul de Date (Practice vs Competition)</b>", table_cell_style), Paragraph("<b>3</b>", table_cell_center)],
        [Paragraph("<b>7</b>", table_cell_center), Paragraph("<b>Evaluare, Bareme & Punctaj</b>", table_cell_style), Paragraph("<b>3</b>", table_cell_center)],
        [Paragraph("<b>8</b>", table_cell_center), Paragraph("<b>Constrângeri Tehnice & Reguli Stricte (STRICT INTERZIS)</b>", table_cell_style), Paragraph("<b>3</b>", table_cell_center)],
        [Paragraph("<b>9</b>", table_cell_center), Paragraph("<b>Instrucțiuni de Trimitere & Makefile</b>", table_cell_style), Paragraph("<b>3</b>", table_cell_center)],
    ]
    t_toc = Table(toc_data, colWidths=[25, 430, 45])
    t_toc.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1.5),
        ('TOPPADDING', (0,0), (-1,-1), 1.5),
        ('LINEBELOW', (0,-1), (-1,-1), 0.5, colors.HexColor("#dddddd")),
    ]))
    story.append(t_toc)
    story.append(Spacer(1, 10))

    # Section 1: Configurația Problemei & Date de Intrare
    story.append(Paragraph("1 Configurația Problemei & Date de Intrare", h1_style))
    story.append(Paragraph(
        "Fiecare test furnizează o matrice pătratică <b>A &isin; &#8477;<sup>N &times; N</sup></b> (cu <i>N = 64</i>), "
        "reprezentând intensitatea pixelilor normalizată în intervalul [0, 1] dintr-o imagine degradată a unui caracter antic oracol "
        "(dinastia Shang, datasetul Oracle-MNIST). Suplimentar, este disponibil un dicționar de referință <code>data/known_symbols/</code> "
        "conținând <b>C = 10</b> simboluri prototip reale.", body_style
    ))
    story.append(Paragraph(
        "<b>Obiectivul:</b> Implementarea unui flux numeric complet de procesare a semnalului pentru extragerea trăsăturilor geometrice invariante "
        "și clasificarea imaginii în una dintre cele <i>C = 10</i> clase prin distanță Hamming minimă.", body_style
    ))
    story.append(Paragraph(
        "<b>Parametri globali:</b> Dimensiunea imaginii <i>N = 64</i>, dimensiunea spațiului de trăsături / hash <i>K = N / 2 = 32</i>, "
        "numărul de clase de caractere <i>C = 10</i>.", body_style
    ))
    story.append(Spacer(1, 8))

    # Section 2: Task 1
    story.append(Paragraph("2 Task 1: Filtrarea Frecvențelor Spațiale (Fourier 2D) [30 puncte]", h1_style))
    story.append(Paragraph(
        "Pentru a elimina zgomotul de înaltă frecvență cauzat de porozitatea osului și degradarea fizică, imaginea este mapată în domeniul frecvenței "
        "folosind Transformata Fourier Discretă 2D (DFT 2D).", body_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 1.1 (10p) — Construcția matricei Fourier 2D:</b><br/>"
        "Construiți matricea exponențialelor complexe <b>F &isin; &#8450;<sup>N &times; N</sup></b> conform formulei:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>F<sub>m,n</sub> = exp(&minus;2&pi;i &middot; m &middot; n / N)</b>, &nbsp;&nbsp; pentru <i>m, n &isin; {0, 1, ..., N&minus;1}</i>.<br/>"
        "Calculați spectrul bidimensional al imaginii prin transformarea matriceală: <b>X = F &middot; A &middot; F</b>.", bullet_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 1.2 (10p) — Masca binară trece-jos (Low-Pass Filter):</b><br/>"
        "Generați o mască binară <b>M &isin; &#8477;<sup>N &times; N</sup></b> astfel încât elementele din submatricea centrală de dimensiune "
        "<i>(N/2) &times; (N/2)</i> (adică liniile și coloanele din intervalul <i>N/4 + 1 : 3N/4</i>) să fie <b>1</b>, iar restul <b>0</b>.<br/>"
        "Aplicați filtrarea spectrală prin produsul Hadamard: <b>X<sub>f</sub> = X &compfn; M</b>.", bullet_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 1.3 (10p) — Reconstrucția imaginii filtrate:</b><br/>"
        "Reconstruiți imaginea spațială filtrată <b>&Atilde; &isin; &#8477;<sup>N &times; N</sup></b> aplicând transformata inversă 2D:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&Atilde; = Re( F<sup>&minus;1</sup> &middot; X<sub>f</sub> &middot; F<sup>&minus;1</sup> )</b>, &nbsp;&nbsp; unde <b>F<sup>&minus;1</sup> = (1 / N) &middot; F<sup>*</sup></b> (conjugata hermitică).", bullet_style
    ))
    story.append(Spacer(1, 8))

    # Section 3: Task 2
    story.append(Paragraph("3 Task 2: Decuplarea Caracteristicilor (Wavelet Haar 2D) [20 puncte]", h1_style))
    story.append(Paragraph(
        "Pentru a decupla componentele direcționale ale trăsăturilor (linii orizontale vs verticale), se aplică Transformata Wavelet Discretă 2D "
        "(DWT 2D) utilizând baza ortonormată Haar.", body_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 2.1 (10p) — Construcția operatorului Haar:</b><br/>"
        "Construiți matricea ortogonală Haar <b>H &isin; &#8477;<sup>N &times; N</sup></b> definită pe blocuri:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pentru <i>i = 1, ..., K</i> (cu <i>K = N/2</i>):<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;H(i, 2i&minus;1) = 1/&radic;2, &nbsp;&nbsp; H(i, 2i) = 1/&radic;2<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;H(K+i, 2i&minus;1) = 1/&radic;2, &nbsp;&nbsp; H(K+i, 2i) = &minus;1/&radic;2<br/>"
        "Calculați coeficienții Wavelet 2D prin transformarea: <b>W = H &middot; &Atilde; &middot; H<sup>T</sup></b>.", bullet_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 2.2 (10p) — Extragerea subbenzilor direcționale:</b><br/>"
        "Extrageți din matricea <b>W</b> cele două submatrice de dimensiune <i>K &times; K</i>:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. <b>W<sub>LH</sub></b> (cadranul superior-dreapta, <i>linii 1:K, coloane K+1:N</i>) &mdash; variații orizontale.<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. <b>W<sub>HL</sub></b> (cadranul inferior-stânga, <i>linii K+1:N, coloane 1:K</i>) &mdash; variații verticale.", bullet_style
    ))
    story.append(Spacer(1, 8))

    # Section 4: Task 3
    story.append(Paragraph("4 Task 3: Extragerea Asimetrică & Gradientul Direcțional [20 puncte]", h1_style))
    story.append(Paragraph(
        "Deoarece trăsăturile caligrafice oracol prezintă anizotropie puternică, aplicăm diferențierea numerică asimetrică folosind scriptul de laborator <code>Dif.m</code>.", body_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 3.1 (10p) — Derivare numerică direcțională:</b><br/>"
        "Calculați derivata numerică de ordinul 1 pe fiecare linie a matricei <b>W<sub>LH</sub></b> pentru a obține componenta orizontală <b>G<sub>x</sub> &isin; &#8477;<sup>K &times; K</sup></b>, "
        "și pe fiecare coloană a matricei <b>W<sub>HL</sub></b> pentru a obține componenta verticală <b>G<sub>y</sub> &isin; &#8477;<sup>K &times; K</sup></b>.<br/>"
        "<i>Se va utiliza schema cu diferențe finite centrate la interior și diferențe unilaterale la capete (conform Dif.m).</i>", bullet_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 3.2 (10p) — Magnitudinea gradientului trăsăturilor:</b><br/>"
        "Sintetizați harta bidimensională a trăsăturilor calculând magnitudinea euclidiană element cu element:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>S = &radic;( G<sub>x</sub><sup>2</sup> + G<sub>y</sub><sup>2</sup> ) &isin; &#8477;<sup>K &times; K</sup></b>.", bullet_style
    ))
    story.append(Spacer(1, 8))

    # Section 5: Task 4
    story.append(Paragraph("5 Task 4: SVD, Hashing Binar & Clasificare Hamming [20 puncte]", h1_style))
    story.append(Paragraph(
        "Comprimați matricea <b>S</b> într-o amprentă binară compactă și clasificați caracterul prin distanță Hamming minimă față de dicționar.", body_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 4.1 (10p) — Descompunerea în Valori Singulare (SVD):</b><br/>"
        "Efectuați descompunerea SVD a matricei trăsăturilor: <b>S = U &middot; &Sigma; &middot; V<sup>T</sup></b> folosind algoritmul numeric dezvoltat la laborator (<code>SVD.m</code>). "
        "Extrageți diagonala principală a matricei <b>&Sigma;</b> pentru a forma vectorul valorilor singulare <b>v &isin; &#8477;<sup>K</sup></b>.", bullet_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 4.2 (5p) — Binarizare și Hashing:</b><br/>"
        "Calculați media valorilor singulare <b>&mu; = mean(v)</b>. Generați codul binar de hash <b>b &isin; {&minus;1, +1}<sup>K</sup></b> aplicând funcția semn:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>b<sub>i</sub> = sign(v<sub>i</sub> &minus; &mu;)</b>, &nbsp;&nbsp; (unde sign(0) este mapat la +1).", bullet_style
    ))
    story.append(Paragraph(
        "• <b>Subtask 4.3 (5p) — Clasificare prin Distanță Hamming Minimă:</b><br/>"
        "Având la dispoziție matricea <b>known_hashes &isin; {&minus;1, +1}<sup>K &times; C</sup></b> (conținând codurile de hash ale celor <i>C = 10</i> simboluri cunoscute), "
        "calculați distanța Hamming față de fiecare coloană <i>c &isin; {1, ..., C}</i>:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>d<sub>c</sub> = &sum;<sub>i=1..K</sub> [ b<sub>i</sub> &ne; known_hashes(i, c) ]</b>.<br/>"
        "Identificați clasa prezisă: <b>predicted_class = argmin<sub>c</sub> (d<sub>c</sub>)</b> și distanța minimă asociată <b>min_dist = min(d)</b>.", bullet_style
    ))
    story.append(Spacer(1, 10))

    # Section 6: Structura Testelor & Setul de Date
    story.append(Paragraph("6 Structura Testelor & Setul de Date", h1_style))
    story.append(Paragraph(
        "Evaluarea temei folosește două seturi de date distincte pentru a măsura robustețea numerică și a preveni supra-optimizarea (hardcodarea):", body_style
    ))

    tier_data = [
        [Paragraph("<b>Set / Tier</b>", table_header_style), Paragraph("<b>Nr. Imagini</b>", table_header_style), Paragraph("<b>Tip Zgomot / Degradare</b>", table_header_style), Paragraph("<b>Scop Evaluare</b>", table_header_style)],
        [Paragraph("<b>Practice — Tier 1</b>", table_cell_style), Paragraph("10", table_cell_center), Paragraph("Contrast optim, zgomot minim", table_cell_style), Paragraph("Validare de bază algoritmi", table_cell_style)],
        [Paragraph("<b>Practice — Tier 2</b>", table_cell_style), Paragraph("10", table_cell_center), Paragraph("Textură de piatră & porozitate", table_cell_style), Paragraph("Sensibilitate la variații de tuș", table_cell_style)],
        [Paragraph("<b>Practice — Tier 3</b>", table_cell_style), Paragraph("10", table_cell_center), Paragraph("Zgomot speckle & micro-eroziune", table_cell_style), Paragraph("Eficiență Fourier & Wavelet", table_cell_style)],
        [Paragraph("<b>Competition (Secret)</b>", table_cell_style), Paragraph("40", table_cell_center), Paragraph("4 Tiers (inclusiv Extra-Hard)", table_cell_style), Paragraph("Evaluare oficială anti-hardcodare", table_cell_style)],
    ]
    t_tier = Table(tier_data, colWidths=[110, 60, 180, 150])
    t_tier.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f0f0f0")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cccccc")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_tier)
    story.append(Spacer(1, 10))

    # Section 7: Evaluare și Punctaj
    story.append(Paragraph("7 Evaluare și Punctaj", h1_style))
    story.append(Paragraph(
        "Punctajul maxim total este de <b>100 puncte</b>, distribuit astfel:", body_style
    ))

    score_data = [
        [Paragraph("<b>Componentă</b>", table_header_style), Paragraph("<b>Punctaj</b>", table_header_style), Paragraph("<b>Criterii de Validare</b>", table_header_style)],
        [Paragraph("<b>Task 1 (Fourier 2D)</b>", table_cell_style), Paragraph("30 puncte", table_cell_center), Paragraph("Matrice F (10p), Mască M & X_f (10p), Reconstrucție A_tilde (10p)", table_cell_style)],
        [Paragraph("<b>Task 2 (Wavelet Haar)</b>", table_cell_style), Paragraph("20 puncte", table_cell_center), Paragraph("Matrice Haar H & W (10p), Subbenzi W_LH & W_HL (10p)", table_cell_style)],
        [Paragraph("<b>Task 3 (Derivare Numerică)</b>", table_cell_style), Paragraph("20 puncte", table_cell_center), Paragraph("Gradienți G_x & G_y (10p), Magnitudine S (10p)", table_cell_style)],
        [Paragraph("<b>Task 4 (SVD & Clasificare)</b>", table_cell_style), Paragraph("20 puncte", table_cell_center), Paragraph("Valori singulare v (10p), Hash b (5p), Clasificare Hamming (5p)", table_cell_style)],
        [Paragraph("<b>Coding Style & README</b>", table_cell_style), Paragraph("10 puncte", table_cell_center), Paragraph("Comentarii clare, cod vectorizat, structură modulară", table_cell_style)],
        [Paragraph("<b>TOTAL</b>", table_header_style), Paragraph("<b>100 puncte</b>", table_header_style), Paragraph("<b>90p Parțial (Checker) + 10p Stil / Barem Manual</b>", table_header_style)],
    ]
    t_score = Table(score_data, colWidths=[130, 80, 290])
    t_score.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor("#f0f0f0")),
        ('BACKGROUND', (0,-1), (-1,-1), colors.HexColor("#e8f0fe")),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cccccc")),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_score)
    story.append(Spacer(1, 10))

    # Section 8: Constrângeri Tehnice & Reguli Stricte
    story.append(Paragraph("8 Constrângeri Tehnice & Reguli Stricte (STRICT INTERZIS)", h1_style))
    story.append(Paragraph(
        "Scopul temei este aprofundarea algoritmilor numerici la nivel de bază. Utilizarea funcțiilor built-in automate de nivel înalt "
        "anulează valoarea pedagogică și este <b>STRICT INTERZISĂ</b> în soluțiile submise.", body_style
    ))
    story.append(Paragraph(
        "<b>Sunt STRICT INTERZISE în fișierele din <code>src/</code>:</b><br/>"
        "• <b>Descompuneri spectrale și factorizări built-in:</b> <code>svd</code>, <code>svds</code>, <code>eig</code>, <code>eigs</code>, <code>schur</code>.<br/>"
        "• <b>Transformate Fourier și Wavelet automate:</b> <code>fft</code>, <code>fft2</code>, <code>fftn</code>, <code>ifft</code>, <code>ifft2</code>, <code>dwt</code>, <code>dwt2</code>, <code>idwt2</code>, <code>wavedec2</code>.<br/>"
        "• <b>Derivare și convoluție automată:</b> <code>diff</code>, <code>gradient</code>, <code>conv</code>, <code>conv2</code>, <code>filter2</code>, <code>imfilter</code>, <code>edge</code>.<br/>"
        "• <b>Toolbox-uri specializate:</b> Image Processing Toolbox, Signal Processing Toolbox, Wavelet Toolbox, Statistics / Machine Learning Toolbox.<br/>"
        "• <b>Solvatori de sisteme pe matrici mari:</b> <code>inv</code>, <code>pinv</code> (este permisă doar inversarea explicită cu formula <i>F<sup>&minus;1</sup> = (1/N) &middot; F<sup>*</sup></i>).",
        bullet_style
    ))
    story.append(Paragraph(
        "<b>Sunt PERMISE și RECOMANDATE:</b><br/>"
        "• Operații aritmetice matriceale primitive: multiplicare (<code>*</code>), produs pe elemente (<code>.*</code>), transpunere (<code>'</code>, <code>.'</code>), conjugare (<code>conj</code>), norme (<code>norm</code>), sume (<code>sum</code>), rădăcină (<code>sqrt</code>), funcții trigonometrice/exponențiale (<code>exp</code>, <code>sin</code>, <code>cos</code>).<br/>"
        "• Reutilizarea algoritmilor dezvoltați la laboratoare: <code>Dif.m</code> (Laborator 10) și <code>SVD.m</code> (Laborator 7).",
        bullet_style
    ))
    story.append(Spacer(1, 10))

    # Section 9: Instrucțiuni de Trimitere
    story.append(Paragraph("9 Instrucțiuni de Trimitere & Makefile", h1_style))
    story.append(Paragraph(
        "Pentru a asigura o testare și o livrare fără erori, folosiți comenzile definite în <code>Makefile</code>:", body_style
    ))
    story.append(Paragraph(
        "• <code>make check</code> &mdash; Rulează checker-ul automat în Octave pe setul de practică (<code>data/practice</code>).<br/>"
        "• <code>make docker-check</code> &mdash; Construiește containerul Docker izolat și execută suita completă de teste.<br/>"
        "• <code>make submit</code> &mdash; Împachetează exclusiv fișierele sursă cerute din <code>src/</code> în arhiva <code>submission.zip</code>.<br/>"
        "• <code>make clean</code> &mdash; Șterge fișierele și arhivele temporare generate.",
        bullet_style
    ))
    story.append(Paragraph(
        "<b>Atenție:</b> Arhiva <code>submission.zip</code> va fi evaluată automat pe un mediu curat Linux Octave peste datasetul secret <code>data/competition/</code>. "
        "Asigurați-vă că soluția voastră rulează fără erori și respectă semnăturile funcțiilor cerute!", body_style
    ))

    # Build Document
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Generated PDF documentation successfully at {PDF_PATH}")

if __name__ == "__main__":
    build_pdf()
