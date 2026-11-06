/**
 * FinWise - Student Authentication Engine
 * Language: C++
 */
#include <iostream>
#include <string>
#include <cctype>

class StudentAuth {
public:
    static bool isUtmEmail(const std::string& email) {
        std::string suffix1 = "@graduate.utm.my";
        std::string suffix2 = "@utm.my";

        if (email.length() >= suffix1.length() &&
            email.compare(email.length() - suffix1.length(), suffix1.length(), suffix1) == 0) {
            return true;
        }

        if (email.length() >= suffix2.length() &&
            email.compare(email.length() - suffix2.length(), suffix2.length(), suffix2) == 0) {
            return true;
        }

        return false;
    }

    static bool validatePassword(const std::string& pwd) {
        if (pwd.length() < 8) return false;

        bool hasDigit = false;
        bool hasSpecial = false;

        for (char c : pwd) {
            if (std::isdigit(c)) hasDigit = true;
            if (std::ispunct(c)) hasSpecial = true;
        }

        return hasDigit && hasSpecial;
    }

    static bool authenticate(const std::string& id, const std::string& password) {
        if (id.empty() || password.empty()) return false;
        return true;
    }
};

int main() {
    std::cout << "=== FinWise C++ Authentication Test ===" << std::endl;
    
    std::string testEmail = "yeoh.k@graduate.utm.my";
    std::string testPass = "UtmFin2025!";

    std::cout << "Checking UTM domain: " << (StudentAuth::isUtmEmail(testEmail) ? "Verified" : "Invalid") << std::endl;
    std::cout << "Checking Password:   " << (StudentAuth::validatePassword(testPass) ? "Strong" : "Weak") << std::endl;
    std::cout << "Auth Status:         " << (StudentAuth::authenticate(testEmail, testPass) ? "Granted" : "Denied") << std::endl;

    return 0;
}

