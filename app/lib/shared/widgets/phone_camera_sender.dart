import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

/// Opens the phone's rear camera and sends pictures to the PC (/upload).
class PhoneCameraSender extends StatefulWidget {
  const PhoneCameraSender({super.key});
  @override
  State<PhoneCameraSender> createState() => _PhoneCameraSenderState();
}

class _PhoneCameraSenderState extends State<PhoneCameraSender> {
  final _dio = Dio();
  CameraController? _ctrl;
  bool _running = false;
  int _sent = 0;
  String _status = 'Caméra…';

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _status = 'Aucune caméra');
        return;
      }
      final cam = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );
      final ctrl =
          CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await ctrl.initialize();
      await ctrl.setFlashMode(FlashMode.off);
      await ctrl.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _ctrl = ctrl;
        _status = 'Envoi…';
      });
      _running = true;
      _loop();
    } catch (e) {
      if (mounted) setState(() => _status = 'Caméra refusée');
    }
  }

  Future<void> _loop() async {
    while (mounted && _running) {
      try {
        final file = await _ctrl!.takePicture();
        final bytes = await file.readAsBytes();
        try {
          await File(file.path).delete(); // do not fill the phone storage
        } catch (_) {}
        await _dio.post(
          '${AppConstants.piHttpUrl}/upload',
          data: Stream.fromIterable([bytes]),
          options: Options(
            contentType: 'image/jpeg',
            headers: {Headers.contentLengthHeader: bytes.length},
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );
        if (mounted) setState(() => _sent++);
      } catch (_) {
        if (mounted) setState(() => _status = 'PC injoignable');
        await Future.delayed(const Duration(milliseconds: 700));
      }
    }
  }

  @override
  void dispose() {
    _running = false;
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctrl;
    return ExcludeSemantics(
      child: Container(
        width: 96,
        height: 128,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white54),
        ),
        child: Stack(fit: StackFit.expand, children: [
          if (c != null && c.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: 96,
                height: 96 * c.value.aspectRatio,
                child: CameraPreview(c),
              ),
            ),
          Positioned(
            left: 4,
            right: 4,
            bottom: 4,
            child: Text(
              _sent > 0 ? 'Envoyées : $_sent' : _status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  backgroundColor: Colors.black54),
            ),
          ),
        ]),
      ),
    );
  }
}