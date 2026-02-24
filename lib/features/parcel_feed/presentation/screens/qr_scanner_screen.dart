import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/theme.dart';
import '../../bloc/parcel_bloc.dart';
import '../../bloc/parcel_event.dart';
import '../../bloc/parcel_state.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(rawValue) as Map<String, dynamic>;
    } catch (_) {
      _showError('Invalid QR code format.');
      return;
    }

    final token = payload['token'] as String?;
    final parcelId = payload['parcelId'] as String?;

    if (token == null || parcelId == null) {
      _showError('QR code missing token or parcel ID.');
      return;
    }

    setState(() => _isProcessing = true);
    _controller.stop();

    context.read<ParcelBloc>().add(VerifyHandover(
          parcelId: parcelId,
          token: token,
        ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.failed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParcelBloc, ParcelState>(
      listener: (context, state) {
        if (state is HandoverVerified) {
          Navigator.of(context).pop();
        } else if (state is ParcelActionError) {
          setState(() => _isProcessing = false);
          _controller.start();
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Scan Receiver QR'),
          backgroundColor: Colors.black,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            // Viewfinder overlay
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.cyan,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.spacing16),
                ),
              ),
            ),
            // Bottom instruction
            Positioned(
              left: 0,
              right: 0,
              bottom: AppDimensions.spacing32,
              child: Text(
                _isProcessing
                    ? 'Verifying handover\u2026'
                    : 'Point the camera at the receiver\'s QR code',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(color: AppColors.cyan),
              ),
          ],
        ),
      ),
    );
  }
}
