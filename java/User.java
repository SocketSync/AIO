/**
 * FinWise - Student Model
 * Language: Java
 */
public class User {
    private String matricId;
    private String fullName;
    private String email;
    private String campus;
    private boolean isUtmVerified;

    public User(String matricId, String fullName, String email, String campus) {
        this.matricId = matricId;
        this.fullName = fullName;
        this.email = email;
        this.campus = campus;
        this.isUtmVerified = email.endsWith("@finwise-app.xyz") || email.endsWith("@finwise-app.xyz");
    }

    public String getMatricId() {
        return matricId;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getCampus() {
        return campus;
    }

    public boolean isUtmVerified() {
        return isUtmVerified;
    }

    @Override
    public String toString() {
        return "Student: " + fullName + " (" + email + ") - Campus: " + campus + " [Verified: " + isUtmVerified + "]";
    }
}

