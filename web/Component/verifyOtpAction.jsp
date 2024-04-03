<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.mindrot.jbcrypt.BCrypt, java.util.UUID, java.util.Properties, javax.mail.*, java.util.Date" %>
<%@ page import="OtpUtil" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>verifyOptAction page</title>
</head>
<body>

<%
    // Retrieve parameters from the request
    String email = request.getParameter("email");
    String enteredOtp = request.getParameter("otp");
    int maxAttempts = 4;

    // Validate input parameters
    if (email == null || email.isEmpty() || enteredOtp == null || enteredOtp.isEmpty()) {
        response.sendRedirect("signup.jsp?error=missingFields");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmtSelect = null;
    PreparedStatement pstmtUpdate = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

        // Retrieve user details by email
        pstmtSelect = conn.prepareStatement("SELECT * FROM users WHERE email = ?");
        pstmtSelect.setString(1, email);
        ResultSet rs = pstmtSelect.executeQuery();

        if (rs.next()) {
            // User found, check OTP
            String storedOtp = rs.getString("otp");
            int attemptsRemaining = rs.getInt("otp_attempts");

            if (attemptsRemaining > 0) {
                // Check if entered OTP matches stored OTP
                if (enteredOtp.equals(storedOtp)) {
                    // Correct OTP, update user status and redirect to login page
                    pstmtUpdate = conn.prepareStatement("UPDATE users SET is_verified = 1, otp = null, otp_attempts = 0 WHERE email = ?");
                    pstmtUpdate.setString(1, email);
                    pstmtUpdate.executeUpdate();

                    response.sendRedirect("login.jsp?verification_success=Account verified successfully. You can now log in.");
                } else {
                    // Incorrect OTP, update attempts
                    attemptsRemaining--;
                    pstmtUpdate = conn.prepareStatement("UPDATE users SET otp_attempts = ? WHERE email = ?");
                    pstmtUpdate.setInt(1, attemptsRemaining);
                    pstmtUpdate.setString(2, email);
                    pstmtUpdate.executeUpdate();

                    response.sendRedirect("verifyOtp.jsp?email=" + email + "&error=incorrectOtp&attemptsRemaining=" + attemptsRemaining);
                }
            } else {
                // Exceeded maximum attempts, redirect to signup page
                response.sendRedirect("register.jsp?error=otpAttemptsExceeded");
            }
        } else {
            // User not found, redirect to signup page
            response.sendRedirect("register.jsp?error=userNotFound");
        }
    } catch (ClassNotFoundException e) {
        // Handle ClassNotFoundException
        response.sendRedirect("register.jsp?error=classNotFound");
    } catch (SQLException e) {
        // Handle SQLException
        response.sendRedirect("register.jsp?error=sqlException");
    } finally {
        try {
            if (pstmtSelect != null) pstmtSelect.close();
            if (pstmtUpdate != null) pstmtUpdate.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            // Handle SQLException in closing resources
            response.sendRedirect("register.jsp?error=closeResourcesException");
        }
    }
%>

</body>
</html>
