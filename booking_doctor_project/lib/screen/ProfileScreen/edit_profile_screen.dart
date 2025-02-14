import 'package:booking_doctor_project/bloc/patient/GetAProfile/get_a_profile_bloc.dart';
import 'package:booking_doctor_project/bloc/patient/UpdateProfile/update_profile_bloc.dart';
import 'package:booking_doctor_project/bloc/patient/UpdateProfile/update_profile_event.dart';
import 'package:booking_doctor_project/bloc/patient/UpdateProfile/update_profile_state.dart';
import 'package:booking_doctor_project/class/global_profile.dart';
import 'package:booking_doctor_project/class/patient_profile.dart';
import 'package:booking_doctor_project/routes/patient/navigation_services.dart';
import 'package:booking_doctor_project/widgets/common_date_field.dart';
import 'package:booking_doctor_project/widgets/common_dialogs.dart';
import 'package:booking_doctor_project/widgets/common_textfield.dart';
import 'package:booking_doctor_project/widgets/custom_dropdown.dart';
import 'package:booking_doctor_project/widgets/tap_effect.dart';
import 'package:booking_doctor_project/widgets/textfield_with_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/color_palette.dart';
import '../../../utils/text_styles.dart';
import '../../../widgets/common_appbar_with_title.dart';
import '../../../widgets/common_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final List<String> genders = ["Male", "Female", "None"];
  final List<String> allergies = [
    "Egg",
    "Milk",
    "Soy",
    "Tree nuts",
    "Fish",
    "Peanuts",
    "Shellfish",
    "Wheat",
    "Sesame"
  ];

  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
    "None"
  ];

  String selectedGender = 'None';
  String selectedBloodType = 'None';
  final List<String> selectedAllergy = [];

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final relationshipController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final addressController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  final restrictedEmergencyContactController = TextEditingController();

  final List<TextEditingController> emergencyContactsControllers = [];
  final List<TextEditingController> medicalHistoryControllers = [];

  final Map<String, String> errors = {};

  int curStep = 0;
  bool initialized = false;
  late Future<PatientProfile?> patientProfile;

  @override
  void initState() {
    patientProfile = PatientProfile.getProfile();
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    relationshipController.dispose();
    addressController.dispose();
    weightController.dispose();
    heightController.dispose();
    restrictedEmergencyContactController.dispose();

    for (var element in emergencyContactsControllers) {
      element.dispose();
    }
    for (var element in medicalHistoryControllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<GetAProfileBloc, GetAProfileState>(
      listener: (context, state) {
        if (state is GetAProfileSuccess) {
          NavigationServices(context).pushHomeScreen();
        }
      },
      child: FutureBuilder<PatientProfile?>(
          future: patientProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text('Error loading profile'),
              );
            }

            if (initialized == false) {
              final profile = snapshot.data!;
              firstNameController.text = profile.firstName;
              lastNameController.text = profile.lastName;
              phoneNumberController.text = profile.phoneNumber;
              addressController.text = profile.address ?? '';
              dateOfBirthController.text =
                  '${profile.dob.substring(8, 10)}/${profile.dob.substring(5, 7)}/${profile.dob.substring(0, 4)}';
              weightController.text = profile.weight.toString();
              heightController.text = profile.height.toString();
              relationshipController.text = profile.relationship ?? '';
              if (profile.emergencyContacts != null &&
                  profile.emergencyContacts!.isNotEmpty) {
                restrictedEmergencyContactController.text =
                    profile.emergencyContacts!.first;
                for (int i = 1; i < profile.emergencyContacts!.length; i++) {
                  emergencyContactsControllers.add(TextEditingController(
                      text: profile.emergencyContacts![i]));
                }
              }

              selectedGender = profile.gender;

              selectedBloodType = profile.bloodType ?? 'None';

              if (profile.allergies != null && profile.allergies!.isNotEmpty) {
                for (var element in profile.allergies!) {
                  selectedAllergy.add(element);
                }
              }

              if (profile.medicalHistory != null &&
                  profile.medicalHistory!.isNotEmpty) {
                for (var element in profile.medicalHistory!) {
                  medicalHistoryControllers
                      .add(TextEditingController(text: element));
                }
              }

              initialized = true;
            }

            return Scaffold(
              backgroundColor: ColorPalette.whiteColor,
              body: BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
                  listener: (context, state) async {
                if (state is UpdateProfileLoading) {
                  Dialogs(context).showLoadingDialog();
                } else if (state is UpdateProfileSuccess) {
                  Navigator.pop(context);
                  await Dialogs(context).showAnimatedDialog(
                    title: 'Update Profile',
                    content: 'Profile has been updated successfully.',
                  );
                  context.read<GetAProfileBloc>().add(GetAProfileRequired(
                      profileId: GlobalProfile().profileId!));
                } else if (state is UpdateProfileError) {
                  Navigator.pop(context);
                  Dialogs(context).showErrorDialog(message: state.error);
                }
              }, builder: (context, state) {
                return SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(children: [
                        CommonAppBarWithTitle(
                          title: 'Edit Profile',
                          titleSize: 32,
                          topPadding: MediaQuery.of(context).padding.top,
                          prefixIconData: Icons.arrow_back_ios_new_rounded,
                          onPrefixIconClick: () async {
                            if (curStep == 0) {
                              await Dialogs(context).showErrorDialog(
                                title: 'Unsaved Profile Changes',
                                message: 'This profile will not be saved.',
                              );
                              Navigator.pop(context);
                            } else {
                              await Dialogs(context).showErrorDialog(
                                title: 'Unsaved Profile Changes',
                                message: 'This profile will not be saved.',
                              );
                              setState(() {
                                curStep -= 1;
                              });
                            }
                          },
                        ),
                        if (curStep == 0) _buildPersonalInformationForm(size),
                        if (curStep == 1) _buildHealthInformationForm(size),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: CommonButton(
                              buttonTextWidget: Text(
                                curStep == 0 ? 'Next' : 'Complete',
                                style: TextStyles(context).getTitleStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              onTap: () {
                                if (curStep == 0) {
                                  if (validatePage1()) {
                                    setState(() {
                                      curStep += 1;
                                    });
                                  }
                                } else {
                                  if (validatePage2()) {
                                    List<String> allergiesTmp = [];
                                    for (var element in selectedAllergy) {
                                      allergiesTmp.add(element);
                                    }

                                    List<String> emergencyContactsTmp = [];
                                    emergencyContactsTmp.add(
                                        restrictedEmergencyContactController
                                            .text);
                                    for (var element
                                        in emergencyContactsControllers) {
                                      emergencyContactsTmp.add(element.text);
                                    }

                                    List<String> medicalHistoryTmp = [];
                                    for (var element
                                        in medicalHistoryControllers) {
                                      medicalHistoryTmp.add(element.text);
                                    }

                                    context.read<UpdateProfileBloc>().add(
                                          UpdateProfileDataEvent(
                                            id: GlobalProfile().profileId!,
                                            fname: firstNameController.text,
                                            lname: lastNameController.text,
                                            pnum: phoneNumberController.text,
                                            rela: relationshipController.text,
                                            gender: selectedGender,
                                            dob:
                                                '${dateOfBirthController.text.substring(6, 10)}-${dateOfBirthController.text.substring(3, 5)}-${dateOfBirthController.text.substring(0, 2)}',
                                            blood: selectedBloodType,
                                            address: addressController.text,
                                            weight: double.parse(
                                                weightController.text),
                                            height: double.parse(
                                                heightController.text),
                                            econtact: emergencyContactsTmp,
                                            medlist: medicalHistoryTmp,
                                            allergy: allergiesTmp,
                                          ),
                                        );
                                  }
                                }
                              },
                              width: double.infinity,
                              height: size.height * 0.06,
                              radius: 30,
                            ),
                          ),
                        ),
                      ])),
                );
              }),
            );
          }),
    );
  }

  Widget _buildPersonalInformationForm(Size size) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: LabelAndTextField(
                  context: context,
                  label: 'First Name',
                  hintText: '',
                  controller: firstNameController,
                  errorText: errors['firstName'] ?? '',
                  isRestricted: true),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: LabelAndTextField(
                  context: context,
                  label: 'Last Name',
                  hintText: '',
                  controller: lastNameController,
                  errorText: errors['lastName'] ?? '',
                  isRestricted: true),
            )
          ],
        ),
        LabelAndTextField(
            context: context,
            label: 'Phone Number',
            hintText: '',
            controller: phoneNumberController,
            errorText: errors['phoneNumber'] ?? '',
            isRestricted: true),
        LabelAndTextField(
          context: context,
          label: 'Relationship',
          hintText: '',
          controller: relationshipController,
          errorText: '',
        ),
        LabelAndTextField(
          context: context,
          label: 'Address',
          hintText: '',
          controller: addressController,
          errorText: errors['address'] ?? '',
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 101,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: TextStyles(context).getTitleStyle(
                        size: 20,
                        fontWeight: FontWeight.w500,
                        color: ColorPalette.blackColor,
                      ),
                    ),
                    Container(
                      height: size.height * 0.06,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: ColorPalette.blueFormColor,
                          borderRadius: BorderRadius.circular(15)),
                      child: CustDropDown(
                          defaultSelectedIndex: genders.indexOf(selectedGender),
                          items: List<CustDropdownMenuItem<String>>.generate(
                            genders.length,
                            (index) => CustDropdownMenuItem<String>(
                              value: genders[index],
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  genders[index],
                                  style: TextStyles(context).getRegularStyle(),
                                ),
                              ),
                            ),
                          ),
                          borderRadius: 10,
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value as String;
                            });
                          }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              flex: 2,
              child: DateOfBirthPicker(
                label: 'Date of Birth',
                isRestricted: true,
                errorText: errors['dateOfBirth'] ?? '',
                controller: dateOfBirthController,
              ),
            ),
          ],
        ),
        SizedBox(
          height: size.height * 0.02,
        ),
        LabelAndTextField(
            context: context,
            label: 'Emergency Contacts',
            hintText: '',
            height: 111,
            controller: restrictedEmergencyContactController,
            errorText: errors['restrictedEmergencyContact'] ?? '',
            isRestricted: true),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(emergencyContactsControllers.length, (index) {
              return AdditionTextField(
                controller: emergencyContactsControllers[index],
                errorText: errors['emergencyContact$index'] ?? '',
                onRemove: () {
                  setState(() {
                    emergencyContactsControllers.removeAt(index);
                  });
                },
              );
            }),
            if (emergencyContactsControllers.isNotEmpty)
              SizedBox(
                height: size.height * 0.00,
              ),
            Align(
              alignment: Alignment.topRight,
              child: TapEffect(
                onClick: () {
                  setState(() {
                    emergencyContactsControllers.add(TextEditingController());
                  });
                },
                child: Text(
                  '+\tAdd',
                  textAlign: TextAlign.right,
                  style: TextStyles(context).getRegularStyle(
                      fontWeight: FontWeight.w400,
                      color: ColorPalette.deepBlue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthInformationForm(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                height: 111,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blood',
                      style: TextStyles(context).getTitleStyle(
                        size: 20,
                        fontWeight: FontWeight.w500,
                        color: ColorPalette.blackColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: ColorPalette.blueFormColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: CustDropDown(
                            defaultSelectedIndex:
                                bloodTypes.indexOf(selectedBloodType),
                            items: List<CustDropdownMenuItem<String>>.generate(
                              bloodTypes.length,
                              (index) => CustDropdownMenuItem<String>(
                                value: bloodTypes[index],
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    bloodTypes[index],
                                    style:
                                        TextStyles(context).getRegularStyle(),
                                  ),
                                ),
                              ),
                            ),
                            borderRadius: 10,
                            onChanged: (value) {
                              setState(() {
                                selectedBloodType = value as String;
                              });
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: LabelAndTextField(
                context: context,
                label: 'Weight',
                hintText: '',
                controller: weightController,
                errorText: errors['weight'] ?? '',
                suffixText: 'kg',
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: LabelAndTextField(
                  context: context,
                  label: 'Height',
                  hintText: '',
                  controller: heightController,
                  errorText: errors['height'] ?? '',
                  suffixText: 'cm'),
            )
          ],
        ),
        Text(
          'Medical History',
          style: TextStyles(context).getTitleStyle(
            size: 20,
            fontWeight: FontWeight.w500,
            color: ColorPalette.blackColor,
          ),
        ),
        Column(
          children: [
            ...List.generate(medicalHistoryControllers.length, (index) {
              return AdditionTextField(
                controller: medicalHistoryControllers[index],
                errorText: '',
                onRemove: () {
                  setState(() {
                    medicalHistoryControllers.removeAt(index);
                  });
                },
              );
            }),
            SizedBox(
              height: size.height * 0.01,
            ),
            Align(
              alignment: Alignment.topRight,
              child: TapEffect(
                onClick: () {
                  setState(() {
                    medicalHistoryControllers.add(TextEditingController());
                  });
                },
                child: Text(
                  '+\tAdd',
                  textAlign: TextAlign.right,
                  style: TextStyles(context).getRegularStyle(
                      fontWeight: FontWeight.w400,
                      color: ColorPalette.deepBlue),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: size.height * 0.01,
        ),
        Text(
          'Allergies',
          style: TextStyles(context).getTitleStyle(
            size: 20,
            fontWeight: FontWeight.w500,
            color: ColorPalette.blackColor,
          ),
        ),
        Column(
          children: [
            ...List.generate(selectedAllergy.length, (index) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                              color: ColorPalette.blueFormColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: CustDropDown(
                              defaultSelectedIndex:
                                  allergies.indexOf(selectedAllergy[index]),
                              items:
                                  List<CustDropdownMenuItem<String>>.generate(
                                allergies.length,
                                (index) => CustDropdownMenuItem<String>(
                                  value: allergies[index],
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      allergies[index],
                                      style:
                                          TextStyles(context).getRegularStyle(),
                                    ),
                                  ),
                                ),
                              ),
                              borderRadius: 10,
                              onChanged: (value) {
                                setState(() {
                                  selectedAllergy[index] = value as String;
                                });
                              }),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedAllergy.removeAt(index);
                          });
                        },
                        padding: const EdgeInsets.all(0),
                        icon: Icon(
                          Icons.close,
                          color: ColorPalette.deepBlue,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  )
                ],
              );
            }),
            SizedBox(
              height: size.height * 0.005,
            ),
            Align(
              alignment: Alignment.topRight,
              child: TapEffect(
                onClick: () {
                  setState(() {
                    selectedAllergy.add('');
                  });
                },
                child: Text(
                  '+\tAdd',
                  textAlign: TextAlign.right,
                  style: TextStyles(context).getRegularStyle(
                      fontWeight: FontWeight.w400,
                      color: ColorPalette.deepBlue),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool validatePage1() {
    bool isValid = true;
    errors.clear();

    if (firstNameController.text.isEmpty) {
      errors['firstName'] = 'First name is required.';
      isValid = false;
    } else if (!RegExp(r"^[a-zA-Z\s\t]+$").hasMatch(firstNameController.text)) {
      errors['firstName'] = 'No numbers or special characters.';
      isValid = false;
    }

    if (lastNameController.text.isEmpty) {
      errors['lastName'] = 'Last name is required.';
      isValid = false;
    } else if (!RegExp(r"^[a-zA-Z\s\t]+$").hasMatch(lastNameController.text)) {
      errors['lastName'] = 'No numbers or special characters.';
      isValid = false;
    }

    if (phoneNumberController.text.isEmpty) {
      errors['phoneNumber'] = 'Phone number is required.';
      isValid = false;
    } else if (!RegExp(r"^\d+$").hasMatch(phoneNumberController.text)) {
      errors['phoneNumber'] = 'Phone number must be numeric.';
      isValid = false;
    } else if (phoneNumberController.text.trim().length != 10) {
      errors['phoneNumber'] = 'Phone number must be 10 digits.';
      isValid = false;
    }

    if (dateOfBirthController.text.isEmpty) {
      errors['dateOfBirth'] = 'Date of birth is required.';
      isValid = false;
    }

    if (restrictedEmergencyContactController.text.isEmpty) {
      errors['restrictedEmergencyContact'] =
          'At least one emergency contact is required.';
      isValid = false;
    } else if (!RegExp(r"^\d+$")
        .hasMatch(restrictedEmergencyContactController.text)) {
      errors['restrictedEmergencyContact'] =
          'Emergency contact must be numeric.';
      isValid = false;
    } else if (restrictedEmergencyContactController.text.trim().length != 10) {
      errors['restrictedEmergencyContact'] =
          'Emergency contact must be 10 digits.';
    }

    for (var i = 0; i < emergencyContactsControllers.length; i++) {
      final contact = emergencyContactsControllers[i].text;
      if (contact.isEmpty) {
        errors['emergencyContact$i'] = 'Emergency contact is required.';
        isValid = false;
      } else if (!RegExp(r"^\d+$").hasMatch(contact)) {
        errors['emergencyContact$i'] = 'Emergency contact must be numeric.';
        isValid = false;
      } else if (contact.trim().length != 10) {
        errors['emergencyContact$i'] = 'Emergency contact must be 10 digits.';
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  bool validatePage2() {
    bool isValid = true;
    errors.clear();

    if (!RegExp(r"^\d+$").hasMatch(weightController.text) &
        weightController.text.isNotEmpty) {
      errors['weight'] = 'Weight must be numeric.';
      isValid = false;
    }

    if (!RegExp(r"^\d+$").hasMatch(heightController.text) &
        heightController.text.isNotEmpty) {
      errors['height'] = 'Height must be numeric.';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }
}

class AdditionTextField extends StatelessWidget {
  const AdditionTextField({
    super.key,
    required this.controller,
    required this.errorText,
    required this.onRemove,
  });

  final TextEditingController controller;
  final VoidCallback onRemove;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            textEditingController: controller,
            contentPadding: const EdgeInsets.all(14),
            textFieldPadding: const EdgeInsets.only(top: 5, bottom: 2),
            radius: 15,
            hintText: '',
            errorText: errorText,
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon: Icon(
            Icons.close,
            color: ColorPalette.deepBlue,
            size: 15,
          ),
        ),
      ],
    );
  }
}
