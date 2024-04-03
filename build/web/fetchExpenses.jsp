<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>

<%! // Define the Expense class within the JSP
    public class Expense {
        private String expenseType; // Corrected variable name
        private String description;
        private double amount;
        private String date;

        // Constructors, getters, and setters
        public Expense() {
        }

        public String getExpenseType() {
            return expenseType;
        }

        public void setExpenseType(String expenseType) {
            this.expenseType = expenseType;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public double getAmount() {
            return amount;
        }

        public void setAmount(double amount) {
            this.amount = amount;
        }

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }
    }
%>

<%
    String keyword = request.getParameter("keyword");
    String logusername = (String) session.getAttribute("username");
    List<Expense> expensesList = new ArrayList<>();

    // Database Connection
    Connection connection = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

        // Database Query
        String query = "SELECT * FROM " + logusername + " WHERE username=? AND expense LIKE ?";
        PreparedStatement preparedStatement = connection.prepareStatement(query);
        preparedStatement.setString(1, logusername);
        preparedStatement.setString(2, "%" + keyword + "%");

        ResultSet resultSet = preparedStatement.executeQuery();

        // Convert ResultSet to List of Expense objects
        while (resultSet.next()) {
            Expense expense = new Expense();
            expense.setExpenseType(resultSet.getString("expense")); // Use the correct column name
            expense.setDescription(resultSet.getString("description"));
            expense.setAmount(resultSet.getDouble("amount"));
            expense.setDate(resultSet.getString("date"));

            expensesList.add(expense);
        }

        // Convert List to JSON using Gson
        String jsonExpenses = new Gson().toJson(expensesList);

        // Send JSON as response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonExpenses);
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>