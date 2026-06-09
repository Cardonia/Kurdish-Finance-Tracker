# 📊 Localized Kurdish Finance Tracker

A simple, fast, and privacy-focused Android application built with Flutter to help users track their daily income and expenses using Iraqi Dinars (IQD).

---

## ✨ Features

* **🌍 Full Kurdish Language Support:** Custom designed with the `NotoArabic` font family for perfect right-to-left Kurdish text display.


* **💵 Quick Cash Buttons:** Tap-to-add image buttons for common Iraqi Dinar notes (250, 500, 1000, and 5000 IQD) to log transactions instantly without typing out the full number.


* **📈 Easy-to-Read Charts:**
* **Income vs. Expenses:** Visual bar graphs to compare what you make versus what you spend over time.


* **Category Breakdown:** A colorful pie chart showing exactly where your money goes.


* **Time Filters:** Switch views easily between weekly, monthly, and yearly reports.




* **🔒 100% Private & Offline:** Your financial data never leaves your phone. Everything is saved securely directly on your device.



---

## 📁 Project Structure (What each file does)

Here is a simple breakdown of how the app's code is organized:

| File Name | What it does |
| --- | --- |
| `main.dart` | The entry point of the app. It sets up the Kurdish font theme and displays the main home dashboard with options to view stats, log expenses, or add income.

 |
| `insert_screen.dart` | The "Income" screen. Allows you to type in an amount or use the quick cash buttons to add money to your tracker.

 |
| `remove_screen.dart` | The "Expense" screen. Allows you to choose a category, type an amount, or use the quick cash buttons to record what you spent.

 |
| `add_type.dart` | The category manager. Lets you add new custom category types for your expenses (up to a maximum of 15) or delete old ones.

 |
| `total_screen.dart` | The main "Statistics" screen. It shows the bar graphs comparing your income and expenses across weeks, months, or years.

 |
| `pie_chart.dart` | The visual report screen. It transforms your expense categories into an easy-to-understand pie chart with calculated percentages.

 |
| `edit_screen.dart` | The history ledger. Displays a history log of all your entries where you can fix mistakes by editing or deleting past items.

 |
| `storage_service.dart` | The data saver. It handles saving, loading, filtering, and deleting your data safely inside your phone's memory using simple local files.

 |

---

## 🚀 Getting Started

### Prerequisites

Make sure you have Flutter installed on your machine.

### Installation

1. Clone this repository to your computer.
2. Run `flutter pub get` in your terminal to download the required components.
3. Ensure your `pubspec.yaml` includes the `NotoArabic` font and the image assets for the cash buttons (`assets/250.jpg`, `assets/500.jpg`, `assets/1000.jpg`, `assets/5000.jpg`).


4. Connect your Android device or emulator and run `flutter run`.
