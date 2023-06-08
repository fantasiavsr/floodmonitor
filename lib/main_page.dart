import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// ignore: must_be_immutable
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // distance 1
  double distance1 = 0.0; // Nilai jarak Distance 1 (dalam cm)
  double distance1forgraph = 0.0; // Nilai untuk panjang graafik
  final double graphHeight1 = 200.0; // Tinggi grafik meter (dalam pixel)

  //distance 2
  double distance2 = 0.0; // Nilai jarak Distance 2 (dalam cm)
  double distance2forgraph = 0.0; // Nilai untuk panjang graafik
  double graphHeight2 = 200.0; // Tinggi grafik meter (dalam pixel)

  //water level
  double waterLevel = 0.0; // Water level tidak memiliki satuan
  double waterLevelForGraph = 0.0; // Nilai untuk panjang graafik
  double graphHeight3 = 200.0; // Tinggi grafik

  //warning meter low, medium, high, very high with 1/2/3/4
  int warningMeter = 0;

  //firebase database reference
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('test');

  @override
  void initState() {
    super.initState();

    //distance 1 -> calculate distance from water flood to the sensor
    _databaseReference.child('distance').onValue.listen((event) {
      setState(() {
        distance1 = double.tryParse(event.snapshot.value.toString()) ?? 0.0;

        if (distance1 > 29) {
          // calculate distance  with right triangle leg c = distance1 and leg a = 30cm
          distance1 = sqrt(pow(distance1, 2) - pow(30, 2));
          //convert value to round
          distance1 = double.parse(distance1.toStringAsFixed(2));
        } else {
          distance1 = 0;
        }

        if (distance1 > 100) {
          distance1forgraph = 0;
        } else if (distance1 < 0) {
          distance1forgraph = 100;
        } else {
          distance1forgraph = 100 - distance1;
        }
      });
    });

    //distance 2 -> distance of height from water flood to the sensor
    _databaseReference.child('distance2').onValue.listen((event) {
      setState(() {
        distance2 = double.tryParse(event.snapshot.value.toString()) ?? 0.0;

        //calculate water flood height
        //distance2 = 30 - distance2;
        //convert value to round
        //distance2 = double.parse(distance2.toStringAsFixed(2));

        if (distance2 <= 15) {
          distance2 = 15 - distance2;
        }

        if (distance2 > 15) {
          distance2forgraph = 0;
        } else if (distance2 < 0) {
          distance2forgraph = 0;
        } else {
          distance2forgraph = distance2;
        }
      });
    });

    //water level
    _databaseReference.child('water_level').onValue.listen((event) {
      setState(() {
        waterLevel = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      });
    });

    //set realtime warning meter value based on distance 1 value, distance 2 value, and water level value, data not from database
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // if else distance1 , distance 2, water level
        if (waterLevel > 110) {
          warningMeter = 4;
        } else if (waterLevel > 100 && distance1 < 25 && distance2 > 10) {
          warningMeter = 4;
        } else if (waterLevel > 50) {
          warningMeter = 3;
        } else if (distance1 < 25 || distance2 >= 10) {
          warningMeter = 3;
        } else if (waterLevel <= 6 && distance1 < 35 && distance2 > 5) {
          warningMeter = 2;
        } else if (waterLevel <= 6 && distance1 < 50 && distance2 > 1) {
          warningMeter = 1;
        } else if (waterLevel < 6 && distance1 > 75 && distance2 > 1) {
          warningMeter = 0;
        } else {
          warningMeter = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flood Warning Monitoring System'),
        ),
        // ignore: avoid_unnecessary_containers
        body: Container(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 2,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* Title Card */
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      /* Title */
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Flood Warning',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      /* Sub Title */
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'IOT Flood Monitoring',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  /* Warning Meter with icon, normal, preparation, warning, danger*/
                  buildWarningMeterCard(),
                  /* Card 1 - Distance 1 */
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Distance 1',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width -
                                          102) *
                                      (distance1forgraph / 100),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            '$distance1 cm | $distance1forgraph %',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /* Card 2 - Distance 2 */
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Distance 2',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width -
                                          102) *
                                      (distance2forgraph / 15),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            '$distance2 cm',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /* Card 3 - Water Level */
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Water Level',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            height: graphHeight2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: (graphHeight3 / 100) * waterLevel,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            '$waterLevel',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget buildWarningMeterCard() {
    IconData warningIcon;
    Color warningColor;
    String warningText;

    // Set the icon, color, and text based on the warningMeter value
    switch (warningMeter) {
      case 0:
        warningIcon = Icons.check_circle;
        warningColor = Colors.green;
        warningText = 'Normal';
        break;
      case 1:
        warningIcon = Icons.check_circle;
        warningColor = Colors.green;
        warningText = 'Normal';
        break;
      case 2:
        warningIcon = Icons.warning;
        warningColor = Colors.yellow;
        warningText = 'Preparation';
        break;
      case 3:
        warningIcon = Icons.warning;
        warningColor = Colors.orange;
        warningText = 'Warning';
        break;
      case 4:
        warningIcon = Icons.error;
        warningColor = Colors.red;
        warningText = 'Danger';
        break;
      default:
        warningIcon = Icons.check_circle;
        warningColor = Colors.green;
        warningText = 'Normal';
    }

    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Warning Meter',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  warningIcon,
                  color: warningColor,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              warningText,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: warningColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
