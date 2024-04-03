<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.*" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>

<%
    HttpSession userSession = request.getSession();
    String loggedInUsername = (String) userSession.getAttribute("username");

    String expense = request.getParameter("expense");
    String amount = request.getParameter("amount");
    String expenseType = request.getParameter("expense_type");
    String date = request.getParameter("date");
    String description = request.getParameter("description");

    Connection connection = null;
    PreparedStatement createTableStatement = null;
    PreparedStatement insertStatement = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

        // Your table creation SQL here
        String createTableQuery = "CREATE TABLE IF NOT EXISTS " + loggedInUsername + " ("
                + "id INT PRIMARY KEY AUTO_INCREMENT,"
                + "username VARCHAR(255) NOT NULL,"
                + "expense VARCHAR(255),"
                + "amount DOUBLE,"
                + "expense_type VARCHAR(50),"
                + "date DATE,"
                + "description TEXT,"
                + "CONSTRAINT username_id_constraint UNIQUE (username, id)"
                + ")";
        createTableStatement = connection.prepareStatement(createTableQuery);
        createTableStatement.executeUpdate();

        // Your insert SQL here
        String insertQuery = "INSERT INTO " + loggedInUsername + " (username, expense, amount, expense_type, date, description) VALUES (?, ?, ?, ?, ?, ?)";
        insertStatement = connection.prepareStatement(insertQuery);

        // Use the logged-in username for the entry
        insertStatement.setString(1, loggedInUsername);
        insertStatement.setString(2, expense);

        // Check if the amount is not empty before parsing
        double parsedAmount = 0.0; // Default value or handle differently based on your logic
        if (amount != null && !amount.trim().isEmpty()) {
            try {
                parsedAmount = Double.parseDouble(amount.trim());
            } catch (NumberFormatException e) {
                e.printStackTrace(); // Log or handle the exception appropriately
                // You may want to redirect or show an error message to the user
            }
        }

        insertStatement.setDouble(3, parsedAmount);
        insertStatement.setString(4, expenseType);
        insertStatement.setDate(5, java.sql.Date.valueOf(date));
        insertStatement.setString(6, description);
        insertStatement.executeUpdate();

        // Redirect to success page
        response.sendRedirect("addExpense.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        // Handle exceptions appropriately
    } finally {
        // Close resources in the reverse order they were opened
        if (createTableStatement != null) {
            try {
                createTableStatement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (insertStatement != null) {
            try {
                insertStatement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
