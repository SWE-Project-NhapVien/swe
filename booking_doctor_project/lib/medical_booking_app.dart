import 'package:booking_doctor_project/screen/patient/ScheduleScreen/schedule_screen.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MedicalBookingApp extends StatefulWidget {
  const MedicalBookingApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MedicalBookingAppState createState() => _MedicalBookingAppState();
}

class _MedicalBookingAppState extends State<MedicalBookingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Medical Booking App',
        debugShowCheckedModeBanner: false,
        routes: _buildRoutes(),
        navigatorKey: navigatorKey,
        builder: (BuildContext context, Widget? child) {
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (BuildContext context) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(
                          MediaQuery.of(context).size.width > 360
                              ? 1.0
                              : (MediaQuery.of(context).size.width >= 340
                                  ? 0.9
                                  : 0.8)),
                    ),
                    child: child ?? const SizedBox(),
                  );
                },
              ));
        });
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/': (BuildContext context) => const ScheduleScreen(),
    };
  }
}
