// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:booking_doctor_project/utils/color_palette.dart';
import 'package:booking_doctor_project/utils/text_styles.dart';

import '../../../class/appointment.dart';

// ignore: must_be_immutable
class PieChartOrderStatus extends StatelessWidget {
  List<Appointment> appointments;
  PieChartOrderStatus({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    double numberOfCancelledAppointment = 20;
    double numberOfCompletedAppointment = 10;
    double numberOfPendingAppointment = 30;

    appointments.forEach((element) {
      if (element.status == 'Cancelled') {
        numberOfCancelledAppointment++;
      } else if (element.status == 'Completed') {
        numberOfCompletedAppointment++;
      } else {
        numberOfPendingAppointment++;
      }
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorPalette.greyColor,
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders Status',
              style: TextStyles(context)
                  .getBoldStyle(color: ColorPalette.deepBlue, fontSize: 16),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.34,
              width: MediaQuery.of(context).size.width * 0.34,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceColor: ColorPalette.whiteColor,
                  sections: [
                    PieChartSectionData(
                      color: ColorPalette.proportionRed,
                      value: numberOfCancelledAppointment,
                      showTitle: false,
                      radius: 30,
                    ),
                    PieChartSectionData(
                      color: ColorPalette.proportionGreen,
                      value: numberOfCompletedAppointment,
                      showTitle: false,
                      radius: 30,
                    ),
                    PieChartSectionData(
                      color: ColorPalette.proportionAmber,
                      value: numberOfPendingAppointment,
                      showTitle: false,
                      radius: 30,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildToolTips(
                numberOfCancelledAppointment: numberOfCancelledAppointment,
                numberOfCompletedAppointment: numberOfCompletedAppointment,
                numberOfPendingAppointment: numberOfPendingAppointment),
          ],
        ),
      ),
    );
  }

  Widget _buildToolTips(
      {required double numberOfCancelledAppointment,
      required double numberOfCompletedAppointment,
      required double numberOfPendingAppointment}) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Color'),
            Text('Status'),
            Text('Value'),
          ],
        ),
        const SizedBox(height: 6),
        Divider(
          height: 1,
          color: ColorPalette.dividerGreyColor,
        ),
        _buildToolTipsItem(
            color: ColorPalette.proportionRed,
            status: 'Cancelled',
            value: numberOfCancelledAppointment),
        Divider(
          height: 1,
          color: ColorPalette.dividerGreyColor,
        ),
        _buildToolTipsItem(
            color: ColorPalette.proportionGreen,
            status: 'Completed',
            value: numberOfCompletedAppointment),
        Divider(
          height: 1,
          color: ColorPalette.dividerGreyColor,
        ),
        _buildToolTipsItem(
            color: ColorPalette.proportionAmber,
            status: 'Pending',
            value: numberOfPendingAppointment),
      ],
    );
  }

  Widget _buildToolTipsItem(
      {required Color color, required String status, required double value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(status),
          Text(value.toString()),
        ],
      ),
    );
  }
}