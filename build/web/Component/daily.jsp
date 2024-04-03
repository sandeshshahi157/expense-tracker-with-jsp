<%-- 
    Document   : daily.jsp
    Created on : 27-Feb-2024, 10:29:26 pm
    Author     : hackeath
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Hello World!</h1>
    </body>
    
    
    <%
    HttpSession userSession = request.getSession();
    String loggedInUsername = (String) userSession.getAttribute("username");

    if (loggedInUsername == null) {
        response.sendRedirect("login.jsp");
    }

    String url = "jdbc:mysql://localhost/expensetracker";
    String username = "root";
    String password = "";

    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;

    int userId = 0;
    double totalExpense = 0;
    double weeklyExpense = 0;
    double monthlyExpense = 0;
    double totalDailyExpense = 0;
    boolean tableNotFound = false;
    
     Date currentDate = new Date();

    // Define the date format
  SimpleDateFormat sqlDateFormat = new SimpleDateFormat("yyyy-MM-dd");

    // Format the current date using the SQL date format
    String formattedDate = sqlDateFormat.format(currentDate);

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection(url, username, password);

        String userIdQuery = "SELECT id FROM " + loggedInUsername + " WHERE username = ?";
        try (PreparedStatement userIdStatement = connection.prepareStatement(userIdQuery)) {
            userIdStatement.setString(1, loggedInUsername);
            try (ResultSet userIdResultSet = userIdStatement.executeQuery()) {
                if (userIdResultSet.next()) {
                    userId = userIdResultSet.getInt("id");
                }
            }
        }

        String totalExpenseQuery = "SELECT SUM(amount) AS totalExpense FROM " + loggedInUsername + " WHERE username= ?";
        try (PreparedStatement totalExpenseStatement = connection.prepareStatement(totalExpenseQuery)) {
            totalExpenseStatement.setString(1, loggedInUsername);
            try (ResultSet totalExpenseResultSet = totalExpenseStatement.executeQuery()) {
                if (totalExpenseResultSet.next()) {
                    totalExpense = totalExpenseResultSet.getDouble("totalExpense");
                }
            }
        }

      

        String dailyExpenseQuery = "SELECT SUM(amount) AS dailyTotal FROM " + loggedInUsername +" WHERE  date = ?";
        try (PreparedStatement dailyExpenseStatement = connection.prepareStatement(dailyExpenseQuery)) {         
            dailyExpenseStatement.setString(1, formattedDate);

            try (ResultSet dailyExpenseResultSet = dailyExpenseStatement.executeQuery()) {
                while (dailyExpenseResultSet.next()) {
                    totalDailyExpense = dailyExpenseResultSet.getDouble("dailyTotal");
                    // Process totalDailyExpense as needed
                }
            }
        }

        String monthlyExpenseQuery = "SELECT SUM(amount) AS monthlyExpense FROM " + loggedInUsername +
                " WHERE username= ? AND date > DATE_SUB(NOW(), INTERVAL 1 MONTH)";
        try (PreparedStatement monthlyExpenseStatement = connection.prepareStatement(monthlyExpenseQuery)) {
            monthlyExpenseStatement.setString(1, loggedInUsername);
            try (ResultSet monthlyExpenseResultSet = monthlyExpenseStatement.executeQuery()) {
                if (monthlyExpenseResultSet.next()) {
                    monthlyExpense = monthlyExpenseResultSet.getDouble("monthlyExpense");
                }
            }
        }

    } catch (SQLException e) {
        if (e.getSQLState().equals("42S02")) {
            tableNotFound = true;
        } else {
            e.printStackTrace();  // Log or handle the exception appropriately
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();  // Log or handle the exception appropriately
    } finally {
        try {
            if (resultSet != null) resultSet.close();
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) connection.close();
        } catch (SQLException e) {
            e.printStackTrace();  // Log or handle the exception appropriately
        }
    }
%>
</html>
