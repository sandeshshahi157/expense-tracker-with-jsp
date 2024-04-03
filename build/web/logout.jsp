<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*, java.io.*" %>
<%@ page import="java.util.*" %>

<%
    // Invalidate the current session
    HttpSession currentSession = request.getSession(false);
    if (currentSession != null) {
        currentSession.invalidate();
    }

    // Clear cookies
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            cookie.setMaxAge(0);
            response.addCookie(cookie);
        }
    }

    // Redirect to the index page after logout
    response.sendRedirect("index.jsp");
%>



<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Your existing head content -->
</head>
<body class="bg-gradient-to-r from-purple-500 to-indigo-600">

<div class="main flex flex-col justify-center">
    <div class=" flex flex-col justify-center items-center align-cente pt-56">
        <!-- Header Section -->
        <header class="text-white text-center py-8">
            <h1 class="text-6xl font-bold pt-5 font-mono">Expense Tracker - Logout</h1>
            <p class="mt-2 pt-8 text-xl font-mono">You have been successfully logged out. Thank you for using Expense Tracker!</p>
        </header>

        <!-- Buttons Section -->
        <div class="flex justify-center text-center space-x-16 mt-8 text-xl font-mono">
            <!-- Signup Button -->
            <a href="register.jsp" class="transition-transform transform hover:scale-110 bg-green-500 hover:bg-green-600 rounded-xl text-white py-2 h-11 w-36"
               onclick="showLoading()">Signup</a>

            <!-- Login Button -->
            <a href="login.jsp" class="transition-transform transform hover:scale-110 bg-blue-500 hover:bg-blue-600 py-2 rounded-xl text-white h-11 w-36"
               onclick="showLoading()">Login</a>
        </div>

    </div>

    <!-- Loading Overlay -->
    <div id="loadingOverlay" class="loading-overlay">
        <div class="loading-spinner"></div>
    </div>

    <!-- Background SVG (Pie Chart) -->
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" class="absolute bottom-0 left-0 opacity-20 pointer-events-none">
        <circle cx="55" cy="55" r="55" fill="transparent" stroke="#ffffff" stroke-width="1"/>
        <circle cx="55" cy="55" r="55" fill="transparent" stroke="#ffffff" stroke-width="10" stroke-dasharray="40 10"/>
    </svg>

</div>

</body>
</html>
