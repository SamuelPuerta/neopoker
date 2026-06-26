import 'package:equatable/equatable.dart';
import 'card.dart';
import '../enums/power_type.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final String operatorId;
  final List<CardEntity> holeCards;
  final int stack;
  final int currentBet;
  final bool isActive;
  final bool isAllIn;
  final int energy;
  final List<PowerType> availablePowers;
  final PowerType? activePower;
  final bool isBot;
  final int botDifficulty;
  final int totalBetThisHand;

  const PlayerEntity({
    required this.id,
    this.name = '',
    this.operatorId = 'vex',
    this.holeCards = const [],
    this.stack = 1000,
    this.currentBet = 0,
    this.isActive = true,
    this.isAllIn = false,
    this.energy = 3,
    this.availablePowers = const [],
    this.activePower,
    this.isBot = false,
    this.botDifficulty = 1,
    this.totalBetThisHand = 0,
  });

  bool get canUsePower => energy > 0 && activePower == null;

  PlayerEntity copyWith({
    String? id,
    String? name,
    String? operatorId,
    List<CardEntity>? holeCards,
    int? stack,
    int? currentBet,
    bool? isActive,
    bool? isAllIn,
    int? energy,
    List<PowerType>? availablePowers,
    PowerType? activePower,
    bool? isBot,
    int? botDifficulty,
    int? totalBetThisHand,
    bool clearActivePower = false,
  }) {
    return PlayerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      operatorId: operatorId ?? this.operatorId,
      holeCards: holeCards ?? this.holeCards,
      stack: stack ?? this.stack,
      currentBet: currentBet ?? this.currentBet,
      isActive: isActive ?? this.isActive,
      isAllIn: isAllIn ?? this.isAllIn,
      energy: energy ?? this.energy,
      availablePowers: availablePowers ?? this.availablePowers,
      activePower: clearActivePower ? null : (activePower ?? this.activePower),
      isBot: isBot ?? this.isBot,
      botDifficulty: botDifficulty ?? this.botDifficulty,
      totalBetThisHand: totalBetThisHand ?? this.totalBetThisHand,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        operatorId,
        holeCards,
        stack,
        currentBet,
        isActive,
        isAllIn,
        energy,
        availablePowers,
        activePower,
        isBot,
        botDifficulty,
        totalBetThisHand,
      ];
}
