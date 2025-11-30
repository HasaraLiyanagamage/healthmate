-- HealthMate Database Schema and Sample Data
-- This script creates the tables and populates them with sample data

-- Create health_records table
CREATE TABLE IF NOT EXISTS health_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,
  steps INTEGER NOT NULL,
  calories REAL NOT NULL,
  waterIntake REAL NOT NULL
);

-- Create user_profile table
CREATE TABLE IF NOT EXISTS user_profile (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  gender TEXT NOT NULL,
  height REAL NOT NULL,
  weight REAL NOT NULL,
  dailyStepsGoal INTEGER NOT NULL,
  dailyWaterGoal REAL NOT NULL,
  dailyCaloriesGoal REAL NOT NULL,
  activityLevel TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);

-- Insert sample health records
INSERT INTO health_records (date, steps, calories, waterIntake) VALUES
  ('2025-11-25', 10000, 2500.0, 2.5),
  ('2025-11-24', 8500, 2200.0, 2.0),
  ('2025-11-23', 12000, 2800.0, 3.0),
  ('2025-11-22', 9500, 2400.0, 2.2),
  ('2025-11-21', 11000, 2600.0, 2.8),
  ('2025-11-20', 7500, 2100.0, 1.8),
  ('2025-11-19', 13000, 2900.0, 3.2);

-- Insert sample user profile
INSERT INTO user_profile (name, age, gender, height, weight, dailyStepsGoal, dailyWaterGoal, dailyCaloriesGoal, activityLevel, createdAt, updatedAt) VALUES
  ('John Doe', 25, 'Male', 175.0, 70.0, 10000, 2.5, 2000.0, 'Moderately Active', '2025-11-20 10:30:00', '2025-11-25 15:45:00');
