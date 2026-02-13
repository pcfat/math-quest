import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../models/pet_models.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';
import 'home_screen.dart';

class PetSelectionScreen extends StatefulWidget {
  const PetSelectionScreen({super.key});

  @override
  State<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends State<PetSelectionScreen> 
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final starterPets = PetsData.starterPets;
    final selectedPet = starterPets[_selectedIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // 標題
              Text(
                'CHOOSE YOUR',
                style: PixelTheme.pixelText(size: 12, color: PixelTheme.textDim),
              ),
              const SizedBox(height: 8),
              Text(
                'PARTNER',
                style: PixelTheme.pixelTitle(size: 28, color: PixelTheme.secondary),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '選擇你的冒險夥伴！',
                style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim),
              ),
              
              const SizedBox(height: 40),
              
              // 寵物展示
              Expanded(
                child: Column(
                  children: [
                    // 大寵物顯示
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        final offset = _bounceController.value * 10 - 5;
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: PixelTheme.codedexCard(
                          borderColor: _getRarityColor(selectedPet.rarity),
                          borderRadius: 16,
                          withGlow: true,
                        ),
                        child: Center(
                          child: Text(
                            selectedPet.emoji,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 寵物名稱
                    Text(
                      selectedPet.name,
                      style: PixelTheme.pixelTitle(size: 18, color: _getRarityColor(selectedPet.rarity)),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 描述
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        selectedPet.description,
                        style: PixelTheme.pixelText(size: 9, color: PixelTheme.textDim),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 屬性
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatBadge('⚔️', 'ATK', selectedPet.attack, PixelTheme.error),
                        const SizedBox(width: 24),
                        _buildStatBadge('🛡️', 'DEF', selectedPet.defense, PixelTheme.accent),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // 寵物選擇
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(starterPets.length, (index) {
                        final pet = starterPets[index];
                        final isSelected = index == _selectedIndex;
                        
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: isSelected ? 80 : 64,
                            height: isSelected ? 80 : 64,
                            decoration: PixelTheme.codedexCard(
                              color: isSelected 
                                  ? _getRarityColor(pet.rarity).withOpacity(0.2)
                                  : null,
                              borderColor: isSelected 
                                  ? _getRarityColor(pet.rarity)
                                  : PixelTheme.textMuted,
                              borderRadius: 12,
                              withGlow: isSelected,
                            ),
                            child: Center(
                              child: Text(
                                pet.emoji,
                                style: TextStyle(fontSize: isSelected ? 40 : 28),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              
              // 確認按鈕
              Padding(
                padding: const EdgeInsets.all(24),
                child: PixelButton(
                  text: 'CHOOSE ${selectedPet.name.toUpperCase()}',
                  emoji: '✓',
                  color: PixelTheme.primary,
                  height: 60,
                  fontSize: 10,
                  onPressed: () => _confirmSelection(context, selectedPet),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatBadge(String emoji, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: PixelTheme.codedexCard(
        color: color.withOpacity(0.2),
        borderColor: color,
        borderRadius: 12,
        withGlow: false,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: PixelTheme.pixelText(size: 7, color: color)),
              // Progress bar with gradient
              Container(
                width: 60,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: PixelTheme.bgLight,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (value / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text('$value', style: PixelTheme.pixelText(size: 10, color: color)),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getRarityColor(PetRarity rarity) {
    switch (rarity) {
      case PetRarity.common: return PixelTheme.textLight;
      case PetRarity.rare: return PixelTheme.accent;
      case PetRarity.epic: return const Color(0xFFa855f7);
      case PetRarity.legendary: return PixelTheme.secondary;
    }
  }
  
  void _confirmSelection(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelCard(
          borderColor: PixelTheme.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pet.emoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                '確認選擇',
                style: PixelTheme.pixelTitle(size: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${pet.name} 將成為你的夥伴！',
                style: PixelTheme.pixelText(size: 9, color: PixelTheme.textDim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      text: 'NO',
                      color: PixelTheme.error,
                      height: 44,
                      fontSize: 10,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PixelButton(
                      text: 'YES!',
                      color: PixelTheme.primary,
                      height: 44,
                      fontSize: 10,
                      onPressed: () {
                        context.read<GameState>().chooseStarterPet(pet);
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
