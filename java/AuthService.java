/**
 * FinWise - Authentication Service
 * Language: Java
 */
public class AuthService {

    public static boolean isUtmEmail(String email) {
        if (email == null) return false;
        String lower = email.trim().toLowerCase();
        return lower.endsWith("@graduate.utm.my") || lower.endsWith("@utm.my");
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

        // Return student model
        return new User("A22EC0123", "Yeoh Kean Shen", studentId, "Universiti Teknologi Malaysia (UTM)");
    }

    public static User register(String fullName, String email, String password) {
        if (!isUtmEmail(email)) {
            System.out.println("[Error] Email must belong to UTM domain.");
            return null;
        }

        if (!validatePassword(password)) {
            System.out.println("[Error] Password does not meet security criteria.");
            return null;
        }

        System.out.println("[Success] Student profile registered.");
        return new User("A22EC0123", fullName, email, "Universiti Teknologi Malaysia (UTM)");
    }

    public static void main(String[] args) {
        System.out.println("=== FinWise Java Authentication Test ===");
        User student = login("yeoh.k@graduate.utm.my", "SecretStudentPass99");
        if (student != null) {
            System.out.println(student);
        }
    }
}
