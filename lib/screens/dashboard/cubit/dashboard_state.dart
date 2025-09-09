part of 'dashboard_cubit.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class UsageDataState extends DashboardState {
  final List<Map<String, dynamic>> usageHistory;
  final DashboardUsage? usageData;

  UsageDataState({required this.usageHistory, required this.usageData});
}
