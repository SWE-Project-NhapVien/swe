import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_webapp/bloc/DoctorInfo/doctor_info_event.dart';
import 'package:doctor_webapp/bloc/DoctorInfo/doctor_info_state.dart';
import 'package:doctor_webapp/bloc/DoctorInfo/doctor_info_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final String doctorId;

  const ProfileScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetDoctorInfoBloc()..add(GetDoctorInfoEvent(doctorId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocBuilder<GetDoctorInfoBloc, GetDoctorInfoState>(
          builder: (context, state) {
            if (state is GetDoctorInfoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is GetDoctorInfoSuccess) {
              return _buildDoctorProfile(state.doctorData);
            } else if (state is GetDoctorInfoError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text("No data available."));
          },
        ),
      ),
    );
  }

  Widget _buildDoctorProfile(Map<String, dynamic> doctorData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundImage: doctorData['ava_url'] != null
                ? NetworkImage(doctorData['ava_url'])
                : const AssetImage('assets/placeholder.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          // Doctor's Name
          Text(
            "${doctorData['first_name']} ${doctorData['last_name']}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Specialization: ${doctorData['specialization']}",
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          const Divider(height: 32),
          // Profile Details
          _buildInfoRow("Date of Birth", doctorData['date_of_birth']),
          _buildInfoRow("Gender", doctorData['gender']),
          _buildInfoRow("Blood Type", doctorData['blood_type']),
          _buildInfoRow("Phone Number", doctorData['phone_number']),
          _buildInfoRow("Address", doctorData['address']),
          const Divider(height: 32),
          _buildInfoRow("Education", doctorData['education']),
          _buildInfoRow("Career", doctorData['career']),
          _buildInfoRow("Description", doctorData['description']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "N/A"),
          ),
        ],
      ),
    );
  }
}
