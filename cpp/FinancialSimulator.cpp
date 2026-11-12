#include "FinancialSimulator.h"
#include <cmath>
#include <algorithm>
#include <sstream>
#include <iomanip>

namespace FinWise {
namespace Simulation {

FinancialSimulator::FinancialSimulator() {
}

SimulationResult FinancialSimulator::simulateSemesterRunway(double startingBalance, 
                                                            double dailySpend, 
                                                            int totalSemesterDays) {
    SimulationResult result;
    result.initialBalance = startingBalance;
    result.totalIncome = 0.0;
    result.totalExpense = 0.0;
    result.daysUntilDepletion = -1;
    result.dailyBalanceCurve.reserve(totalSemesterDays);

    double currentBalance = startingBalance;

    for (int day = 1; day <= totalSemesterDays; ++day) {
        currentBalance -= dailySpend;
        result.totalExpense += dailySpend;
        result.dailyBalanceCurve.push_back(currentBalance);

        if (currentBalance <= 0.0 && result.daysUntilDepletion == -1) {
            result.daysUntilDepletion = day;
        }
    }

    result.finalBalance = currentBalance;

    if (result.daysUntilDepletion != -1) {
        std::ostringstream ss;
        ss << "HIGH RISK: Funds will be depleted on day " << result.daysUntilDepletion 
           << " before the semester concludes (" << totalSemesterDays << " days). Recommended burn rate reduction: RM " 
           << std::fixed << std::setprecision(2) << (dailySpend - (startingBalance / totalSemesterDays)) << "/day.";
        result.riskAssessment = ss.str();
    } else if (currentBalance < startingBalance * 0.15) {
        result.riskAssessment = "MODERATE: Low financial buffer remaining at semester end. Maintain caution on non-essential spending.";
    } else {
        result.riskAssessment = "HEALTHY: Current burn rate maintains a sustainable surplus throughout the 18-week monthly budget.";
    }

    return result;
}

SimulationResult FinancialSimulator::simulateSpendingAdjustment(double startingBalance,
                                                                const std::vector<CashFlowItem>& items,
                                                                double discretionaryReductionPercent,
                                                                int simulationDays) {
    SimulationResult result;
    result.initialBalance = startingBalance;
    result.totalIncome = 0.0;
    result.totalExpense = 0.0;
    result.daysUntilDepletion = -1;
    result.dailyBalanceCurve.reserve(simulationDays);

    double currentBalance = startingBalance;
    double factor = std::max(0.0, 1.0 - (discretionaryReductionPercent / 100.0));

    for (int day = 1; day <= simulationDays; ++day) {
        for (const auto& item : items) {
            if (item.dayOfMonth == (day % 30 == 0 ? 30 : day % 30)) {
                if (item.amount > 0) {
                    currentBalance += item.amount;
                    result.totalIncome += item.amount;
                } else {
                    // Apply reduction to expenses
                    double adjustedExpense = std::abs(item.amount) * factor;
                    currentBalance -= adjustedExpense;
                    result.totalExpense += adjustedExpense;
                }
            }
        }
        result.dailyBalanceCurve.push_back(currentBalance);
        if (currentBalance <= 0.0 && result.daysUntilDepletion == -1) {
            result.daysUntilDepletion = day;
        }
    }

    result.finalBalance = currentBalance;
    result.riskAssessment = (result.finalBalance >= result.initialBalance) ? "NET POSITIVE: Cash flow surplus achieved." : "NET DEFICIT: Consider adjusting discretionary categories.";
    return result;
}

double FinancialSimulator::calculateTargetSavings(double initialDeposit,
                                                  double monthlyContribution,
                                                  double annualRatePercent,
                                                  int months) {
    double monthlyRate = (annualRatePercent / 100.0) / 12.0;
    double futureValue = initialDeposit * std::pow(1.0 + monthlyRate, months);

    if (monthlyRate > 0.0) {
        futureValue += monthlyContribution * ((std::pow(1.0 + monthlyRate, months) - 1.0) / monthlyRate);
    } else {
        futureValue += monthlyContribution * months;
    }

    return futureValue;
}

} // namespace Simulation
} // namespace FinWise

