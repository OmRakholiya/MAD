class DietPlan {
  final String id;
  final String name;
  final String description;
  final String goal; // weight_loss, muscle_gain, maintenance, healthy_eating
  final String difficulty; // beginner, intermediate, advanced
  final int durationDays;
  final String imageUrl;
  final List<String> galleryImages;
  final List<String> benefits;
  final List<String> restrictions;
  final NutritionalInfo dailyTargets;
  final List<MealPlan> mealPlans;

  const DietPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.difficulty,
    required this.durationDays,
    required this.imageUrl,
    required this.galleryImages,
    required this.benefits,
    required this.restrictions,
    required this.dailyTargets,
    required this.mealPlans,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'goal': goal,
        'difficulty': difficulty,
        'durationDays': durationDays,
        'imageUrl': imageUrl,
        'galleryImages': galleryImages,
        'benefits': benefits,
        'restrictions': restrictions,
        'dailyTargets': dailyTargets.toJson(),
        'mealPlans': mealPlans.map((plan) => plan.toJson()).toList(),
      };

  factory DietPlan.fromJson(Map<String, dynamic> json) => DietPlan(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        goal: json['goal'] ?? '',
        difficulty: json['difficulty'] ?? '',
        durationDays: json['durationDays'] ?? 0,
        imageUrl: json['imageUrl'] ?? '',
        galleryImages: List<String>.from(json['galleryImages'] ?? []),
        benefits: List<String>.from(json['benefits'] ?? []),
        restrictions: List<String>.from(json['restrictions'] ?? []),
        dailyTargets: NutritionalInfo.fromJson(json['dailyTargets'] ?? {}),
        mealPlans: (json['mealPlans'] as List<dynamic>? ?? [])
            .map((plan) => MealPlan.fromJson(plan))
            .toList(),
      );
}

class MealPlan {
  final String id;
  final String name;
  final String type; // breakfast, lunch, dinner, snack
  final String description;
  final String imageUrl;
  final int prepTimeMinutes;
  final int servings;
  final String difficulty; // easy, medium, hard
  final NutritionalInfo nutrition;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String> tips;

  const MealPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.imageUrl,
    required this.prepTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.nutrition,
    required this.ingredients,
    required this.instructions,
    required this.tips,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'imageUrl': imageUrl,
        'prepTimeMinutes': prepTimeMinutes,
        'servings': servings,
        'difficulty': difficulty,
        'nutrition': nutrition.toJson(),
        'ingredients': ingredients.map((ing) => ing.toJson()).toList(),
        'instructions': instructions,
        'tips': tips,
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        prepTimeMinutes: json['prepTimeMinutes'] ?? 0,
        servings: json['servings'] ?? 1,
        difficulty: json['difficulty'] ?? 'easy',
        nutrition: NutritionalInfo.fromJson(json['nutrition'] ?? {}),
        ingredients: (json['ingredients'] as List<dynamic>? ?? [])
            .map((ing) => Ingredient.fromJson(ing))
            .toList(),
        instructions: List<String>.from(json['instructions'] ?? []),
        tips: List<String>.from(json['tips'] ?? []),
      );
}

class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String? notes;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'unit': unit,
        'notes': notes,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        unit: json['unit'] ?? '',
        notes: json['notes'],
      );

  String get displayText {
    final amountStr = amount == amount.toInt() 
        ? amount.toInt().toString() 
        : amount.toString();
    return '$amountStr $unit $name${notes != null ? ' ($notes)' : ''}';
  }
}

class NutritionalInfo {
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double fiber; // grams
  final double sugar; // grams
  final int sodium; // mg

  const NutritionalInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
      };

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) => NutritionalInfo(
        calories: json['calories'] ?? 0,
        protein: (json['protein'] ?? 0).toDouble(),
        carbs: (json['carbs'] ?? 0).toDouble(),
        fat: (json['fat'] ?? 0).toDouble(),
        fiber: (json['fiber'] ?? 0).toDouble(),
        sugar: (json['sugar'] ?? 0).toDouble(),
        sodium: json['sodium'] ?? 0,
      );
}

class DailyMealLog {
  final String id;
  final DateTime date;
  final String userId;
  final List<MealEntry> meals;
  final NutritionalInfo totalNutrition;

  const DailyMealLog({
    required this.id,
    required this.date,
    required this.userId,
    required this.meals,
    required this.totalNutrition,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'userId': userId,
        'meals': meals.map((meal) => meal.toJson()).toList(),
        'totalNutrition': totalNutrition.toJson(),
      };

  factory DailyMealLog.fromJson(Map<String, dynamic> json) => DailyMealLog(
        id: json['id'] ?? '',
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
        userId: json['userId'] ?? '',
        meals: (json['meals'] as List<dynamic>? ?? [])
            .map((meal) => MealEntry.fromJson(meal))
            .toList(),
        totalNutrition: NutritionalInfo.fromJson(json['totalNutrition'] ?? {}),
      );
}

class MealEntry {
  final String id;
  final String mealPlanId;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime timestamp;
  final double servingMultiplier;
  final NutritionalInfo nutrition;

  const MealEntry({
    required this.id,
    required this.mealPlanId,
    required this.mealType,
    required this.timestamp,
    required this.servingMultiplier,
    required this.nutrition,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealPlanId': mealPlanId,
        'mealType': mealType,
        'timestamp': timestamp.toIso8601String(),
        'servingMultiplier': servingMultiplier,
        'nutrition': nutrition.toJson(),
      };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        id: json['id'] ?? '',
        mealPlanId: json['mealPlanId'] ?? '',
        mealType: json['mealType'] ?? '',
        timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
        servingMultiplier: (json['servingMultiplier'] ?? 1.0).toDouble(),
        nutrition: NutritionalInfo.fromJson(json['nutrition'] ?? {}),
      );
}
