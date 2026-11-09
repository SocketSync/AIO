import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isExpense = true,
  });

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(
      id: 'food_dining',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFFF9800),
      isExpense: true,
    ),
    CategoryItem(
      id: 'transportation',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Color(0xFF2196F3),
      isExpense: true,
    ),
    CategoryItem(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_cart,
      color: Color(0xFF4CAF50),
      isExpense: true,
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFF9C27B0),
      isExpense: true,
    ),
    CategoryItem(
      id: 'bills_utilities',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: Color(0xFFF44336),
      isExpense: true,
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.sports_esports,
      color: Color(0xFFE91E63),
      isExpense: true,
    ),
    CategoryItem(
      id: 'health_wellness',
      name: 'Health & Wellness',
      icon: Icons.medical_services,
      color: Color(0xFF009688),
      isExpense: true,
    ),
    CategoryItem(
      id: 'salary',
      name: 'Salary / Employment',
      icon: Icons.payments,
      color: Color(0xFF006C49),
      isExpense: false,
    ),
    CategoryItem(
      id: 'freelance',
      name: 'Freelance & Side Gig',
      icon: Icons.laptop_mac,
      color: Color(0xFF00BCD4),
      isExpense: false,
    ),
    CategoryItem(
      id: 'investments',
      name: 'Investments & Returns',
      icon: Icons.trending_up,
      color: Color(0xFF673AB7),
      isExpense: false,
    ),
    CategoryItem(
      id: 'other',
      name: 'General / Other',
      icon: Icons.category,
      color: Color(0xFF607D8B),
      isExpense: true,
    ),
  ];

  static CategoryItem getById(String id) {
    return defaultCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => const CategoryItem(
        id: 'other',
        name: 'General / Other',
        icon: Icons.category,
        color: Color(0xFF607D8B),
      ),
    );
  }
}

