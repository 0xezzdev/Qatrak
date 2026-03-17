class TrainModel {
  final String id;
  final String trainNumber;
  final String trainType;
  final String route;
  final String direction;

  TrainModel({
    required this.id,
    required this.trainNumber,
    required this.trainType,
    required this.route,
    required this.direction,
  });

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    return TrainModel(
      id: json['id'].toString(),
      trainNumber: json['train_number'].toString(),
      trainType: json['train_type'].toString(),
      route: json['route'].toString(),
      direction: json['direction'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'train_number': trainNumber,
      'train_type': trainType,
      'route': route,
      'direction': direction,
    };
  }
}
