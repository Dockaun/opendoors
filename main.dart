import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Open Doors Project - BLE Beacon Detection and Navigation App
// This app is designed to assist visually impaired users by detecting BLE beacons and using text-to-speech to provide navigation instructions.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load environment variables
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
	return MaterialApp(
  	title: 'Flutter BLE Demo',
  	theme: ThemeData(
    	primarySwatch: Colors.blue,
  	),
  	home: BLEScanner(),
	);
  }
}

class BLEScanner extends StatefulWidget {
  @override
  _BLEScannerState createState() => _BLEScannerState();
}

class _BLEScannerState extends State<BLEScanner> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
	super.initState();
	scanForBeacons();
  }

  void scanForBeacons() {
	flutterBlue.startScan(timeout: Duration(seconds: 4));

	var subscription = flutterBlue.scanResults.listen((results) {
  	for (ScanResult r in results) {
    	// Check if the device is your specific beacon by name or UUID
    	if (r.device.name.contains('BlueCharm') ||
        	r.advertisementData.serviceUuids.contains('426C7565-4368-6172-6D42-6561636F6E73')) {
      	print('Beacon found: ${r.device.name} with RSSI: ${r.rssi}');
      	flutterBlue.stopScan();
      	subscription.cancel();
      	speakInstructions("Beacon detected. Navigating to the door.");
    	}
  	}
	});

	// Stop the scan after 4 seconds if nothing is found
	Future.delayed(Duration(seconds: 4), () {
  	flutterBlue.stopScan();
	});
  }

  Future<void> speakInstructions(String instructions) async {
	// Set TTS options if needed
	await flutterTts.setLanguage('en-US');
	await flutterTts.setSpeechRate(0.5);
	await flutterTts.setPitch(1.0);

	// Speak the instructions
	await flutterTts.speak(instructions);
  }

  @override
  Widget build(BuildContext context) {
	return Scaffold(
  	appBar: AppBar(
    	title: Text('BLE Scanner'),
  	),
  	body: Center(
    	child: Text('Scanning for BLE devices...'),
  	),
	);
  }
}
