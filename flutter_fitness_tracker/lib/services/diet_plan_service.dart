import '../models/diet_plan_model.dart';

class DietPlanService {
  static List<DietPlan> getPredefinedPlans() {
    return [
      _weightLossPlan(),
      _muscleGainPlan(),
      _healthyEatingPlan(),
      _mediterraneanPlan(),
    ];
  }

  static DietPlan? getPlanById(String id) {
    try {
      return getPredefinedPlans().firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<DietPlan> getPlansByGoal(String goal) {
    return getPredefinedPlans().where((plan) => plan.goal == goal).toList();
  }

  static DietPlan _weightLossPlan() {
    return DietPlan(
      id: 'weight_loss_plan',
      name: 'Weight Loss Plan',
      description: 'A balanced, calorie-controlled diet plan designed to help you lose weight sustainably while maintaining proper nutrition.',
      goal: 'weight_loss',
      difficulty: 'beginner',
      durationDays: 30,
      imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&h=600&fit=crop',
      galleryImages: [
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop',
      ],
      benefits: [
        'Sustainable weight loss of 1-2 lbs per week',
        'Improved energy levels',
        'Better portion control habits',
        'Increased vegetable intake',
        'Reduced processed food consumption'
      ],
      restrictions: [
        'Limited processed foods',
        'Controlled portion sizes',
        'Reduced sugar intake',
        'Limited refined carbohydrates'
      ],
      dailyTargets: const NutritionalInfo(
        calories: 1500,
        protein: 120,
        carbs: 150,
        fat: 50,
        fiber: 30,
        sugar: 50,
        sodium: 2000,
      ),
      mealPlans: [
        _avocadoToastBreakfast(),
        _quinoaSaladLunch(),
        _grilledSalmonDinner(),
        _greekYogurtSnack(),
      ],
    );
  }

  static DietPlan _muscleGainPlan() {
    return DietPlan(
      id: 'muscle_gain_plan',
      name: 'Muscle Gain Plan',
      description: 'High-protein diet plan optimized for muscle building and recovery, perfect for those engaged in strength training.',
      goal: 'muscle_gain',
      difficulty: 'intermediate',
      durationDays: 45,
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop',
      galleryImages: [
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1546554137-f86b9593a222?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop',
      ],
      benefits: [
        'Optimized protein intake for muscle growth',
        'Enhanced workout recovery',
        'Increased lean muscle mass',
        'Improved strength gains',
        'Better post-workout nutrition'
      ],
      restrictions: [
        'High protein requirements',
        'Timing of meals around workouts',
        'Limited empty calories',
        'Adequate hydration essential'
      ],
      dailyTargets: const NutritionalInfo(
        calories: 2500,
        protein: 180,
        carbs: 250,
        fat: 85,
        fiber: 35,
        sugar: 60,
        sodium: 2300,
      ),
      mealPlans: [
        _proteinPancakesBreakfast(),
        _chickenQuinoaLunch(),
        _beefStirFryDinner(),
        _proteinSmoothieSnack(),
      ],
    );
  }

  static DietPlan _healthyEatingPlan() {
    return DietPlan(
      id: 'healthy_eating_plan',
      name: 'Balanced Healthy Eating',
      description: 'A well-rounded nutrition plan focusing on whole foods, balanced macronutrients, and sustainable healthy eating habits.',
      goal: 'maintenance',
      difficulty: 'beginner',
      durationDays: 21,
      imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800&h=600&fit=crop',
      galleryImages: [
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=400&h=300&fit=crop',
      ],
      benefits: [
        'Improved overall health',
        'Better energy throughout the day',
        'Enhanced immune system',
        'Stable blood sugar levels',
        'Improved digestion'
      ],
      restrictions: [
        'Minimal processed foods',
        'Focus on whole foods',
        'Balanced meal timing',
        'Adequate water intake'
      ],
      dailyTargets: const NutritionalInfo(
        calories: 2000,
        protein: 150,
        carbs: 200,
        fat: 70,
        fiber: 30,
        sugar: 55,
        sodium: 2100,
      ),
      mealPlans: [
        _oatmealBerryBreakfast(),
        _mediterraneanWrapLunch(),
        _herbChickenDinner(),
        _mixedNutsSnack(),
      ],
    );
  }

  static DietPlan _mediterraneanPlan() {
    return DietPlan(
      id: 'mediterranean_plan',
      name: 'Mediterranean Diet',
      description: 'Traditional Mediterranean eating pattern rich in olive oil, fish, vegetables, and whole grains for heart health.',
      goal: 'healthy_eating',
      difficulty: 'intermediate',
      durationDays: 28,
      imageUrl: 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=800&h=600&fit=crop',
      galleryImages: [
        'https://images.unsplash.com/photo-1559847844-d721426d6edc?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1551782450-17144efb9c50?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop',
      ],
      benefits: [
        'Heart-healthy eating pattern',
        'Rich in antioxidants',
        'Anti-inflammatory foods',
        'Improved brain health',
        'Longevity benefits'
      ],
      restrictions: [
        'Limited red meat',
        'Focus on fish and seafood',
        'Olive oil as primary fat',
        'Moderate wine consumption (optional)'
      ],
      dailyTargets: const NutritionalInfo(
        calories: 2100,
        protein: 140,
        carbs: 220,
        fat: 80,
        fiber: 35,
        sugar: 50,
        sodium: 1800,
      ),
      mealPlans: [
        _greekYogurtHoneyBreakfast(),
        _mediterraneanSaladLunch(),
        _bakedSeaBassDinner(),
        _olivesAlmondsSnack(),
      ],
    );
  }

  // Sample Meal Plans - Simplified versions
  static MealPlan _avocadoToastBreakfast() {
    return MealPlan(
      id: 'avocado_toast',
      name: 'Avocado Toast with Poached Egg',
      type: 'breakfast',
      description: 'Nutritious whole grain toast topped with mashed avocado and a perfectly poached egg.',
      imageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=400&h=300&fit=crop',
      prepTimeMinutes: 10,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 320, protein: 14, carbs: 25, fat: 18, fiber: 8, sugar: 3, sodium: 380),
      ingredients: [
        const Ingredient(name: 'whole grain bread', amount: 2, unit: 'slices'),
        const Ingredient(name: 'ripe avocado', amount: 0.5, unit: 'medium'),
        const Ingredient(name: 'egg', amount: 1, unit: 'large'),
      ],
      instructions: ['Toast bread', 'Mash avocado', 'Poach egg', 'Assemble and serve'],
      tips: ['Use fresh eggs', 'Choose ripe avocados'],
    );
  }

  static MealPlan _proteinPancakesBreakfast() {
    return MealPlan(
      id: 'protein_pancakes',
      name: 'High-Protein Banana Pancakes',
      type: 'breakfast',
      description: 'Fluffy pancakes packed with protein powder and topped with fresh berries.',
      imageUrl: 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=400&h=300&fit=crop',
      prepTimeMinutes: 15,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 420, protein: 35, carbs: 45, fat: 8, fiber: 6, sugar: 20, sodium: 320),
      ingredients: [
        const Ingredient(name: 'protein powder', amount: 30, unit: 'g'),
        const Ingredient(name: 'banana', amount: 1, unit: 'medium'),
        const Ingredient(name: 'eggs', amount: 2, unit: 'large'),
      ],
      instructions: ['Blend ingredients', 'Cook pancakes', 'Serve with berries'],
      tips: ['Use ripe bananas', 'Don\'t overmix'],
    );
  }

  static MealPlan _oatmealBerryBreakfast() {
    return MealPlan(
      id: 'oatmeal_berry',
      name: 'Overnight Oats with Mixed Berries',
      type: 'breakfast',
      description: 'Creamy overnight oats topped with antioxidant-rich berries.',
      imageUrl: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400&h=300&fit=crop',
      prepTimeMinutes: 5,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 350, protein: 18, carbs: 55, fat: 8, fiber: 10, sugar: 18, sodium: 120),
      ingredients: [
        const Ingredient(name: 'rolled oats', amount: 50, unit: 'g'),
        const Ingredient(name: 'Greek yogurt', amount: 100, unit: 'g'),
        const Ingredient(name: 'mixed berries', amount: 80, unit: 'g'),
      ],
      instructions: ['Mix ingredients', 'Refrigerate overnight', 'Top with berries'],
      tips: ['Prepare multiple servings', 'Add chia seeds'],
    );
  }

  static MealPlan _greekYogurtHoneyBreakfast() {
    return MealPlan(
      id: 'greek_yogurt_honey',
      name: 'Greek Yogurt with Honey and Walnuts',
      type: 'breakfast',
      description: 'Creamy Greek yogurt drizzled with honey and topped with walnuts.',
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=300&fit=crop',
      prepTimeMinutes: 3,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 280, protein: 20, carbs: 25, fat: 12, fiber: 2, sugar: 22, sodium: 85),
      ingredients: [
        const Ingredient(name: 'Greek yogurt', amount: 200, unit: 'g'),
        const Ingredient(name: 'honey', amount: 2, unit: 'tbsp'),
        const Ingredient(name: 'walnuts', amount: 20, unit: 'g'),
      ],
      instructions: ['Place yogurt in bowl', 'Drizzle honey', 'Top with walnuts'],
      tips: ['Choose plain yogurt', 'Toast walnuts'],
    );
  }

  static MealPlan _quinoaSaladLunch() {
    return MealPlan(
      id: 'quinoa_salad',
      name: 'Mediterranean Quinoa Salad',
      type: 'lunch',
      description: 'Fresh quinoa salad with vegetables and feta cheese.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
      prepTimeMinutes: 20,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 380, protein: 16, carbs: 45, fat: 14, fiber: 8, sugar: 8, sodium: 520),
      ingredients: [
        const Ingredient(name: 'quinoa', amount: 60, unit: 'g'),
        const Ingredient(name: 'cucumber', amount: 100, unit: 'g'),
        const Ingredient(name: 'feta cheese', amount: 40, unit: 'g'),
      ],
      instructions: ['Cook quinoa', 'Dice vegetables', 'Mix and dress'],
      tips: ['Cool quinoa first', 'Add fresh herbs'],
    );
  }

  static MealPlan _chickenQuinoaLunch() {
    return MealPlan(
      id: 'chicken_quinoa',
      name: 'Grilled Chicken Quinoa Bowl',
      type: 'lunch',
      description: 'Protein-packed bowl with grilled chicken and quinoa.',
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop',
      prepTimeMinutes: 25,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 520, protein: 42, carbs: 48, fat: 16, fiber: 8, sugar: 12, sodium: 580),
      ingredients: [
        const Ingredient(name: 'chicken breast', amount: 120, unit: 'g'),
        const Ingredient(name: 'quinoa', amount: 60, unit: 'g'),
        const Ingredient(name: 'mixed vegetables', amount: 180, unit: 'g'),
      ],
      instructions: ['Grill chicken', 'Cook quinoa', 'Roast vegetables', 'Assemble bowl'],
      tips: ['Marinate chicken', 'Season vegetables well'],
    );
  }

  static MealPlan _mediterraneanWrapLunch() {
    return MealPlan(
      id: 'mediterranean_wrap',
      name: 'Mediterranean Hummus Wrap',
      type: 'lunch',
      description: 'Whole wheat wrap filled with hummus and fresh vegetables.',
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop',
      prepTimeMinutes: 10,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 420, protein: 18, carbs: 58, fat: 14, fiber: 12, sugar: 8, sodium: 680),
      ingredients: [
        const Ingredient(name: 'whole wheat tortilla', amount: 1, unit: 'large'),
        const Ingredient(name: 'hummus', amount: 60, unit: 'g'),
        const Ingredient(name: 'mixed vegetables', amount: 200, unit: 'g'),
      ],
      instructions: ['Spread hummus', 'Add vegetables', 'Roll tightly'],
      tips: ['Pat vegetables dry', 'Don\'t overfill'],
    );
  }

  static MealPlan _mediterraneanSaladLunch() {
    return MealPlan(
      id: 'mediterranean_salad',
      name: 'Greek Village Salad',
      type: 'lunch',
      description: 'Traditional Greek salad with tomatoes, cucumber, and feta.',
      imageUrl: 'https://images.unsplash.com/photo-1559847844-d721426d6edc?w=400&h=300&fit=crop',
      prepTimeMinutes: 15,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 320, protein: 12, carbs: 18, fat: 24, fiber: 6, sugar: 12, sodium: 890),
      ingredients: [
        const Ingredient(name: 'tomatoes', amount: 200, unit: 'g'),
        const Ingredient(name: 'cucumber', amount: 150, unit: 'g'),
        const Ingredient(name: 'feta cheese', amount: 60, unit: 'g'),
      ],
      instructions: ['Chop vegetables', 'Add feta and olives', 'Dress with oil and vinegar'],
      tips: ['Use ripe tomatoes', 'Let salad sit'],
    );
  }

  static MealPlan _grilledSalmonDinner() {
    return MealPlan(
      id: 'grilled_salmon',
      name: 'Grilled Salmon with Asparagus',
      type: 'dinner',
      description: 'Perfectly grilled salmon with roasted asparagus.',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop',
      prepTimeMinutes: 20,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 420, protein: 35, carbs: 12, fat: 26, fiber: 5, sugar: 6, sodium: 380),
      ingredients: [
        const Ingredient(name: 'salmon fillet', amount: 150, unit: 'g'),
        const Ingredient(name: 'asparagus', amount: 200, unit: 'g'),
        const Ingredient(name: 'lemon', amount: 0.5, unit: 'medium'),
      ],
      instructions: ['Season salmon', 'Grill 4-5 min per side', 'Roast asparagus', 'Serve with lemon'],
      tips: ['Don\'t overcook', 'Let salmon rest'],
    );
  }

  static MealPlan _beefStirFryDinner() {
    return MealPlan(
      id: 'beef_stir_fry',
      name: 'Beef and Vegetable Stir Fry',
      type: 'dinner',
      description: 'Quick beef stir fry with mixed vegetables.',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=300&fit=crop',
      prepTimeMinutes: 18,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 480, protein: 38, carbs: 22, fat: 28, fiber: 6, sugar: 12, sodium: 650),
      ingredients: [
        const Ingredient(name: 'beef sirloin', amount: 120, unit: 'g'),
        const Ingredient(name: 'mixed vegetables', amount: 200, unit: 'g'),
        const Ingredient(name: 'soy sauce', amount: 2, unit: 'tbsp'),
      ],
      instructions: ['Slice beef thinly', 'Stir fry beef', 'Add vegetables', 'Season and serve'],
      tips: ['Keep heat high', 'Don\'t overcrowd pan'],
    );
  }

  static MealPlan _herbChickenDinner() {
    return MealPlan(
      id: 'herb_chicken',
      name: 'Herb-Crusted Chicken with Sweet Potato',
      type: 'dinner',
      description: 'Juicy herb-crusted chicken with roasted sweet potato.',
      imageUrl: 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400&h=300&fit=crop',
      prepTimeMinutes: 30,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 450, protein: 40, carbs: 35, fat: 16, fiber: 6, sugar: 8, sodium: 420),
      ingredients: [
        const Ingredient(name: 'chicken breast', amount: 150, unit: 'g'),
        const Ingredient(name: 'sweet potato', amount: 200, unit: 'g'),
        const Ingredient(name: 'mixed herbs', amount: 1, unit: 'tbsp'),
      ],
      instructions: ['Season chicken with herbs', 'Roast sweet potato', 'Pan-sear chicken', 'Rest and serve'],
      tips: ['Use meat thermometer', 'Let chicken rest'],
    );
  }

  static MealPlan _bakedSeaBassDinner() {
    return MealPlan(
      id: 'baked_sea_bass',
      name: 'Mediterranean Baked Sea Bass',
      type: 'dinner',
      description: 'Delicate sea bass baked with Mediterranean herbs.',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&h=300&fit=crop',
      prepTimeMinutes: 25,
      servings: 1,
      difficulty: 'medium',
      nutrition: const NutritionalInfo(calories: 380, protein: 32, carbs: 18, fat: 20, fiber: 4, sugar: 8, sodium: 420),
      ingredients: [
        const Ingredient(name: 'sea bass fillet', amount: 150, unit: 'g'),
        const Ingredient(name: 'mixed vegetables', amount: 200, unit: 'g'),
        const Ingredient(name: 'olive oil', amount: 1, unit: 'tbsp'),
      ],
      instructions: ['Season fish', 'Arrange vegetables', 'Bake 15-18 minutes', 'Check doneness'],
      tips: ['Don\'t overcook', 'Check with fork'],
    );
  }

  static MealPlan _greekYogurtSnack() {
    return MealPlan(
      id: 'greek_yogurt_snack',
      name: 'Greek Yogurt with Berries',
      type: 'snack',
      description: 'Protein-rich Greek yogurt with fresh berries.',
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=300&fit=crop',
      prepTimeMinutes: 2,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 150, protein: 15, carbs: 18, fat: 3, fiber: 3, sugar: 15, sodium: 60),
      ingredients: [
        const Ingredient(name: 'Greek yogurt', amount: 150, unit: 'g'),
        const Ingredient(name: 'mixed berries', amount: 80, unit: 'g'),
      ],
      instructions: ['Place yogurt in bowl', 'Top with berries'],
      tips: ['Choose plain yogurt', 'Add honey if desired'],
    );
  }

  static MealPlan _proteinSmoothieSnack() {
    return MealPlan(
      id: 'protein_smoothie',
      name: 'Post-Workout Protein Smoothie',
      type: 'snack',
      description: 'Refreshing protein smoothie perfect after workouts.',
      imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&h=300&fit=crop',
      prepTimeMinutes: 5,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 280, protein: 25, carbs: 35, fat: 6, fiber: 4, sugar: 28, sodium: 120),
      ingredients: [
        const Ingredient(name: 'protein powder', amount: 30, unit: 'g'),
        const Ingredient(name: 'banana', amount: 1, unit: 'medium'),
        const Ingredient(name: 'almond milk', amount: 250, unit: 'ml'),
      ],
      instructions: ['Add ingredients to blender', 'Blend until smooth', 'Serve immediately'],
      tips: ['Use frozen banana', 'Add ice for coldness'],
    );
  }

  static MealPlan _mixedNutsSnack() {
    return MealPlan(
      id: 'mixed_nuts',
      name: 'Mixed Nuts and Dried Fruit',
      type: 'snack',
      description: 'Healthy mix of nuts and dried fruit.',
      imageUrl: 'https://images.unsplash.com/photo-1599599810694-57a2ca8276a8?w=400&h=300&fit=crop',
      prepTimeMinutes: 1,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 200, protein: 6, carbs: 12, fat: 16, fiber: 3, sugar: 8, sodium: 5),
      ingredients: [
        const Ingredient(name: 'mixed nuts', amount: 30, unit: 'g'),
        const Ingredient(name: 'dried fruit', amount: 20, unit: 'g'),
      ],
      instructions: ['Mix nuts and fruit', 'Portion into containers'],
      tips: ['Choose unsalted nuts', 'Watch portions'],
    );
  }

  static MealPlan _olivesAlmondsSnack() {
    return MealPlan(
      id: 'olives_almonds',
      name: 'Mediterranean Olives and Almonds',
      type: 'snack',
      description: 'Traditional Mediterranean snack.',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      prepTimeMinutes: 1,
      servings: 1,
      difficulty: 'easy',
      nutrition: const NutritionalInfo(calories: 180, protein: 5, carbs: 8, fat: 16, fiber: 4, sugar: 2, sodium: 420),
      ingredients: [
        const Ingredient(name: 'kalamata olives', amount: 40, unit: 'g'),
        const Ingredient(name: 'almonds', amount: 20, unit: 'g'),
      ],
      instructions: ['Combine olives and almonds', 'Serve in small bowl'],
      tips: ['Choose quality olives', 'Raw almonds preferred'],
    );
  }
}
