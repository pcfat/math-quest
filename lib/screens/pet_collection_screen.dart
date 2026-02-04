import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../models/pet_models.dart';
import '../theme/pixel_theme.dart';

class PetCollectionScreen extends StatelessWidget {
  const PetCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final ownedPets = gameState.ownedPets;
    final lockedPets = gameState.lockedPets;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, gameState),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 當前寵物
                      if (gameState.activePet != null)
                        _buildActivePet(gameState.activePet!),
                      
                      const SizedBox(height: 24),
                      
                      // 擁有的寵物
                      Text(
                        'MY PETS (${ownedPets.length})',
                        style: PixelTheme.pixelText(size: 10, color: PixelTheme.primary),
                      ),
                      const SizedBox(height: 12),
                      _buildPetGrid(context, ownedPets, isOwned: true),
                      
                      const SizedBox(height: 24),
                      
                      // 未解鎖寵物
                      Text(
                        'LOCKED (${lockedPets.length})',
                        style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim),
                      ),
                      const SizedBox(height: 12),
                      _buildPetGrid(context, lockedPets, isOwned: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: PixelTheme.bgMid,
                border: Border.all(color: PixelTheme.textDim, width: 3),
              ),
              child: const Center(
                child: Text('←', style: TextStyle(
                  fontFamily: PixelTheme.pixelFont,
                  fontSize: 16,
                  color: PixelTheme.textLight,
                )),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text('🐾', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text('PETS', style: PixelTheme.pixelTitle(size: 16, color: PixelTheme.accent)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PixelTheme.secondary.withOpacity(0.2),
              border: Border.all(color: PixelTheme.secondary, width: 2),
            ),
            child: Text(
              '${gameState.ownedPets.length}/${PetsData.allPets.length}',
              style: PixelTheme.pixelText(size: 10, color: PixelTheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivePet(Pet pet) {
    return PixelCard(
      borderColor: PixelTheme.accent,
      child: Row(
        children: [
          // 寵物圖標
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: PixelTheme.accent.withOpacity(0.2),
              border: Border.all(color: PixelTheme.accent, width: 3),
            ),
            child: Center(
              child: Text(pet.emoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pet.name, style: PixelTheme.pixelText(size: 12)),
                    const SizedBox(width: 8),
                    PixelBadge(
                      text: 'ACTIVE',
                      color: PixelTheme.primary,
                      fontSize: 6,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniStat('⚔️', pet.attack, PixelTheme.error),
                    const SizedBox(width: 16),
                    _buildMiniStat('🛡️', pet.defense, PixelTheme.accent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniStat(String emoji, int value, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text('$value', style: PixelTheme.pixelText(size: 10, color: color)),
      ],
    );
  }
  
  Widget _buildPetGrid(BuildContext context, List<Pet> pets, {required bool isOwned}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: pets.map((pet) => _buildPetCard(context, pet, isOwned)).toList(),
    );
  }
  
  Widget _buildPetCard(BuildContext context, Pet pet, bool isOwned) {
    final gameState = context.read<GameState>();
    final isActive = gameState.activePet?.id == pet.id;
    
    return GestureDetector(
      onTap: isOwned ? () => _showPetDetails(context, pet, isOwned) : null,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOwned 
              ? (isActive ? PixelTheme.accent.withOpacity(0.2) : PixelTheme.bgMid)
              : PixelTheme.bgMid.withOpacity(0.5),
          border: Border.all(
            color: isOwned 
                ? (isActive ? PixelTheme.accent : _getRarityColor(pet.rarity))
                : PixelTheme.textDim,
            width: isActive ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            // 寵物
            Text(
              isOwned ? pet.emoji : '🔒',
              style: TextStyle(
                fontSize: 36,
                color: isOwned ? null : PixelTheme.textDim,
              ),
            ),
            const SizedBox(height: 8),
            // 名稱
            Text(
              pet.name,
              style: PixelTheme.pixelText(
                size: 7,
                color: isOwned ? PixelTheme.textLight : PixelTheme.textDim,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 稀有度
            _buildRarityBadge(pet.rarity),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRarityBadge(PetRarity rarity) {
    final labels = {
      PetRarity.common: 'N',
      PetRarity.rare: 'R',
      PetRarity.epic: 'SR',
      PetRarity.legendary: 'SSR',
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getRarityColor(rarity).withOpacity(0.2),
        border: Border.all(color: _getRarityColor(rarity), width: 1),
      ),
      child: Text(
        labels[rarity]!,
        style: PixelTheme.pixelText(size: 6, color: _getRarityColor(rarity)),
      ),
    );
  }
  
  Color _getRarityColor(PetRarity rarity) {
    switch (rarity) {
      case PetRarity.common: return PixelTheme.textDim;
      case PetRarity.rare: return PixelTheme.accent;
      case PetRarity.epic: return const Color(0xFFa855f7);
      case PetRarity.legendary: return PixelTheme.secondary;
    }
  }
  
  void _showPetDetails(BuildContext context, Pet pet, bool isOwned) {
    final gameState = context.read<GameState>();
    final isActive = gameState.activePet?.id == pet.id;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelCard(
          borderColor: _getRarityColor(pet.rarity),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 寵物
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getRarityColor(pet.rarity).withOpacity(0.2),
                  border: Border.all(color: _getRarityColor(pet.rarity), width: 3),
                ),
                child: Center(
                  child: Text(pet.emoji, style: const TextStyle(fontSize: 60)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 名稱
              Text(pet.name, style: PixelTheme.pixelTitle(size: 14, color: _getRarityColor(pet.rarity))),
              const SizedBox(height: 4),
              _buildRarityBadge(pet.rarity),
              
              const SizedBox(height: 12),
              
              // 描述
              Text(
                pet.description,
                style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // 屬性
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatBox('⚔️', 'ATK', pet.attack, PixelTheme.error),
                  const SizedBox(width: 16),
                  _buildStatBox('🛡️', 'DEF', pet.defense, PixelTheme.accent),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 解鎖方式
              if (!isOwned)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PixelTheme.bgLight,
                    border: Border.all(color: PixelTheme.textDim, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        pet.unlockMethod,
                        style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 按鈕
              if (isOwned && !isActive)
                PixelButton(
                  text: 'SET ACTIVE',
                  emoji: '✓',
                  color: PixelTheme.primary,
                  height: 44,
                  fontSize: 9,
                  onPressed: () {
                    gameState.setActivePet(pet);
                    Navigator.pop(context);
                  },
                )
              else if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: PixelTheme.primary.withOpacity(0.2),
                    border: Border.all(color: PixelTheme.primary, width: 2),
                  ),
                  child: Text(
                    'CURRENT PARTNER',
                    style: PixelTheme.pixelText(size: 8, color: PixelTheme.primary),
                  ),
                ),
              
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'CLOSE',
                  style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatBox(String emoji, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          Text(label, style: PixelTheme.pixelText(size: 6, color: color)),
          Text('$value', style: PixelTheme.pixelText(size: 12, color: color)),
        ],
      ),
    );
  }
}
