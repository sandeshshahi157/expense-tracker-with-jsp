<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Your head content -->
</head>
<body>

    <h2>User Information</h2>

    <% 
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("location".equals(cookie.getName())) {
    %>
                    <p><strong>User Location:</strong> <%= cookie.getValue() %></p>
    <%
                } else if ("loginTime".equals(cookie.getName())) {
    %>
                    <p><strong>Date of Login:</strong> <%= cookie.getValue() %></p>
    <%
                }
            }
        } else {
    %>
            <p>No cookies found.</p>
    <%
        }
    %>

</body>
</html>