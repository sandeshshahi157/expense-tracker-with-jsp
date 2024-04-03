<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<%@ page import="javax.servlet.http.*" %>
<!DOCTYPE html>
<html lang="en">
<head>

</head>
<body>
    <div id="loading" style="display: none; text-align: center;">
        <p>Loading...</p>
    </div>

    <%
        // Setting session timeout to 10 years (in seconds)
        int sessionTimeout = 10 * 365 * 24 * 60 * 60; // 10 years in seconds

        HttpSession existingSession = request.getSession(false);
        if (existingSession != null && existingSession.getAttribute("username") != null) {
            existingSession.setMaxInactiveInterval(sessionTimeout);
            response.sendRedirect("dashboard.jsp");
        } else {
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
                                    usernameCookie.setMaxAge(sessionTimeout); // Set expiration to 10 years
                                    response.addCookie(usernameCookie);

                                    // Store login status in session
                                    HttpSession newSession = request.getSession(true);
                                    newSession.setAttribute("username", resultSet.getString("username"));
                                    newSession.setMaxInactiveInterval(sessionTimeout);

                                    // Redirect after showing loading overlay
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
            } catch (SQLException | ClassNotFoundException e) {
                e.printStackTrace();
                response.sendRedirect("login.jsp?error=An error occurred. Please try again later.");
            }
        }
    %>

    <%
        // Remove the "username" cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("username".equals(cookie.getName())) {
                    cookie.setMaxAge(0); // Expire cookie immediately
                    response.addCookie(cookie);
                    break;
                }
            }
        }
    %>
</body>
</html>
