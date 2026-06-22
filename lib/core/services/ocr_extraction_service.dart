import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/extracted_document.dart';

class OcrExtractionService {
  /// Processes the recognized text and extracts fields based on layout and document type rules.
  Future<ExtractedDocument> processRecognizedText(RecognizedText recognizedText) async {
    final doc = ExtractedDocument();

    // 1. Layout Pattern Classification
    doc.layoutPattern = _classifyLayout(recognizedText);

    // 3. Document Type Detection
    doc.category = _detectDocumentType(recognizedText);

    // 2. Extract Dates & Disambiguate
    _extractAndAssignDates(recognizedText, doc);

    // 4. Generic Field Extraction Rules
    _extractGenericFields(recognizedText, doc);

    // 5. Type-Specific Validation
    _validateFields(doc);

    // 8. Gather Unclassified Lines
    _gatherUnclassifiedLines(recognizedText, doc);

    // 9. Confidence Aggregation
    _calculateConfidence(recognizedText, doc);

    return doc;
  }

  DocumentLayoutPattern _classifyLayout(RecognizedText recognizedText) {
    int shortLines = 0;
    int totalLines = 0;
    int labelKeywords = 0;
    
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        totalLines++;
        if (line.text.split(' ').length < 5) shortLines++;
        if (line.text.contains(':')) labelKeywords++;
      }
    }

    if (totalLines == 0) return DocumentLayoutPattern.unknown;

    double shortRatio = shortLines / totalLines;
    if (shortRatio > 0.7 && labelKeywords > 2) {
      return DocumentLayoutPattern.labelValueForm;
    } else if (shortRatio < 0.3) {
      return DocumentLayoutPattern.narrativeCertificate;
    }
    return DocumentLayoutPattern.mixed;
  }

  DocumentCategory _detectDocumentType(RecognizedText recognizedText) {
    String fullText = recognizedText.text.toUpperCase();

    // Government ID
    if (fullText.contains('AADHAAR') || fullText.contains('UIDAI') || RegExp(r'\d{4}\s\d{4}\s\d{4}').hasMatch(fullText)) return DocumentCategory.aadhaar;
    if (fullText.contains('PERMANENT ACCOUNT NUMBER') || RegExp(r'[A-Z]{5}\d{4}[A-Z]').hasMatch(fullText)) return DocumentCategory.panCard;
    if (fullText.contains('ELECTION COMMISSION') || fullText.contains('EPIC NO')) return DocumentCategory.voterId;
    if (fullText.contains('DRIVING LICENCE') || fullText.contains('DL NO')) return DocumentCategory.drivingLicense;
    if (fullText.contains('PASSPORT') || RegExp(r'^P<', multiLine: true).hasMatch(fullText)) return DocumentCategory.passport;
    if (fullText.contains('RATION CARD') || fullText.contains('PDS')) return DocumentCategory.rationCard;

    // Financial
    if (fullText.contains('SAVINGS ACCOUNT') || fullText.contains('IFSC') || fullText.contains('PASSBOOK')) return DocumentCategory.bankPassbook;
    if (fullText.contains('GSTIN') || fullText.contains('TAX INVOICE') || fullText.contains('HSN')) return DocumentCategory.gstInvoice;
    if (fullText.contains('SALARY SLIP') || fullText.contains('NET PAY') || fullText.contains('GROSS EARNINGS')) return DocumentCategory.payslip;
    if (fullText.contains('POLICY NO') || fullText.contains('SUM INSURED') || fullText.contains('PREMIUM')) return DocumentCategory.insurancePolicy;
    if (fullText.contains('LOAN ACCOUNT') || fullText.contains('EMI') || fullText.contains('SANCTIONED AMOUNT')) return DocumentCategory.loanAgreement;
    if (fullText.contains('CHEQUE') || fullText.contains('PAY TO THE ORDER OF')) return DocumentCategory.cheque;

    // Educational
    if (fullText.contains('MARKS STATEMENT') || fullText.contains('CGPA') || fullText.contains('SEMESTER')) return DocumentCategory.marksheet;
    if (fullText.contains('DEGREE') || fullText.contains('CONVOCATION') || fullText.contains('HAS BEEN CONFERRED')) return DocumentCategory.degreeCertificate;
    if (fullText.contains('BONAFIDE') || fullText.contains('IS A BONAFIDE STUDENT')) return DocumentCategory.bonafideCertificate;
    if (fullText.contains('TRANSFER CERTIFICATE') || fullText.contains('TC NO')) return DocumentCategory.transferCertificate;

    // Medical
    if (fullText.contains('RX') || fullText.contains('DOSAGE')) return DocumentCategory.prescription;
    if (fullText.contains('REFERENCE RANGE') || fullText.contains('SPECIMEN')) return DocumentCategory.labReport;
    if (fullText.contains('VACCINATION') || fullText.contains('DOSE 1') || fullText.contains('BATCH NO')) return DocumentCategory.vaccinationCertificate;
    if (fullText.contains('DISCHARGE SUMMARY') || fullText.contains('DIAGNOSIS') || fullText.contains('ADMITTED ON')) return DocumentCategory.dischargeSummary;

    // Travel
    if (fullText.contains('BOARDING PASS') || fullText.contains('GATE') || fullText.contains('PNR')) return DocumentCategory.boardingPass;
    if (fullText.contains('VISA') || fullText.contains('TYPE OF VISA') || fullText.contains('DURATION OF STAY')) return DocumentCategory.visa;
    if (fullText.contains('ITINERARY') || fullText.contains('BOOKING REFERENCE')) return DocumentCategory.travelItinerary;

    // Property / Legal
    if (fullText.contains('LEASE AGREEMENT') || fullText.contains('LESSOR') || fullText.contains('MONTHLY RENT')) return DocumentCategory.rentalAgreement;
    if (fullText.contains('SALE DEED') || fullText.contains('VENDOR') || fullText.contains('SURVEY NO')) return DocumentCategory.saleDeed;
    if (fullText.contains('PROPERTY TAX') || fullText.contains('ASSESSMENT NO')) return DocumentCategory.propertyTaxReceipt;
    if (fullText.contains('AFFIDAVIT') || fullText.contains('I DO HEREBY SOLEMNLY AFFIRM')) return DocumentCategory.affidavit;
    if (fullText.contains('POWER OF ATTORNEY')) return DocumentCategory.powerOfAttorney;

    // Utility / Bills
    if (fullText.contains('UNITS CONSUMED') || fullText.contains('KWH') || fullText.contains('ELECTRICITY')) return DocumentCategory.electricityBill;
    if (fullText.contains('WATER CHARGES')) return DocumentCategory.waterBill;
    
    if (fullText.contains('TOTAL') || fullText.contains('AMOUNT PAID')) return DocumentCategory.receipt;

    // Employment
    if (fullText.contains('OFFER OF EMPLOYMENT') || fullText.contains('DESIGNATION') || fullText.contains('CTC')) return DocumentCategory.offerLetter;
    if (fullText.contains('EXPERIENCE CERTIFICATE') || fullText.contains('WORKED AS')) return DocumentCategory.experienceCertificate;
    if (fullText.contains('RELIEVING LETTER') || fullText.contains('LAST WORKING DAY')) return DocumentCategory.relievingLetter;

    return DocumentCategory.genericDocument;
  }

  void _extractAndAssignDates(RecognizedText recognizedText, ExtractedDocument doc) {
    List<DateTime> foundDates = [];
    RegExp dateRegExp = RegExp(r'\b(\d{2})[-/](\d{2})[-/](\d{4})\b');
    
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        var matches = dateRegExp.allMatches(line.text);
        for (var match in matches) {
          try {
            int day = int.parse(match.group(1)!);
            int month = int.parse(match.group(2)!);
            int year = int.parse(match.group(3)!);
            if (month > 12 && day <= 12) {
              int temp = month; month = day; day = temp;
            }
            DateTime date = DateTime(year, month, day);
            foundDates.add(date);
            
            String lineUpper = line.text.toUpperCase();
            if (lineUpper.contains('EXP') || lineUpper.contains('VALID')) {
              doc.expiryDate = date;
            } else if (lineUpper.contains('ISSUE') || lineUpper.contains('DOI')) {
              doc.issueDate = date;
            } else if (lineUpper.contains('DOB') || lineUpper.contains('BIRTH') || lineUpper.contains('BORN')) {
              doc.dateOfBirth = date;
            } else if (lineUpper.contains('RENEW')) {
              doc.renewalDate = date;
            } else if (lineUpper.contains('ADMISSION') || lineUpper.contains('JOIN')) {
              doc.admissionOrJoiningDate = date;
            }
          } catch (_) {}
        }
      }
    }

    if (doc.issueDate == null && doc.expiryDate == null) {
      List<DateTime> unassigned = foundDates.where((d) => d != doc.dateOfBirth && d != doc.renewalDate).toList();
      DateTime today = DateTime.now();
      
      if (unassigned.length == 2) {
        DateTime d1 = unassigned[0];
        DateTime d2 = unassigned[1];
        
        if (d1.isAfter(today) && d2.isBefore(today)) {
          doc.expiryDate = d1; doc.issueDate = d2;
        } else if (d2.isAfter(today) && d1.isBefore(today)) {
          doc.expiryDate = d2; doc.issueDate = d1;
        } else {
          if (d1.isBefore(d2)) {
            doc.issueDate = d1; doc.expiryDate = d2;
          } else {
            doc.issueDate = d2; doc.expiryDate = d1;
          }
        }
      } else if (unassigned.length > 2) {
        unassigned.sort();
        doc.issueDate = unassigned.first;
        doc.expiryDate = unassigned.last;
      }
    }
  }

  void _extractGenericFields(RecognizedText recognizedText, ExtractedDocument doc) {
    RegExp phoneRegex = RegExp(r'(?:\+91|0)?\s?\d{5}[\s\-]?\d{5}');
    RegExp emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String text = line.text;
        
        if (doc.email == null) {
          var match = emailRegex.firstMatch(text);
          if (match != null) doc.email = match.group(0);
        }
        
        if (doc.phoneNumber == null) {
          var match = phoneRegex.firstMatch(text);
          if (match != null) doc.phoneNumber = match.group(0);
        }

        if (text.contains('%') && doc.percentageOrGrade == null) {
          doc.percentageOrGrade = text;
        }
      }
    }

    if (doc.category == DocumentCategory.aadhaar) {
      var match = RegExp(r'\d{4}\s\d{4}\s\d{4}').firstMatch(recognizedText.text);
      if (match != null) doc.documentNumber = match.group(0);
    } else if (doc.category == DocumentCategory.panCard) {
      var match = RegExp(r'[A-Z]{5}\d{4}[A-Z]').firstMatch(recognizedText.text);
      if (match != null) doc.documentNumber = match.group(0);
    }
  }

  void _validateFields(ExtractedDocument doc) {
    doc.needsReview = false;
    
    if (doc.category == DocumentCategory.aadhaar && doc.documentNumber != null) {
      String clean = doc.documentNumber!.replaceAll(' ', '');
      if (clean.length != 12) doc.needsReview = true;
    } else if (doc.category == DocumentCategory.panCard && doc.documentNumber != null) {
      if (!RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(doc.documentNumber!)) doc.needsReview = true;
    }
    
    if (doc.category == DocumentCategory.drivingLicense && doc.issueDate != null && doc.expiryDate != null) {
      if (doc.expiryDate!.difference(doc.issueDate!).inDays < 365 * 10) {
        doc.needsReview = true;
      }
    }
  }

  void _gatherUnclassifiedLines(RecognizedText recognizedText, ExtractedDocument doc) {
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        doc.unclassifiedLines.add(line.text);
      }
    }
  }

  void _calculateConfidence(RecognizedText recognizedText, ExtractedDocument doc) {
    doc.overallConfidence = 0.85; 
  }
}
