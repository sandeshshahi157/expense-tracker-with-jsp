<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.mindrot.jbcrypt.BCrypt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sign Up Process</title>
</head>
<body>

<%
    // Retrieve parameters from the request
    String firstName = request.getParameter("first_name");
    String lastName = request.getParameter("last_name");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String passwordConfirmation = request.getParameter("password_confirmation");
    String marketingAccept = request.getParameter("marketing_accept");

    // Validate input parameters
    if (firstName == null || lastName == null || email == null || password == null || passwordConfirmation == null ||
            firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty() || passwordConfirmation.isEmpty()) {
        response.sendRedirect("register.jsp?error=missingFields");
        return;
    }

    if (!password.equals(passwordConfirmation)) {
        response.sendRedirect("register.jsp?error=passwordMismatch");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmtCheck = null;
    PreparedStatement pstmtInsert = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", ""); 
        
        // Check if the email already exists
        pstmtCheck = conn.prepareStatement("SELECT * FROM users WHERE email = ?");
        pstmtCheck.setString(1, email);
        ResultSet rs = pstmtCheck.executeQuery();

        if (rs.next()) {
            // Email already exists, redirect to register page with a message
            response.sendRedirect("register.jsp?error=emailExists");
        } else {
            // Email doesn't exist, proceed with the sign-up
            
            // Generate a username by concatenating first name, last name, and a random number
            String username = firstName + lastName + (int) (Math.random() * 10000);

            // Use BCrypt to hash the password
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

            // Use prepared statement to insert user details with hashed password
            String insertQuery = "INSERT INTO users (first_name, last_name, email, username, password) VALUES (?, ?, ?, ?, ?)";
            pstmtInsert = conn.prepareStatement(insertQuery);
            pstmtInsert.setString(1, firstName);
            pstmtInsert.setString(2, lastName);
            pstmtInsert.setString(3, email);
            pstmtInsert.setString(4, username);
            pstmtInsert.setString(5, hashedPassword);

            int rowsAffected = pstmtInsert.executeUpdate();

            if (rowsAffected > 0) {
                // Successful sign up, redirect to the login page
                response.sendRedirect("login.jsp?signup_success=Sign up successful. You can now log in.");
            } else {
                // Failed sign up, display an error message
                response.sendRedirect("register.jsp?error=signupFailed");
            }
        }
    } catch (ClassNotFoundException e) {
        // Handle ClassNotFoundException
        response.sendRedirect("register.jsp?error=classNotFound");
    } catch (SQLException e) {
        // Handle SQLException
        response.sendRedirect("register.jsp?error=sqlException");
    } finally {
        try {
            if (pstmtCheck != null) pstmtCheck.close();
            if (pstmtInsert != null) pstmtInsert.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            // Handle SQLException in closing resources
            response.sendRedirect("register.jsp?error=closeResourcesException");
        }
    }
%>

</body>
</html>
