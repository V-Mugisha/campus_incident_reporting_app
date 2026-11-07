import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:campus_incident_reporting_app/models/app_user.dart';
import 'package:campus_incident_reporting_app/models/incident.dart';
import 'package:campus_incident_reporting_app/models/incident_category.dart';
import 'package:campus_incident_reporting_app/models/user_role.dart';
import 'package:campus_incident_reporting_app/providers/incident_provider.dart';
import 'package:campus_incident_reporting_app/services/image_upload_service.dart';
import 'package:campus_incident_reporting_app/services/incident_service.dart';

class _FakeService implements IncidentService {
  String? updatedId;
  IncidentCategory? updatedCategory;
  String? updatedTitle;
  String? updatedDescription;
  String? updatedLocation;
  String? updatedImageUrl;
  String? deletedId;

  bool submitCalled = false;
  String? submittedImageUrl;

  @override
  Stream<List<Incident>> streamIncidents() => const Stream.empty();

  @override
  Stream<List<Incident>> watchMyIncidents(String uid) => const Stream.empty();

  @override
  Stream<Incident?> watchIncident(String id) => const Stream.empty();

  @override
  Future<void> submitIncident({
    required IncidentCategory category,
    required String title,
    required String description,
    required String reportedBy,
    required String reportedByName,
    String? location,
    String? imageUrl,
  }) async {
    submitCalled = true;
    submittedImageUrl = imageUrl;
  }

  @override
  Future<void> updateStatus({
    required String id,
    required IncidentStatus status,
    required String changedBy,
  }) async {}

  @override
  Future<void> updateIncident({
    required String id,
    required IncidentCategory category,
    required String title,
    required String description,
    String? location,
    String? imageUrl,
  }) async {
    updatedId = id;
    updatedCategory = category;
    updatedTitle = title;
    updatedDescription = description;
    updatedLocation = location;
    updatedImageUrl = imageUrl;
  }

  @override
  Future<void> deleteIncident(String id) async {
    deletedId = id;
  }
}

class _FakeImageUploader implements ImageUploadService {
  final String url = 'https://res.cloudinary.com/demo/image.png';

  String? uploadedPath;

  @override
  Future<String> upload(File file) async {
    uploadedPath = file.path;
    return url;
  }
}

class _FailingImageUploader implements ImageUploadService {
  @override
  Future<String> upload(File file) async => throw Exception('upload failed');
}

const _reporter = AppUser(
  id: 'student-1',
  name: 'Test Student',
  email: 'm.victor@alustudent.com',
  role: UserRole.student,
);

void main() {
  test('updateIncident delegates to the service', () async {
    final service = _FakeService();
    final provider = IncidentProvider(service: service);

    final ok = await provider.updateIncident(
      id: 'inc1',
      category: IncidentCategory.water,
      title: 'Leaky tap',
      description: 'Water is dripping in Block B.',
      location: 'Library',
    );

    expect(ok, isTrue);
    expect(service.updatedId, 'inc1');
    expect(service.updatedCategory, IncidentCategory.water);
    expect(service.updatedTitle, 'Leaky tap');
    expect(service.updatedDescription, 'Water is dripping in Block B.');
    expect(service.updatedLocation, 'Library');
  });

  test('deleteIncident delegates to the service', () async {
    final service = _FakeService();
    final provider = IncidentProvider(service: service);

    final ok = await provider.deleteIncident('inc2');

    expect(ok, isTrue);
    expect(service.deletedId, 'inc2');
  });

  test('submitIncident uploads a photo and passes the URL', () async {
    final service = _FakeService();
    final uploader = _FakeImageUploader();
    final provider =
        IncidentProvider(service: service, imageUploader: uploader);

    final ok = await provider.submitIncident(
      category: IncidentCategory.safety,
      title: 'Broken light',
      description: 'The light is broken.',
      reporter: _reporter,
      photo: File('/tmp/photo.jpg'),
    );

    expect(ok, isTrue);
    expect(uploader.uploadedPath, '/tmp/photo.jpg');
    expect(service.submittedImageUrl, uploader.url);
  });

  test('updateIncident uploads a replacement photo', () async {
    final service = _FakeService();
    final uploader = _FakeImageUploader();
    final provider =
        IncidentProvider(service: service, imageUploader: uploader);

    final ok = await provider.updateIncident(
      id: 'inc3',
      category: IncidentCategory.water,
      title: 'Leaky tap',
      description: 'Still leaking.',
      currentImageUrl: 'https://old/image.png',
      photo: File('/tmp/new.jpg'),
    );

    expect(ok, isTrue);
    expect(uploader.uploadedPath, '/tmp/new.jpg');
    expect(service.updatedImageUrl, uploader.url);
  });

  test('updateIncident keeps the current image when no new photo', () async {
    final service = _FakeService();
    final uploader = _FakeImageUploader();
    final provider =
        IncidentProvider(service: service, imageUploader: uploader);

    await provider.updateIncident(
      id: 'inc4',
      category: IncidentCategory.water,
      title: 'Leaky tap',
      description: 'Still leaking.',
      currentImageUrl: 'https://old/image.png',
    );

    expect(uploader.uploadedPath, isNull);
    expect(service.updatedImageUrl, 'https://old/image.png');
  });

  test('submitIncident fails without submitting when the upload fails',
      () async {
    final service = _FakeService();
    final provider = IncidentProvider(
      service: service,
      imageUploader: _FailingImageUploader(),
    );

    final ok = await provider.submitIncident(
      category: IncidentCategory.safety,
      title: 'Broken light',
      description: 'The light is broken.',
      reporter: _reporter,
      photo: File('/tmp/photo.jpg'),
    );

    expect(ok, isFalse);
    expect(service.submitCalled, isFalse);
    expect(
      provider.submitError,
      "Couldn't upload your photo. Please try again.",
    );
  });
}
