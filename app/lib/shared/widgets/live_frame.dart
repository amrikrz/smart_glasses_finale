import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class LiveFrame extends StatefulWidget {
  const LiveFrame({super.key});
  @override
  State<LiveFrame> createState() => _LiveFrameState();
}

class _LiveFrameState extends State<LiveFrame> {
  final _dio = Dio();
  Timer? _timer;
  Uint8List? _bytes;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (_busy) return;
    _busy = true;
    try {
      final r = await _dio.get<List<int>>(
        '${AppConstants.piHttpUrl}/frame.jpg',
        queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
      if (!mounted) return;
      setState(() {
        _bytes = Uint8List.fromList(r.data!);
        _failed = false;
      });
    } catch (_) {
      if (mounted && !_failed) setState(() => _failed = true);
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null || _failed) {
      return const Center(
        child: Text('Pas de flux vidéo',
            style: TextStyle(color: Colors.white54, fontSize: 14)),
      );
    }
    return Image.memory(
      _bytes!,
      fit: BoxFit.cover,
      gaplessPlayback: true, // no flicker between frames
      width: double.infinity,
      height: double.infinity,
    );
  }
}