/**
 * FinWise - Authentication Service
 * Language: Java
 */
public class AuthService {

    public static boolean isUtmEmail(String email) {
        if (email == null) return false;
        String lower = email.trim().toLowerCase();
        return lower.endsWith("@finwise-app.xyz") || lower.endsWith("@finwise-app.xyz");
    }

    public static boolean validatePassword(String password) {
        if (password == null || password.length() < 8) return false;
        boolean hasNumber = password.matches(".*\\d.*");
        boolean hasSymbol = password.matches(".*[!@#$%^&*(),.?\":{}|<>].*");
        return hasNumber && hasSymbol;
    }

    public static User login(String studentId, String password) {
        if (studentId == null || studentId.trim().isEmpty() || password == null || password.isEmpty()) {
            System.out.println("[Error] Missing login credentials.");
            return null;
        }

        // Return user model
        return new User("00000000-0000-4000-8000-000000000001", "Demo Finwise", studentId, "FinWise");
    }

    public static User register(String fullName, String email, String password) {
        if (!validatePassword(password)) {
            System.out.println("[Error] Password does not meet security criteria.");
            return null;
        }

        System.out.println("[Success] User profile registered.");
        return new User("00000000-0000-4000-8000-000000000001", fullName, email, "FinWise");
    }

    public static void main(String[] args) {
        System.out.println("=== FinWise Java Authentication Test ===");
        User user = login("demo@finwise-app.xyz", "FinWise2026!");
        if (user != null) {
            System.out.println(user);
        }
    }
}

