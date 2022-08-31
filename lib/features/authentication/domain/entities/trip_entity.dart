class TripEntity {
  final String tripId;
  final String userId;
  final String driverId;
  final String source;
  final String destination;
  final double cost;
  final String date;
  final String time;
  final String estimatedTime;
  final List pathArray;
  final double rating;

  const TripEntity({
    required this.tripId,
    required this.userId,
    required this.driverId,
    required this.source,
    required this.destination,
    required this.cost,
    required this.date,
    required this.time,
    required this.estimatedTime,
    required this.pathArray,
    required this.rating,
  });
}
