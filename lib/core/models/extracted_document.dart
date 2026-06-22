import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

enum DocumentLayoutPattern {
  labelValueForm,
  tableStatement,
  narrativeCertificate,
  mixed,
  unknown,
}

enum DocumentCategory {
  aadhaar,
  panCard,
  voterId,
  drivingLicense,
  passport,
  rationCard,
  bankPassbook,
  gstInvoice,
  payslip,
  insurancePolicy,
  loanAgreement,
  cheque,
  marksheet,
  degreeCertificate,
  bonafideCertificate,
  transferCertificate,
  prescription,
  labReport,
  vaccinationCertificate,
  dischargeSummary,
  boardingPass,
  visa,
  travelItinerary,
  rentalAgreement,
  saleDeed,
  propertyTaxReceipt,
  affidavit,
  powerOfAttorney,
  electricityBill,
  waterBill,
  receipt,
  offerLetter,
  experienceCertificate,
  relievingLetter,
  genericDocument,
}

class ExtractedDocument {
  DocumentLayoutPattern layoutPattern;
  DocumentCategory category;
  
  DateTime? issueDate;
  DateTime? expiryDate;
  DateTime? dateOfBirth;
  DateTime? renewalDate;
  DateTime? admissionOrJoiningDate;
  DateTime? collectionDate;
  List<DateTime> otherDates;

  String? name;
  String? relativeName;
  String? documentNumber;
  String? address;
  String? bloodGroup;
  double? amount;
  String? phoneNumber;
  String? email;
  String? percentageOrGrade;
  
  bool hasSignature;
  bool needsReview;
  double overallConfidence;

  List<String> unclassifiedLines;
  
  ExtractedDocument({
    this.layoutPattern = DocumentLayoutPattern.unknown,
    this.category = DocumentCategory.genericDocument,
    this.issueDate,
    this.expiryDate,
    this.dateOfBirth,
    this.renewalDate,
    this.admissionOrJoiningDate,
    this.collectionDate,
    this.otherDates = const [],
    this.name,
    this.relativeName,
    this.documentNumber,
    this.address,
    this.bloodGroup,
    this.amount,
    this.phoneNumber,
    this.email,
    this.percentageOrGrade,
    this.hasSignature = false,
    this.needsReview = false,
    this.overallConfidence = 0.0,
    this.unclassifiedLines = const [],
  });

  @override
  String toString() {
    return 'ExtractedDocument(category: $category, documentNumber: $documentNumber, name: $name, issueDate: $issueDate, expiryDate: $expiryDate)';
  }
}
