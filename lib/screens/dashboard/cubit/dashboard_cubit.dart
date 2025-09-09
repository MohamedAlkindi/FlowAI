import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flow_ai/services/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());
  DashboardUsage? usage;
  List<Map<String, dynamic>> history = const [];

  Future<void> loadData() async {
    final usageData = await DashboardService.getSavedUsage();
    final usageHistory = await DashboardService.getUsageHistory();

    emit(UsageDataState(usageHistory: usageHistory, usageData: usageData));
  }
}
