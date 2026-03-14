class InterestCalculator {
  /// Calculates daily interest for a negative balance (KMH).
  /// Formula: (Balance * Rate * Days) / (30 * 100) - simplified for monthly rate
  /// TCMB usually uses 365 days for annual, but banks show monthly.
  static double calculateDailyKMHInterest(double negativeBalance, double monthlyRate) {
    if (negativeBalance >= 0) return 0.0;
    
    // Monthly rate is e.g. 5.0 (for 5%)
    // Daily rate approx = monthlyRate / 30
    final dailyRate = monthlyRate / 30 / 100;
    return negativeBalance.abs() * dailyRate;
  }

  /// Estimates monthly interest cost if the balance stays negative for the whole month.
  static double estimateMonthlyInterest(double balance, double monthlyRate) {
    if (balance >= 0) return 0.0;
    return balance.abs() * (monthlyRate / 100);
  }

  /// Calculates the "opportunity cost" or "wasted interest" for credit card debt.
  static double calculateCCWastedInterest(double debt, double monthlyRate) {
    if (debt <= 0) return 0.0;
    return debt * (monthlyRate / 100);
  }
}
