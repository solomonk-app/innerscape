import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('GEMINI_API_KEY environment variable is required');
    exit(1);
  }

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  const geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final router = Router();

  router.post('/api/gemini', (Request request) async {
    try {
      final body = await request.readAsString();

      final geminiResponse = await http.post(
        Uri.parse('$geminiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      return Response(
        geminiResponse.statusCode,
        body: geminiResponse.body,
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Proxy error: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Serve Flutter web static files
  final staticHandler = createStaticHandler(
    'build/web',
    defaultDocument: 'index.html',
  );

  // Cascade: try API routes first, then static files
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(
        Cascade().add(router.call).add(staticHandler).handler,
      );

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Server running on http://${server.address.host}:${server.port}');
}
