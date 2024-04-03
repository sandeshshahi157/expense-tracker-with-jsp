<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>

<%
    // Retrieve expense ID from the request parameter
    int expenseId = Integer.parseInt(request.getParameter("id"));

    // Assuming you have a session attribute named "username" that holds the logged-in user's name
    String loggedInUsername = (String) request.getSession().getAttribute("username");

    Connection connection = null;
    PreparedStatement preparedStatement = null;

    try {
        // Establish a database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

        // Delete the expense from the database
        String deleteQuery = "DELETE FROM " + loggedInUsername + " WHERE id=?";
        preparedStatement = connection.prepareStatement(deleteQuery);
        preparedStatement.setInt(1, expenseId);
        int rowsAffected = preparedStatement.executeUpdate();

        if (rowsAffected > 0) {
            // Expense deleted successfully
            response.sendRedirect("addWallet.jsp");
        } else {
            // Handle the case where the deletion was not successful
            out.println("Failed to delete expense.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        // Handle exceptions appropriately
    } finally {
        // Close resources in the reverse order they were opened
        // ...
    }
%>
