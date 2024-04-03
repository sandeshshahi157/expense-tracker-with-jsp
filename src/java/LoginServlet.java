
import jakarta.servlet.ServletException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;



import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "")) {
                String query = "SELECT * FROM users WHERE email=?";
                try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                    pstmt.setString(1, email);
                    try (ResultSet resultSet = pstmt.executeQuery()) {
                        if (resultSet.next()) {
                            String hashedPasswordFromDB = resultSet.getString("password");
                            if (BCrypt.checkpw(password, hashedPasswordFromDB)) {
                                // Set a cookie with the username
                                Cookie usernameCookie = new Cookie("username", resultSet.getString("username"));
                                usernameCookie.setMaxAge(3600); // Set the cookie to expire in 1 hour (adjust as needed)
                                response.addCookie(usernameCookie);

                                // Set a cookie with the login time
                                long loginTime = System.currentTimeMillis();
                                Cookie loginTimeCookie = new Cookie("loginTime", String.valueOf(loginTime));
                                loginTimeCookie.setMaxAge(3600); // Set the cookie to expire in 1 hour (adjust as needed)
                                response.addCookie(loginTimeCookie);

                                // Placeholder for location (replace with actual location retrieval)
                                String userLocation = "User's Location";

                                // Set a cookie with the location
                                Cookie locationCookie = new Cookie("location", userLocation);
                                locationCookie.setMaxAge(3600); // Set the cookie to expire in 1 hour (adjust as needed)
                                response.addCookie(locationCookie);

                                HttpSession session = request.getSession();
                                session.setAttribute("username", resultSet.getString("username"));

                                response.sendRedirect("dashboard.jsp?login_success=Login successful. Welcome!");
                            } else {
                                response.sendRedirect("login.jsp?error=invalidCredentials");
                            }
                        } else {
                            response.sendRedirect("login.jsp?error=userNotFound");
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=An error occurred. Please try again later.");
        }
    }
}
