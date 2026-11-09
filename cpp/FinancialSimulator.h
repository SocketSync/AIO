#ifndef FINWISE_FINANCIAL_SIMULATOR_H
#define FINWISE_FINANCIAL_SIMULATOR_H

#include <string>
#include <vector>
#include <memory>

namespace FinWise {
namespace Simulation {

/**
 * Represents a simulated transaction or scheduled cash flow
 */
struct CashFlowItem {
    std::string name;
    double amount;        // Positive for income, negative for expense
    int dayOfMonth;       // 1 - 31
    bool isRecurring;
};

/**
 * Result of a scenario projection
 */
struct SimulationResult {
    double initialBalance;
    double finalBalance;
    double totalIncome;
    double totalExpense;
    int daysUntilDepletion; // -1 if never depleted
    std::vector<double> dailyBalanceCurve;
    std::string riskAssessment;
};

/**
 * Financial Simulation Engine prepared for Sprint 3 C++ / JNI integration
 */
class FinancialSimulator {
public:
    FinancialSimulator();
    ~FinancialSimulator() = default;

    /**
     * Simulate semester runway based on starting balance and daily average spend
     */
    SimulationResult simulateSemesterRunway(double startingBalance, 
                                            double dailySpend, 
                                            int totalSemesterDays = 126);

    /**
     * Compare hypothetical budget adjustment scenario
     * e.g. reducing campus dining expenses by percentage
     */
    SimulationResult simulateSpendingAdjustment(double startingBalance,
                                                const std::vector<CashFlowItem>& items,
                                                double discretionaryReductionPercent,
                                                int simulationDays = 30);

    /**
     * Calculate compound interest for student savings targets
     */
    double calculateTargetSavings(double initialDeposit,
                                  double monthlyContribution,
                                  double annualRatePercent,
                                  int months);
};

} // namespace Simulation
} // namespace FinWise

#endif // FINWISE_FINANCIAL_SIMULATOR_H

