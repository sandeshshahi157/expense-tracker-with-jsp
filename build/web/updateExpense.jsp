<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>

<%
    // Retrieve expense details from the form
    int expenseId = Integer.parseInt(request.getParameter("id"));
    String updatedExpense = request.getParameter("expense");
    double updatedAmount = Double.parseDouble(request.getParameter("amount"));
    String updatedDescription = request.getParameter("description");
    String updatedDate = request.getParameter("date");

    // Assuming you have a session attribute named "username" that holds the logged-in user's name
    String loggedInUsername = (String) request.getSession().getAttribute("username");

    Connection connection = null;
    PreparedStatement preparedStatement = null;

    try {
        // Establish a database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

        // Update the expense in the database
        String updateQuery = "UPDATE " + loggedInUsername + " SET expense=?, amount=?, description=?, date=? WHERE id=?";
        preparedStatement = connection.prepareStatement(updateQuery);
        preparedStatement.setString(1, updatedExpense);
        preparedStatement.setDouble(2, updatedAmount);
        preparedStatement.setString(3, updatedDescription);
        preparedStatement.setString(4, updatedDate);
        preparedStatement.setInt(5, expenseId);
        int rowsAffected = preparedStatement.executeUpdate();

        if (rowsAffected > 0) {
            // Expense updated successfully
            response.sendRedirect("addWallet.jsp");
        } else {
            // Handle the case where the update was not successful
            out.println("Failed to update expense.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        // Handle exceptions appropriately
    } finally {
        // Close resources in the reverse order they were opened
        // ...
    }
%>
