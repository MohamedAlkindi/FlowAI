class DashboardUsage {
  final int requestCount;
  final int dailyLimit;
  final int requestsLastMinute;
  final int perMinuteLimit;
  final String lastRequestDate; // yyyy-MM-dd
  final String lastRequestMinute; // ISO string

  DashboardUsage({
    required this.requestCount,
    required this.dailyLimit,
    required this.requestsLastMinute,
    required this.perMinuteLimit,
    required this.lastRequestDate,
    required this.lastRequestMinute,
  });

  factory DashboardUsage.fromJson(Map<String, dynamic> json) {
    return DashboardUsage(
      requestCount: json['request_count'] is int
          ? json['request_count']
          : int.tryParse('${json['request_count']}') ?? 0,
      dailyLimit: json['daily_limit'] is int
          ? json['daily_limit']
          : int.tryParse('${json['daily_limit']}') ?? 0,
      requestsLastMinute: json['requests_last_minute'] is int
          ? json['requests_last_minute']
          : int.tryParse('${json['requests_last_minute']}') ?? 0,
      perMinuteLimit: json['per_minute_limit'] is int
          ? json['per_minute_limit']
          : int.tryParse('${json['per_minute_limit']}') ?? 0,
      lastRequestDate: (json['last_request_date'] ?? '').toString(),
      lastRequestMinute: (json['last_request_minute'] ?? '').toString(),
    );
  }
}
