<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OTP Verification</title>
</head>
<body>
    <%
        // Retrieve parameters from the request
        String email = request.getParameter("email");
        String userEnteredOTP = request.getParameter("otp");

        // Check if the user entered the correct OTP
        if (verifyOTP(email, userEnteredOTP)) {
            // OTP is correct, perform further actions (e.g., redirect to the dashboard)
            response.sendRedirect("dashboard.jsp");
        } else {
            // OTP is incorrect, redirect to the login page with an error message
            response.sendRedirect("login.jsp?login_error=Invalid OTP");
        }

        // Function to verify OTP
        boolean verifyOTP(String userEmail, String enteredOTP) {
            Connection conn = null;
            PreparedStatement pstmt = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

                // Retrieve stored OTP from the database
                pstmt = conn.prepareStatement("SELECT otp FROM otp_table WHERE email = ?");
                pstmt.setString(1, userEmail);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    String storedOTP = rs.getString("otp");
                    return enteredOTP.equals(storedOTP);
                } else {
                    return false; // User not found or OTP not stored
                }
            } catch (ClassNotFoundException | SQLException e) {
                // Handle exceptions
                e.printStackTrace();
                return false;
            } finally {
                try {
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    // Handle SQLException in closing resources
                    e.printStackTrace();
                }
            }
        }
    %>
</body>
</html>
