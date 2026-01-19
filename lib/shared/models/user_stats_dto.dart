import 'json_utils.dart';

class UserStatsDto {
  const UserStatsDto({
    required this.totalDuration,
    required this.totalDistanse,
    required this.averageSpeed,
    required this.carefuness,
    required this.smoofhands,
    required this.smooffeet,
    required this.braketheshold,
    required this.trailbrake,
    required this.throttlecontrol,
    required this.cornerbalance,
    required this.tracklimit,
    required this.recovery,
    required this.tyresympathy,
    required this.kerbstyle,
    required this.consistency,
    required this.absenabled,
    required this.tcenabled,
    required this.autoshift,
  });

  final double totalDuration;
  final double totalDistanse;
  final double averageSpeed;
  final double carefuness;
  final double smoofhands;
  final double smooffeet;
  final double braketheshold;
  final double trailbrake;
  final double throttlecontrol;
  final double cornerbalance;
  final double tracklimit;
  final double recovery;
  final double tyresympathy;
  final double kerbstyle;
  final double consistency;
  final double absenabled;
  final double tcenabled;
  final double autoshift;

  factory UserStatsDto.fromJson(Map<String, dynamic> json) => UserStatsDto(
        totalDuration: JsonUtils.asDouble(json['total_duration']) ?? 0,
        totalDistanse: JsonUtils.asDouble(json['total_distanse']) ?? 0,
        averageSpeed: JsonUtils.asDouble(json['average_speed']) ?? 0,
        carefuness: JsonUtils.asDouble(json['carefuness']) ?? 0,
        smoofhands: JsonUtils.asDouble(json['smoofhands']) ?? 0,
        smooffeet: JsonUtils.asDouble(json['smooffeet']) ?? 0,
        braketheshold: JsonUtils.asDouble(json['braketheshold']) ?? 0,
        trailbrake: JsonUtils.asDouble(json['trailbrake']) ?? 0,
        throttlecontrol: JsonUtils.asDouble(json['throttlecontrol']) ?? 0,
        cornerbalance: JsonUtils.asDouble(json['cornerbalance']) ?? 0,
        tracklimit: JsonUtils.asDouble(json['tracklimit']) ?? 0,
        recovery: JsonUtils.asDouble(json['recovery']) ?? 0,
        tyresympathy: JsonUtils.asDouble(json['tyresympathy']) ?? 0,
        kerbstyle: JsonUtils.asDouble(json['kerbstyle']) ?? 0,
        consistency: JsonUtils.asDouble(json['consistency']) ?? 0,
        absenabled: JsonUtils.asDouble(json['absenabled']) ?? 0,
        tcenabled: JsonUtils.asDouble(json['tcenabled']) ?? 0,
        autoshift: JsonUtils.asDouble(json['autoshift']) ?? 0,
      );

  List<MapEntry<String, num>> get entries => [
        MapEntry('total_duration', totalDuration),
        MapEntry('total_distanse', totalDistanse),
        MapEntry('average_speed', averageSpeed),
        MapEntry('carefuness', carefuness),
        MapEntry('smoofhands', smoofhands),
        MapEntry('smooffeet', smooffeet),
        MapEntry('braketheshold', braketheshold),
        MapEntry('trailbrake', trailbrake),
        MapEntry('throttlecontrol', throttlecontrol),
        MapEntry('cornerbalance', cornerbalance),
        MapEntry('tracklimit', tracklimit),
        MapEntry('recovery', recovery),
        MapEntry('tyresympathy', tyresympathy),
        MapEntry('kerbstyle', kerbstyle),
        MapEntry('consistency', consistency),
        MapEntry('absenabled', absenabled),
        MapEntry('tcenabled', tcenabled),
        MapEntry('autoshift', autoshift),
      ];
}
