<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify OTP</title>
</head>
<body>

<%
    String email = request.getParameter("email");
    String errorMessage = request.getParameter("error");

    // Display error message if any
    if (errorMessage != null && !errorMessage.isEmpty()) {
        out.println("<p style='color:red;'>" + errorMessage + "</p>");
    }
%>

<form action="verifyOtpAction.jsp" method="post">
    <input type="hidden" name="email" value="<%= email %>">
    Enter OTP: <input type="text" name="otp" required>
    <button type="submit">Verify OTP</button>
</form>

</body>
</html>
