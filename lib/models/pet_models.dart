/// 寵物模型
class Pet {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int attack;
  final int defense;
  final PetRarity rarity;
  final String unlockMethod; // 解鎖方式描述

  const Pet({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.attack = 10,
    this.defense = 10,
    this.rarity = PetRarity.common,
    this.unlockMethod = '初始寵物',
  });
}

enum PetRarity {
  common,    // 普通
  rare,      // 稀有
  epic,      // 史詩
  legendary, // 傳說
}

/// 怪物模型
class Monster {
  final String id;
  final String name;
  final String emoji;
  final int maxHp;
  final int attack;
  final String taunt; // 怪物台詞

  const Monster({
    required this.id,
    required this.name,
    required this.emoji,
    required this.maxHp,
    this.attack = 10,
    this.taunt = '來挑戰我吧！',
  });
}

/// 戰鬥狀態
class BattleState {
  final Pet pet;
  final Monster monster;
  int playerHp;
  int playerMaxHp;
  int monsterHp;
  int monsterMaxHp;
  int combo; // 連擊數

  BattleState({
    required this.pet,
    required this.monster,
    this.playerHp = 100,
    this.playerMaxHp = 100,
    int? monsterHp,
    int? monsterMaxHp,
    this.combo = 0,
  }) : monsterHp = monsterHp ?? monster.maxHp,
       monsterMaxHp = monsterMaxHp ?? monster.maxHp;

  bool get isPlayerAlive => playerHp > 0;
  bool get isMonsterAlive => monsterHp > 0;
  bool get isBattleOver => !isPlayerAlive || !isMonsterHp;
  bool get isMonsterHp => monsterHp > 0;
  bool get playerWon => !isMonsterAlive && isPlayerAlive;

  // 玩家攻擊怪物
  int attackMonster(int damage) {
    combo++;
    final totalDamage = damage + (combo ~/ 3) * 5; // 連擊加成
    monsterHp = (monsterHp - totalDamage).clamp(0, monsterMaxHp);
    return totalDamage;
  }

  // 怪物攻擊玩家
  int attackPlayer() {
    combo = 0; // 答錯重置連擊
    final damage = (monster.attack - pet.defense ~/ 2).clamp(5, 50);
    playerHp = (playerHp - damage).clamp(0, playerMaxHp);
    return damage;
  }
}

/// 寵物數據
class PetsData {
  // 初始可選寵物
  static const List<Pet> starterPets = [
    Pet(
      id: 'dragon_baby',
      name: '小火龍',
      emoji: '🐲',
      description: '活潑好動的小火龍，攻擊力強勁！',
      attack: 15,
      defense: 8,
      rarity: PetRarity.common,
      unlockMethod: '初始寵物',
    ),
    Pet(
      id: 'cat_wizard',
      name: '貓咪法師',
      emoji: '🐱',
      description: '聰明的貓咪法師，擅長魔法攻擊。',
      attack: 12,
      defense: 12,
      rarity: PetRarity.common,
      unlockMethod: '初始寵物',
    ),
    Pet(
      id: 'robot_buddy',
      name: '機械夥伴',
      emoji: '🤖',
      description: '堅固的機械夥伴，防禦力超強！',
      attack: 8,
      defense: 18,
      rarity: PetRarity.common,
      unlockMethod: '初始寵物',
    ),
  ];

  // 可解鎖寵物
  static const List<Pet> unlockablePets = [
    Pet(
      id: 'phoenix',
      name: '不死鳳凰',
      emoji: '🔥',
      description: '傳說中的火鳥，浴火重生！',
      attack: 20,
      defense: 15,
      rarity: PetRarity.epic,
      unlockMethod: '完成 10 次每日任務',
    ),
    Pet(
      id: 'unicorn',
      name: '獨角獸',
      emoji: '🦄',
      description: '神聖的獨角獸，帶來幸運。',
      attack: 15,
      defense: 20,
      rarity: PetRarity.rare,
      unlockMethod: '累積 1000 分',
    ),
    Pet(
      id: 'ghost',
      name: '幽靈小鬼',
      emoji: '👻',
      description: '調皮的幽靈，敵人攻擊經常落空。',
      attack: 12,
      defense: 25,
      rarity: PetRarity.rare,
      unlockMethod: '完成所有課題',
    ),
    Pet(
      id: 'alien',
      name: '外星訪客',
      emoji: '👾',
      description: '來自宇宙的神秘生物。',
      attack: 18,
      defense: 18,
      rarity: PetRarity.epic,
      unlockMethod: '連續 7 日登入',
    ),
    Pet(
      id: 'golden_dragon',
      name: '黃金神龍',
      emoji: '🐉',
      description: '傳說中最強的神龍！',
      attack: 30,
      defense: 25,
      rarity: PetRarity.legendary,
      unlockMethod: '累積 10000 分',
    ),
    Pet(
      id: 'panda',
      name: '功夫熊貓',
      emoji: '🐼',
      description: '可愛又強壯的熊貓大師。',
      attack: 16,
      defense: 16,
      rarity: PetRarity.rare,
      unlockMethod: '完美通關 5 次',
    ),
    Pet(
      id: 'fox_spirit',
      name: '九尾狐',
      emoji: '🦊',
      description: '神秘的狐仙，智慧超群。',
      attack: 22,
      defense: 14,
      rarity: PetRarity.epic,
      unlockMethod: '連續答對 20 題',
    ),
    Pet(
      id: 'thunder_tiger',
      name: '雷電虎',
      emoji: '🐯',
      description: '速度如雷電的猛虎！',
      attack: 25,
      defense: 12,
      rarity: PetRarity.epic,
      unlockMethod: '限時模式得分超過 200',
    ),
  ];

  static List<Pet> get allPets => [...starterPets, ...unlockablePets];
}

/// 怪物數據
class MonstersData {
  static const List<Monster> monsters = [
    // 初中怪物
    Monster(
      id: 'slime',
      name: '數學史萊姆',
      emoji: '🟢',
      maxHp: 50,
      attack: 8,
      taunt: '嘿嘿，來解題吧！',
    ),
    Monster(
      id: 'goblin',
      name: '哥布林算師',
      emoji: '👺',
      maxHp: 70,
      attack: 12,
      taunt: '你算得過我嗎？',
    ),
    Monster(
      id: 'skeleton',
      name: '骷髏學者',
      emoji: '💀',
      maxHp: 80,
      attack: 15,
      taunt: '讓我考考你...',
    ),
    Monster(
      id: 'ghost_math',
      name: '幽靈教授',
      emoji: '👻',
      maxHp: 90,
      attack: 18,
      taunt: '這題你一定答唔到！',
    ),
    Monster(
      id: 'orc',
      name: '獸人將軍',
      emoji: '👹',
      maxHp: 100,
      attack: 20,
      taunt: '數學就係力量！',
    ),
    // 高中怪物
    Monster(
      id: 'wizard',
      name: '黑暗法師',
      emoji: '🧙',
      maxHp: 120,
      attack: 22,
      taunt: '見識我的魔法公式！',
    ),
    Monster(
      id: 'demon',
      name: '惡魔數學家',
      emoji: '😈',
      maxHp: 150,
      attack: 25,
      taunt: '準備好面對地獄難度了嗎？',
    ),
    Monster(
      id: 'dragon_boss',
      name: '數學魔龍',
      emoji: '🐲',
      maxHp: 200,
      attack: 30,
      taunt: '我係最終 BOSS！',
    ),
  ];

  static Monster getRandomMonster({String? grade}) {
    final available = grade == 'junior' 
        ? monsters.take(4).toList()
        : grade == 'senior'
            ? monsters.skip(4).toList()
            : monsters;
    return available[DateTime.now().millisecond % available.length];
  }

  static Monster getMonsterForTopic(String topicId) {
    final index = topicId.hashCode.abs() % monsters.length;
    return monsters[index];
  }
}
