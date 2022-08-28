import 'dart:io';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'WebScreen.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  TextEditingController codeCont = TextEditingController();
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        color: appStore.primaryColors,
        textColor: white,
        backWidget: IconButton(
          icon: Icon(Icons.chevron_left_sharp, color: white, size: 18),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 400.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Colors.red, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      if (result!.code!.contains("http://") ||
          result!.code!.contains("https://") ||
          result!.code!.contains("chrome://") ||
          //result!.code!.contains("facebook.com") ||
          result!.code!.contains("data.com") ||
          result!.code!.contains("javascript.com") ||
          result!.code!.contains("about.com")) {
        log("result.code " + result!.code.toString());
        WebScreen(mInitialUrl: result!.code, mHeading: '',isQrScan: true).launch(context);
      } else {
        log(result!.code);
        finish(context);
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
