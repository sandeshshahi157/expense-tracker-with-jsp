<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.servlet.http.*, java.io.*" %>
<%@ page import="java.util.Base64" %>


<html>
    <head>
        <!-- Add your head content here -->
    </head>
    <body>

        <div class="list_addedExpese">
            <label class="text-xl">Recent Added Expense</label>
            <ul class="max-w-md divide-y divide-gray-200 dark:divide-gray-700 pt-3">

                <%
                    HttpSession existingSession = request.getSession(false);
                    if (existingSession == null || existingSession.getAttribute("username") == null) {
                        response.sendRedirect("login.jsp?error=Please log in to view expenses.");
                        return;
                    }

                    // Retrieve the username from the session
                    String loggedInUser = (String) existingSession.getAttribute("username");

                    Connection conn = null;
                    PreparedStatement pstmt = null;

                    try {
                        // Database connection details
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");
                        // Retrieve recent expenses from the 'expenses' table
                       String selectQuery = "SELECT * FROM " + loggedInUser + " WHERE WEEK(date) = WEEK(NOW()) ORDER BY date DESC LIMIT 10";
    pstmt = conn.prepareStatement(selectQuery);

    try (ResultSet resultSet = pstmt.executeQuery()) {
        boolean expensesExist = false;

        while (resultSet.next()) {
            expensesExist = true;
            String expense = resultSet.getString("expense");
            double amount = resultSet.getDouble("amount");
            String description = resultSet.getString("description");
            String date = resultSet.getString("date");
                                // Retrieve image data
 

                %>
                <li class="pb-3 sm:pb-4">
                    <div class="flex items-center space-x-4 rtl:space-x-reverse">
                        <div class="flex-shrink-0">
                            <img class="w-8 h-8 rounded-full" src="", alt="Expense Image"/>
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-medium text-gray-900 truncate dark:text-gray-300">
                                <%= expense %>
                            </p>
                            <p class="text-sm text-gray-500 truncate dark:text-gray-300">
                                <%= description %>
                            </p>
                        </div>
                        <div class=" items-center text-base text-gray-900 dark:text-gray-400">
                            <p class="font-semibold"> $<%= amount %> </p>
                            <p class="text-sm text-gray-500 font-sm"> <%= date %></p>

                        </div>
                    </div>
                </li>
                <%
                            }

                            if (!expensesExist) {
                %>
                <li>
                    <p class="text-gray-500 dark:text-gray-300">No expenses added yet.</p>
                </li>
                <%
                            }
                        }
                    } catch (SQLException | ClassNotFoundException e) {
                        e.printStackTrace();
                        out.println("Add Your expense ");
                    } finally {
                        try {
                            if (pstmt != null) pstmt.close();
                            if (conn != null) conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </ul>
        </div>
    </body>
</html>
