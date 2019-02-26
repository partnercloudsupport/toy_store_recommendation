import 'dart:math' as math;

import 'package:toy_store/model/gender.dart';
import 'package:toy_store/widget_utils.dart';
import 'package:flutter/material.dart';

const double defaultGenderAngle = math.pi / 4;
const Map<Gender, double> genderAngles = {
  Gender.girl: -defaultGenderAngle,
  Gender.other: 0.0,
  Gender.boy: defaultGenderAngle,
};

double circleSize(BuildContext context) => screenAwareSize(80.0, context);
