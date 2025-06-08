class UploadRecordModel {
  final String status;
  final String transcription;
  final String filename;

  UploadRecordModel({
    required this.status,
    required this.transcription,
    required this.filename,
  });

  factory UploadRecordModel.fromJson(Map<String, dynamic> json) {
    return UploadRecordModel(
      status: json['status'] ?? '',
      transcription: json['transcription'] ?? '',
      filename: json['filename'] ?? '',
    );
  }
}
