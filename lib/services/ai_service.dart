import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService._();
  static final instance = AiService._();

  static const Duration _healthTimeout = Duration(seconds: 5);
  static const Duration _chatTimeout = Duration(seconds: 60);

  static const String _defaultPort = '8000';
  static const String _chatPath = '/api/llm';
  static const String _healthPath = '/health';

  String? _cachedBaseUrl;

  String get baseUrl => _cachedBaseUrl ??= _resolveBaseUrl();

  Uri get chatUri => Uri.parse('$baseUrl$_chatPath');
  Uri get healthUri => Uri.parse('$baseUrl$_healthPath');

  String _resolveBaseUrl() {
    
    final fromEnv = dotenv.env['AI_BASE_URL']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return _normalizeBaseUrl(fromEnv);
    }

    
    if (kIsWeb) {
      return _normalizeBaseUrl('http://localhost:$_defaultPort');
    }

    
    final p = defaultTargetPlatform;

    
    if (p == TargetPlatform.android) {
      return _normalizeBaseUrl('http://10.0.2.2:$_defaultPort');
    }

    
    return _normalizeBaseUrl('http://127.0.0.1:$_defaultPort');
  }

  String _normalizeBaseUrl(String raw) {
    final s = raw.trim();

    
    final withScheme = s.startsWith('http://') || s.startsWith('https://')
        ? s
        : 'http://$s';

    
    return withScheme.endsWith('/')
        ? withScheme.substring(0, withScheme.length - 1)
        : withScheme;
  }

  Future<bool> checkHealth() async {
    try {
      final res = await http.get(healthUri).timeout(_healthTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  
  
  
  
  
  Future<String> sendMessage(
    String prompt, {
    String? requestId,
    Map<String, dynamic>? extra,
  }) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      throw const AiServiceException('Prompt is empty');
    }

    final payload = <String, dynamic>{
      'text': trimmed,
      if (requestId != null) 'request_id': requestId,
      if (extra != null) ...extra,
    };

    try {
      final res = await http
          .post(
            chatUri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_chatTimeout);

      if (res.statusCode != 200) {
        throw AiServiceException(
          'Backend error (${res.statusCode})',
          details: _safeBody(res.body),
        );
      }

      final decoded = _decodeJson(res.body);

      
      final text = (decoded['text'] ??
              decoded['message'] ??
              decoded['output'] ??
              decoded['response'])
          ?.toString()
          .trim();

      if (text == null || text.isEmpty) {
        throw AiServiceException(
          'Empty AI response',
          details: _safeBody(res.body),
        );
      }

      return text;
    } on http.ClientException catch (e) {
      throw AiServiceException(
        'Cannot reach server',
        details: 'Base URL: $baseUrl\n$e',
      );
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException('Unexpected AI error', details: e.toString());
    }
  }

  Map<String, dynamic> _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('JSON root is not an object');
    } on FormatException {
      throw AiServiceException('Invalid response format', details: _safeBody(body));
    }
  }

  String _safeBody(String body) {
    
    final b = body.trim();
    if (b.length <= 1200) return b;
    return '${b.substring(0, 1200)}…';
  }
}

class AiServiceException implements Exception {
  final String message;
  final String? details;

  const AiServiceException(this.message, {this.details});

  @override
  String toString() => details == null ? message : '$message\n$details';
}