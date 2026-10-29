import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const _configuredTomoApiUrl = String.fromEnvironment('TOMO_API_BASE_URL');
String get defaultTomoApiUrl => _configuredTomoApiUrl.isNotEmpty
    ? _configuredTomoApiUrl
    : kIsWeb
        ? 'http://localhost:8080'
        : 'http://10.0.2.2:8080';

class TomoApiException implements Exception {
  const TomoApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class TomoApi {
  TomoApi(
      {required this.baseUrl, required this.username, required this.password});

  final String baseUrl;
  final String username;
  final String password;
  final http.Client _client = http.Client();

  Uri _uri(String path) {
    final root = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (root.isEmpty) {
      throw const TomoApiException('Enter the Tomo backend URL.');
    }
    return Uri.parse('$root/${path.replaceFirst(RegExp(r'^/+'), '')}');
  }

  Future<dynamic> _request(String method, String path, {Object? body}) async {
    try {
      final request = http.Request(method, _uri(path))
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] =
            'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      final streamed = await _client.send(request).timeout(
            const Duration(seconds: 15),
          );
      final response = await http.Response.fromStream(streamed).timeout(
        const Duration(seconds: 15),
      );
      final responseBody = response.body;
      dynamic decoded;
      if (responseBody.isNotEmpty) {
        try {
          decoded = jsonDecode(responseBody);
        } on FormatException {
          decoded = responseBody;
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? (decoded['message'] ?? decoded['detail'] ?? decoded['error'])
                ?.toString()
            : null;
        throw TomoApiException(
          message ?? _statusMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      return decoded;
    } on TimeoutException {
      throw TomoApiException(
          'Tomo took too long to respond. Check the backend URL and network.');
    } on http.ClientException {
      throw TomoApiException(
          'Can’t reach Tomo. Check that the backend is running and allows this app connection.');
    } on FormatException {
      throw const TomoApiException(
          'Tomo returned data the app could not read.');
    }
  }

  String _statusMessage(int status) => switch (status) {
        401 => 'Username or password is incorrect.',
        403 => 'This account can’t access Tomo.',
        404 => 'The Tomo API endpoint was not found.',
        500 => 'Tomo had a server error. Try again shortly.',
        _ => 'Tomo returned HTTP $status.',
      };

  Future<List<JobListing>> getJobs() async {
    final data = await _request('GET', 'jobs');
    if (data is! List) {
      throw const TomoApiException('The jobs response was not a list.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(JobListing.fromJson)
        .toList();
  }

  Future<List<TomoNotification>> getNotifications() async {
    final data = await _request('GET', 'notifications');
    if (data is! List) {
      throw const TomoApiException(
          'The notifications response was not a list.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(TomoNotification.fromJson)
        .toList();
  }

  Future<void> markNotificationRead(int id) async {
    await _request('PUT', 'notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _request('PUT', 'notifications/read-all');
  }

  Future<AssistantReply> sendAssistantMessage(
      String message, int? conversationId) async {
    final data = await _request('POST', 'rag/messages', body: {
      if (conversationId != null) 'conversationId': conversationId,
      'message': message,
      'knowledgeBaseIds': <int>[],
    });
    if (data is! Map<String, dynamic>) {
      throw const TomoApiException(
          'Tomo returned an invalid assistant response.');
    }
    return AssistantReply.fromJson(data);
  }

  void close() => _client.close();
}

class JobListing {
  const JobListing({
    required this.id,
    required this.title,
    required this.description,
    required this.skills,
    required this.payRange,
    required this.employmentType,
    required this.shift,
    required this.location,
    required this.isRemote,
    required this.applyLink,
    required this.postedOn,
    required this.employer,
    required this.employerLogo,
    required this.publisher,
  });

  final int id;
  final String title;
  final String description;
  final String skills;
  final String payRange;
  final String employmentType;
  final String shift;
  final String location;
  final bool isRemote;
  final String applyLink;
  final DateTime? postedOn;
  final String employer;
  final String employerLogo;
  final String publisher;

  factory JobListing.fromJson(Map<String, dynamic> json) => JobListing(
        id: _asInt(json['id']),
        title: _asString(json['jobTitle']),
        description: _asString(json['jobDesc']),
        skills: _asString(json['progLang']),
        payRange: _asString(json['payRange']),
        employmentType: _asString(json['employmentType']),
        shift: _asString(json['shiftSchedule']),
        location: _asString(json['location']),
        isRemote: json['isRemote'] == true || json['remote'] == true,
        applyLink: _asString(json['applyLink']),
        postedOn: DateTime.tryParse(_asString(json['postedOn']))?.toLocal(),
        employer: _asString(json['employerName'], fallback: 'Tomo employer'),
        employerLogo: _asString(json['employerLogo']),
        publisher: _asString(json['jobPublisher']),
      );
}

class TomoNotification {
  const TomoNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.relatedJobIds,
    required this.createdAt,
    required this.readAt,
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final List<int> relatedJobIds;
  final DateTime? createdAt;
  final DateTime? readAt;
  bool get isRead => readAt != null;

  factory TomoNotification.fromJson(Map<String, dynamic> json) =>
      TomoNotification(
        id: _asInt(json['id']),
        type: _asString(json['type'], fallback: 'UPDATE'),
        title: _asString(json['title'], fallback: 'Tomo update'),
        message: _asString(json['message']),
        relatedJobIds: (json['relatedJobIds'] as List? ?? const [])
            .map(_asInt)
            .toList(growable: false),
        createdAt: DateTime.tryParse(_asString(json['createdAt']))?.toLocal(),
        readAt: json['readAt'] == null
            ? null
            : DateTime.tryParse(_asString(json['readAt']))?.toLocal(),
      );

  TomoNotification markRead() => TomoNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        relatedJobIds: relatedJobIds,
        createdAt: createdAt,
        readAt: DateTime.now(),
      );
}

class AssistantReply {
  const AssistantReply(
      {required this.conversationId,
      required this.answer,
      required this.sources});
  final int conversationId;
  final String answer;
  final List<String> sources;

  factory AssistantReply.fromJson(Map<String, dynamic> json) => AssistantReply(
        conversationId: _asInt(json['conversationId']),
        answer: _asString(json['answer']),
        sources: (json['sources'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((source) => _asString(source['title'],
                fallback: _asString(source['sourceKey'])))
            .toList(growable: false),
      );
}

String _asString(Object? value, {String fallback = ''}) =>
    value?.toString() ?? fallback;
int _asInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
