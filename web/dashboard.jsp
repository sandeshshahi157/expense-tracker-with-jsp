<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.sql.*, java.util.*, java.text.*, com.google.gson.Gson" %>

<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>



<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="com.google.gson.Gson" %>

<%
    String loginUsername = (String) session.getAttribute("username");

    // Database connection parameters
    String dUrl = "jdbc:mysql://localhost/expensetracker";
    String dUsername = "root";
    String dPassword = "";

    // JDBC variables
    Connection dConnection = null;
    PreparedStatement dStatements = null;
    ResultSet dResultSets = null;

    double emonthlyTotal = 0.0;
    String emonth = null;
    // Map to store monthly totals
    Map<String, Double> emonthlyTotalsMap = new LinkedHashMap<>(); // Use LinkedHashMap for maintaining insertion order

    try {
        // Load the JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish a connection
        dConnection = DriverManager.getConnection(dUrl, dUsername, dPassword);
        
        // Get monthly totals for the logged-in user, ordered by month name
             String emonthlyTotalQuery = "SELECT DATE_FORMAT(date, '%b') AS month, SUM(amount) AS monthlyTotal " +
                "FROM " + loginUsername +
                " WHERE username = ? AND YEAR(date) = YEAR(CURDATE()) GROUP BY month ORDER BY FIELD(month, 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')";
        
                
                
                dStatements = dConnection.prepareStatement(emonthlyTotalQuery);
        dStatements.setString(1, loginUsername);
        dResultSets = dStatements.executeQuery();

        while (dResultSets.next()) {
            emonth = dResultSets.getString("month");
            emonthlyTotal = dResultSets.getDouble("monthlyTotal");

            emonthlyTotalsMap.put(emonth, emonthlyTotal);
        }

    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
    } finally {
        // Close the database connection
        try {
            if (dResultSets != null) dResultSets.close();
            if (dStatements != null) dStatements.close();
            if (dConnection != null) dConnection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Convert data to JSON format
    String ejsonMonthlyData = new Gson().toJson(emonthlyTotalsMap);
%>















<!--Barchart-->
<%
    String logInUsername = (String) session.getAttribute("username");
        if (logInUsername == null || logInUsername.isEmpty()) {
        // Handle the case when the username is not set in the session
        // For example, you can redirect the user to the login page
        response.sendRedirect("login.jsp"); // Adjust the URL accordingly
        return;
    }


    // Database connection parameters
    String dbUrl = "jdbc:mysql://localhost/expensetracker";
    String dbUsername = "root";
    String dbPassword = "";

    // JDBC variables
    Connection dbConnection = null;
    PreparedStatement dbStatements = null;
    ResultSet dbResultSets = null;

    // Map to store category-wise expenses with dates
    Map<String, Map<String, Double>> categoryExpensesMap = new HashMap<>();

    try {
        // Load the JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish a connection
        dbConnection = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);

        // Get category-wise expenses with dates for the logged-in user
        String categoryDateExpenseQuery = "SELECT expense_type, DATE_FORMAT(date, '%Y-%m-%d') AS expenseDate, SUM(amount) AS dailyExpense " +
                "FROM " + logInUsername +
                " WHERE username = ? AND MONTH(date) = MONTH(NOW()) " +
                "GROUP BY expense_type, expenseDate";
        dbStatements = dbConnection.prepareStatement(categoryDateExpenseQuery);
        dbStatements.setString(1, logInUsername);
        dbResultSets = dbStatements.executeQuery();

        while (dbResultSets.next()) {
            String category = dbResultSets.getString("expense_type");
            String date = dbResultSets.getString("expenseDate");
            double dailyExpense = dbResultSets.getDouble("dailyExpense");

            // If the category already exists in the map, add the date and expense to the existing entry
            // Otherwise, create a new entry in the map
            categoryExpensesMap.computeIfAbsent(category, k -> new HashMap<>()).put(date, dailyExpense);
        }

    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
    } finally {
        // Close the database connection
        try {
            if (dbResultSets != null) dbResultSets.close();
            if (dbStatements != null) dbStatements.close();
            if (dbConnection != null) dbConnection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Convert data to JSON format
    String jsonCategoryExpenses = new Gson().toJson(categoryExpensesMap);
%>


<%
    // Check if the user is logged in
    HttpSession userSession = request.getSession();
    String loggedInUsername = (String) userSession.getAttribute("username");

    // Redirect to the login page if not logged in
    if (loggedInUsername == null) {
        response.sendRedirect("login.jsp");
    }

    // Database connection parameters
    String url = "jdbc:mysql://localhost/expensetracker";
    String username = "root";
    String password = "";

    // JDBC variables
    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;

    // Initialize variables
    int userId = 0; // Assuming userId is an integer
    double totalExpense = 0;
    double weeklyExpense = 0;
    double monthlyExpense = 0;
    double totalDailyExpense = 0;
    boolean tableNotFound = false;
    Map<String, Double> categoryExpenses = new HashMap<>();

    try {
        // Load the JDBC driver
        Class.forName("com.mysql.cj.jdbc.Driver");

        // Establish a connection
        connection = DriverManager.getConnection(url, username, password);

        // Get monthly expense of the logged-in user
        String monthlyExpenseQuery = "SELECT SUM(amount) AS monthlyExpense FROM " + loggedInUsername +
                " WHERE username= ? AND MONTH(date) = MONTH(NOW())";
        preparedStatement = connection.prepareStatement(monthlyExpenseQuery);
        preparedStatement.setString(1, loggedInUsername);
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            monthlyExpense = resultSet.getDouble("monthlyExpense");
        }

        // Get weekly expense of the logged-in user
        String weeklyExpenseQuery = "SELECT IFNULL(SUM(amount), 0) as weekly_total " +
                "FROM " + loggedInUsername + " " +
                "WHERE username = ? AND WEEK(date) = WEEK(NOW()) " +
                "GROUP BY WEEK(date)";
        preparedStatement = connection.prepareStatement(weeklyExpenseQuery);
        preparedStatement.setString(1, loggedInUsername);
        resultSet = preparedStatement.executeQuery();

        while (resultSet.next()) {
            double weeklyTotal = resultSet.getDouble("weekly_total");
            weeklyExpense += weeklyTotal;
        }

        // Get daily expense of the logged-in user
        String dailyExpenseQuery = "SELECT IFNULL(SUM(amount), 0) as daily_total " +
                "FROM " + loggedInUsername +
                " WHERE username = ? AND date >= CURRENT_DATE() AND date < CURRENT_DATE() + INTERVAL 1 DAY";
        preparedStatement = connection.prepareStatement(dailyExpenseQuery);
        preparedStatement.setString(1, loggedInUsername);
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            totalDailyExpense = resultSet.getDouble("daily_total");
        }

        // Get user ID based on the username
        String userIdQuery = "SELECT id FROM " + loggedInUsername + " WHERE username = ?";
        preparedStatement = connection.prepareStatement(userIdQuery);
        preparedStatement.setString(1, loggedInUsername);
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            userId = resultSet.getInt("id");
        }

        // Get total expense of the logged-in user
        String totalExpenseQuery = "SELECT SUM(amount) AS totalExpense FROM " + loggedInUsername + " WHERE username= ?";
        preparedStatement = connection.prepareStatement(totalExpenseQuery);
        preparedStatement.setString(1, loggedInUsername);
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            totalExpense = resultSet.getDouble("totalExpense");
        }

        
        //Pie chart
        
        // Get category-wise monthly expense of the logged-in user
        String categoryMonthlyExpenseQuery = "SELECT expense_type, SUM(amount) AS MonthlyExpense " +
                "FROM " + loggedInUsername +
                " WHERE username = ? AND MONTH(date) = MONTH(NOW()) " +
                "GROUP BY expense_type";
        preparedStatement = connection.prepareStatement(categoryMonthlyExpenseQuery);
        preparedStatement.setString(1, loggedInUsername);
        resultSet = preparedStatement.executeQuery();

        while (resultSet.next()) {
            String category = resultSet.getString("expense_type");
            double monthlyExpenseForCategory = resultSet.getDouble("MonthlyExpense");
            categoryExpenses.put(category, monthlyExpenseForCategory);
        }

    } catch (SQLException e) {
        // Handle SQLException
        if (e.getSQLState().equals("42S02")) {
            // Table not found, set the flag to true
            tableNotFound = true;
        } else {
            // Other SQLException, print stack trace
            e.printStackTrace();
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    } finally {
        // Close the database connection
        try {
            if (resultSet != null) resultSet.close();
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>


        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <title>Expense Tracker</title>
        <link
            href="https://fonts.googleapis.com/css2?family=Cairo:wght@200;300;400;600;700;900&display=swap"
            rel="stylesheet"
            />
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <link rel="stylesheet" href="Component/tailwind.css" />
        <script src="https://cdn.jsdelivr.net/gh/alpine-collective/alpine-magic-helpers@0.5.x/dist/component.min.js"></script>
        <script src="https://cdn.jsdelivr.net/gh/alpinejs/alpine@v2.7.3/dist/alpine.min.js" defer></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels"></script>




    </head>

    <body >



        <div x-data="setup()" x-init="setColors(color);" :class="{ 'dark': isDark}">
            <div class="flex h-screen antialiased text-gray-900 bg-gray-100 dark:bg-dark dark:text-light">
                <!-- Loading screen -->


                <!-- Sidebar -->
                <aside class="flex-shrink-0 hidden w-64 bg-white border-r dark:border-primary-darker dark:bg-darker md:block">
                    <div class="flex flex-col h-full">
                        <!-- Sidebar links -->
                        <nav aria-label="Main" class="flex-1 px-2 py-4 space-y-2 overflow-y-hidden hover:overflow-y-auto">
                            <!-- Dashboards links -->
                            <div x-data="{ isActive: true, open: true}">
                                <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                <a
                                    href="dashboard.jsp"
                                    class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                    :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                    role="button"
                                    aria-haspopup="true"
                                    :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                    >
                                    <span aria-hidden="true">
                                        <svg
                                            class="w-5 h-5"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                                            />
                                        </svg>
                                    </span>
                                    <span class="ml-2 text-sm"> Dashboard</span>
                                    <span class="ml-auto" aria-hidden="true">
                                        <!-- active class 'rotate-180' -->
                                        <svg
                                            class="w-4 h-4 transition-transform transform"
                                            :class="{ 'rotate-180': open }"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </span>
                                </a>

                            </div>

                            <!-- Components links -->
                            <div x-data="{ isActive: false, open: false }">
                                <!-- active classes 'bg-primary-100 dark:bg-primary' -->
                                <a
                                    href="addExpense.jsp"

                                    class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                    :class="{ 'bg-primary-100 dark:bg-primary': isActive || open }"
                                    role="button"
                                    aria-haspopup="true"
                                    :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                    >
                                    <span aria-hidden="true">
                                        <svg
                                            class="w-5 h-5"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"
                                            />
                                        </svg>
                                    </span>
                                    <span class="ml-2 text-sm">Add Expense</span>
                                    <span aria-hidden="true" class="ml-auto">
                                        <!-- active class 'rotate-180' -->
                                        <svg
                                            class="w-4 h-4 transition-transform transform"
                                            :class="{ 'rotate-180': open }"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </span>
                                </a>

                            </div>

                            <!-- Pages links -->
                            <div x-data="{ isActive: false, open: false }">
                                <!-- active classes 'bg-primary-100 dark:bg-primary' -->
                                <a
                                    href="addWallet.jsp"



                                    class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                    :class="{ 'bg-primary-100 dark:bg-primary': isActive || open }"
                                    role="button"
                                    aria-haspopup="true"
                                    :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                    >
                                    <span aria-hidden="true">
                                        <svg
                                            class="w-5 h-5"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"
                                            />
                                        </svg>
                                    </span>
                                    <span class="ml-2 text-sm"> My Expenses</span>
                                    <span aria-hidden="true" class="ml-auto">
                                        <!-- active class 'rotate-180' -->
                                        <svg
                                            class="w-4 h-4 transition-transform transform"
                                            :class="{ 'rotate-180': open }"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </span>
                                </a>

                            </div>

                            <!-- Authentication links -->
                            <div x-data="{ isActive: false, open: false}">
                                <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                <a

                                    href="profile.jsp"

                                    class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                    :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                    role="button"
                                    aria-haspopup="true"
                                    :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                    >
                                    <span aria-hidden="true">
                                        <svg
                                            class="w-5 h-5"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                                            />
                                        </svg>
                                    </span>
                                    <span class="ml-2 text-sm"> Profile </span>
                                    <span aria-hidden="true" class="ml-auto">
                                        <!-- active class 'rotate-180' -->
                                        <svg
                                            class="w-4 h-4 transition-transform transform"
                                            :class="{ 'rotate-180': open }"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </span>
                                </a>

                            </div>

                            <!-- Layouts links -->
                            <div x-data="{ isActive: false, open: false}">
                                <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                <a
                                    href="settings.jsp"

                                    class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                    :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                    role="button"
                                    aria-haspopup="true"
                                    :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                    >
                                    <span aria-hidden="true">
                                        <svg
                                            class="w-5 h-5"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                                            />
                                        </svg>
                                    </span>
                                    <span class="ml-2 text-sm"> Settings</span>
                                    <span aria-hidden="true" class="ml-auto">
                                        <!-- active class 'rotate-180' -->
                                        <svg
                                            class="w-4 h-4 transition-transform transform"
                                            :class="{ 'rotate-180': open }"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </span>
                                </a>

                            </div>
                            <div x-data="{ isActive: false, open: false}">
                                <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                <a
                                    href="register.jsp"

                                    class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                    :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                    role="button"
                                    aria-haspopup="true"
                                    :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                    >
                                    <span aria-hidden="true">
                                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M14 5l7 7-7 7"></path>
                                        <path d="M2 12h19"></path>
                                        </svg>

                                    </span>
                                    <span class="ml-2 text-sm"> Log Out</span>
                                    <span aria-hidden="true" class="ml-auto">
                                        <!-- active class 'rotate-180' -->
                                        <svg
                                            class="w-4 h-4 transition-transform transform"
                                            :class="{ 'rotate-180': open }"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                        </svg>
                                    </span>
                                </a>

                            </div>
                        </nav>


                    </div>
                </aside>

                <div class="flex-1  " >
                    <!-- Navbar -->
                    <header class="relative bg-white dark:bg-darker">
                        <div class="flex items-center justify-between p-2 border-b dark:border-primary-darker">
                            <!-- Mobile menu button -->
                            <button
                                @click="isMobileMainMenuOpen = !isMobileMainMenuOpen"
                                class="p-1 transition-colors duration-200 rounded-md text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark md:hidden focus:outline-none focus:ring"
                                >
                                <span class="sr-only">Open main manu</span>
                                <span aria-hidden="true">
                                    <svg
                                        class="w-8 h-8"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke="currentColor"
                                        >
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                                    </svg>
                                </span>
                            </button>

                            <!-- Brand -->
                            <a
                                href="dashboard.jsp"
                                class="inline-block text-2xl font-bold tracking-wider font-mono text-primary-dark dark:text-light"
                                >
                                Expense Tracker
                            </a>

                            <!-- Mobile sub menu button -->
                            <button
                                @click="isMobileSubMenuOpen = !isMobileSubMenuOpen"
                                class="p-1 transition-colors duration-200 rounded-md text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark md:hidden focus:outline-none focus:ring"
                                >
                                <span class="sr-only">Open sub manu</span>
                                <span aria-hidden="true">
                                    <svg
                                        class="w-8 h-8"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke="currentColor"
                                        >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
                                        />
                                    </svg>
                                </span>
                            </button>

                            <!-- Desktop Right buttons -->

                            <nav aria-label="Secondary" class="hidden space-x-2 md:flex md:items-center">
                                <!-- Toggle dark theme button -->
                                <button aria-hidden="true" class="relative focus:outline-none" x-cloak @click="toggleTheme">
                                    <div
                                        class="w-12 h-6 transition rounded-full outline-none bg-primary-100 dark:bg-primary-lighter"
                                        ></div>
                                    <div
                                        class="absolute top-0 left-0 inline-flex items-center justify-center w-6 h-6 transition-all duration-150 transform scale-110 rounded-full shadow-sm"
                                        :class="{ 'translate-x-0 -translate-y-px  bg-white text-primary-dark': !isDark, 'translate-x-6 text-primary-100 bg-primary-darker': isDark }"
                                        >
                                        <svg
                                            x-show="!isDark"
                                            class="w-4 h-4"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
                                            />
                                        </svg>
                                        <svg
                                            x-show="isDark"
                                            class="w-4 h-4"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
                                            />
                                        </svg>
                                    </div>
                                </button>

                                <!-- Notification button -->
                                <button
                                    @click="openNotificationsPanel"
                                    class="p-2 transition-colors duration-200 rounded-full text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark focus:outline-none focus:bg-primary-100 dark:focus:bg-primary-dark focus:ring-primary-darker"
                                    >
                                    <span class="sr-only">Open Notification panel</span>
                                    <svg
                                        class="w-7 h-7"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke="currentColor"
                                        aria-hidden="true"
                                        >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                                        />
                                    </svg>
                                </button>

                                <!-- Search button -->
                                <button
                                    @click="openSearchPanel"
                                    class="p-2 transition-colors duration-200 rounded-full text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark focus:outline-none focus:bg-primary-100 dark:focus:bg-primary-dark focus:ring-primary-darker"
                                    >
                                    <span class="sr-only">Open search panel</span>
                                    <svg
                                        class="w-7 h-7"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke="currentColor"
                                        aria-hidden="true"
                                        >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                                        />
                                    </svg>
                                </button>

                                <!-- Settings button -->
                                <button
                                    @click="openSettingsPanel"
                                    class="p-2 transition-colors duration-200 rounded-full text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark focus:outline-none focus:bg-primary-100 dark:focus:bg-primary-dark focus:ring-primary-darker"
                                    >
                                    <span class="sr-only">Open settings panel</span>
                                    <svg
                                        class="w-7 h-7"
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke="currentColor"
                                        aria-hidden="true"
                                        >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                                        />
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                                        />
                                    </svg>
                                </button>

                                <!-- User avatar button -->
                                <div class="relative" x-data="{ open: false }">
                                    <button
                                        @click="open = !open; $nextTick(() => { if(open){ $refs.userMenu.focus() } })"
                                        type="button"
                                        aria-haspopup="true"
                                        :aria-expanded="open ? 'true' : 'false'"
                                        class="transition-opacity duration-200 rounded-full dark:opacity-75 dark:hover:opacity-100 focus:outline-none focus:ring dark:focus:opacity-100"
                                        >
                                        <span class="sr-only">User menu</span>
                                        <img class="w-10 h-10 rounded-full" src="https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"/>
                                    </button>

                                    <!-- User dropdown menu -->
                                    <div
                                        x-show="open"
                                        x-ref="userMenu"
                                        x-transition:enter="transition-all transform ease-out"
                                        x-transition:enter-start="translate-y-1/2 opacity-0"
                                        x-transition:enter-end="translate-y-0 opacity-100"
                                        x-transition:leave="transition-all transform ease-in"
                                        x-transition:leave-start="translate-y-0 opacity-100"
                                        x-transition:leave-end="translate-y-1/2 opacity-0"
                                        @click.away="open = false"
                                        @keydown.escape="open = false"
                                        class="absolute right-0 w-48 py-1 bg-white rounded-md shadow-lg top-12 ring-1 ring-black ring-opacity-5 dark:bg-dark focus:outline-none"
                                        tabindex="-1"
                                        role="menu"
                                        aria-orientation="vertical"
                                        aria-label="User menu"
                                        >
                                        <a
                                            href="profile.jsp"

                                            role="menuitem"
                                            class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-light dark:hover:bg-primary"
                                            >
                                            Your Profile
                                        </a>
                                        <a
                                            href="settings.jsp"


                                            role="menuitem"
                                            class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-light dark:hover:bg-primary"
                                            >
                                            Settings
                                        </a>
                                        <a
                                            href="logout.jsp"


                                            role="menuitem"
                                            class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-light dark:hover:bg-primary"
                                            >
                                            Logout
                                        </a>
                                    </div>
                                </div>
                            </nav>


                            <!-- Mobile sub menu -->
                            <nav
                                x-transition:enter="transition duration-200 ease-in-out transform sm:duration-500"
                                x-transition:enter-start="-translate-y-full opacity-0"
                                x-transition:enter-end="translate-y-0 opacity-100"
                                x-transition:leave="transition duration-300 ease-in-out transform sm:duration-500"
                                x-transition:leave-start="translate-y-0 opacity-100"
                                x-transition:leave-end="-translate-y-full opacity-0"
                                x-show="isMobileSubMenuOpen"
                                @click.away="isMobileSubMenuOpen = false"
                                class="absolute flex items-center p-4 bg-white rounded-md shadow-lg dark:bg-darker top-16 inset-x-4 md:hidden"
                                aria-label="Secondary"
                                >
                                <div class="space-x-2">
                                    <!-- Toggle dark theme button -->
                                    <button aria-hidden="true" class="relative focus:outline-none" x-cloak @click="toggleTheme">
                                        <div
                                            class="w-12 h-6 transition rounded-full outline-none bg-primary-100 dark:bg-primary-lighter"
                                            ></div>
                                        <div
                                            class="absolute top-0 left-0 inline-flex items-center justify-center w-6 h-6 transition-all duration-200 transform scale-110 rounded-full shadow-sm"
                                            :class="{ 'translate-x-0 -translate-y-px  bg-white text-primary-dark': !isDark, 'translate-x-6 text-primary-100 bg-primary-darker': isDark }"
                                            >
                                            <svg
                                                x-show="!isDark"
                                                class="w-4 h-4"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
                                                />
                                            </svg>
                                            <svg
                                                x-show="isDark"
                                                class="w-4 h-4"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
                                                />
                                            </svg>
                                        </div>
                                    </button>

                                    <!-- Notification button -->
                                    <button
                                        @click="openNotificationsPanel(); $nextTick(() => { isMobileSubMenuOpen = false })"
                                        class="p-2 transition-colors duration-200 rounded-full text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark focus:outline-none focus:bg-primary-100 dark:focus:bg-primary-dark focus:ring-primary-darker"
                                        >
                                        <span class="sr-only">Open notifications panel</span>
                                        <svg
                                            class="w-7 h-7"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            aria-hidden="true"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                                            />
                                        </svg>
                                    </button>

                                    <!-- Search button -->
                                    <button
                                        @click="openSearchPanel(); $nextTick(() => { $refs.searchInput.focus(); setTimeout(() => {isMobileSubMenuOpen= false}, 100) })"
                                        class="p-2 transition-colors duration-200 rounded-full text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark focus:outline-none focus:bg-primary-100 dark:focus:bg-primary-dark focus:ring-primary-darker"
                                        >
                                        <span class="sr-only">Open search panel</span>
                                        <svg
                                            class="w-7 h-7"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            aria-hidden="true"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                                            />
                                        </svg>
                                    </button>

                                    <!-- Settings button -->
                                    <button
                                        @click="openSettingsPanel(); $nextTick(() => { isMobileSubMenuOpen = false })"
                                        class="p-2 transition-colors duration-200 rounded-full text-primary-lighter bg-primary-50 hover:text-primary hover:bg-primary-100 dark:hover:text-light dark:hover:bg-primary-dark dark:bg-dark focus:outline-none focus:bg-primary-100 dark:focus:bg-primary-dark focus:ring-primary-darker"
                                        >
                                        <span class="sr-only">Open settings panel</span>
                                        <svg
                                            class="w-7 h-7"
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                            >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                                            />
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            stroke-width="2"
                                            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                                            />
                                        </svg>
                                    </button>
                                </div>

                                <!-- User avatar button -->
                                <div class="relative ml-auto" x-data="{ open: false }">
                                    <button
                                        @click="open = !open"
                                        type="button"
                                        aria-haspopup="true"
                                        :aria-expanded="open ? 'true' : 'false'"
                                        class="block transition-opacity duration-200 rounded-full dark:opacity-75 dark:hover:opacity-100 focus:outline-none focus:ring dark:focus:opacity-100"
                                        >
                                        <span class="sr-only">User menu</span>
                                        <img class="w-10 h-10 rounded-full" src="https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500" />
                                    </button>

                                    <!-- User dropdown menu -->
                                    <div
                                        x-show="open"
                                        x-transition:enter="transition-all transform ease-out"
                                        x-transition:enter-start="translate-y-1/2 opacity-0"
                                        x-transition:enter-end="translate-y-0 opacity-100"
                                        x-transition:leave="transition-all transform ease-in"
                                        x-transition:leave-start="translate-y-0 opacity-100"
                                        x-transition:leave-end="translate-y-1/2 opacity-0"
                                        @click.away="open = false"
                                        class="absolute right-0 w-48 py-1 origin-top-right bg-white rounded-md shadow-lg top-12 ring-1 ring-black ring-opacity-5 dark:bg-dark"
                                        role="menu"
                                        aria-orientation="vertical"
                                        aria-label="User menu"
                                        >
                                        <a


                                            href="profile.jsp"

                                            role="menuitem"
                                            class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-light dark:hover:bg-primary"
                                            >
                                            Your Profile
                                        </a>
                                        <a


                                            href="settings.jsp"

                                            role="menuitem"
                                            class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-light dark:hover:bg-primary"
                                            >
                                            Settings
                                        </a>
                                        <a
                                            href="logout.jsp"

                                            role="menuitem"
                                            class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-100 dark:text-light dark:hover:bg-primary"
                                            >
                                            Logout
                                        </a>
                                    </div>
                                </div>
                            </nav>
                        </div>
                        <!-- Mobile main manu -->
                        <div
                            class="border-b md:hidden dark:border-primary-darker"
                            x-show="isMobileMainMenuOpen"
                            @click.away="isMobileMainMenuOpen = false"
                            >
                            <nav aria-label="Main" class="px-2 py-4 space-y-2">
                                <!-- Dashboards links -->
                                <div x-data="{ isActive: true, open: true}">
                                    <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                    <a
                                        href="dashboard.jsp"


                                        class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                        :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                        role="button"
                                        aria-haspopup="true"
                                        :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                        >
                                        <span aria-hidden="true">
                                            <svg
                                                class="w-5 h-5"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                                                />
                                            </svg>
                                        </span>
                                        <span class="ml-2 text-sm"> Dashboard</span>
                                        <span class="ml-auto" aria-hidden="true">
                                            <!-- active class 'rotate-180' -->
                                            <svg
                                                class="w-4 h-4 transition-transform transform"
                                                :class="{ 'rotate-180': open }"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </span>
                                    </a>

                                </div>

                                <!-- Components links -->
                                <div x-data="{ isActive: false, open: false }">
                                    <!-- active classes 'bg-primary-100 dark:bg-primary' -->
                                    <a
                                        href="addExpense.jsp"


                                        class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                        :class="{ 'bg-primary-100 dark:bg-primary': isActive || open }"
                                        role="button"
                                        aria-haspopup="true"
                                        :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                        >
                                        <span aria-hidden="true">
                                            <svg
                                                class="w-5 h-5"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"
                                                />
                                            </svg>
                                        </span>
                                        <span class="ml-2 text-sm"> Add Expense </span>
                                        <span aria-hidden="true" class="ml-auto">
                                            <!-- active class 'rotate-180' -->
                                            <svg
                                                class="w-4 h-4 transition-transform transform"
                                                :class="{ 'rotate-180': open }"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </span>
                                    </a>

                                </div>

                                <!-- Pages links -->
                                <div x-data="{ isActive: false, open: false }">
                                    <!-- active classes 'bg-primary-100 dark:bg-primary' -->
                                    <a
                                        href=addWallet.jsp"

                                        class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                        :class="{ 'bg-primary-100 dark:bg-primary': isActive || open }"
                                        role="button"
                                        aria-haspopup="true"
                                        :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                        >
                                        <span aria-hidden="true">
                                            <svg
                                                class="w-5 h-5"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"
                                                />
                                            </svg>
                                        </span>
                                        <span class="ml-2 text-sm"> Wallet</span>
                                        <span aria-hidden="true" class="ml-auto">
                                            <!-- active class 'rotate-180' -->
                                            <svg
                                                class="w-4 h-4 transition-transform transform"
                                                :class="{ 'rotate-180': open }"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </span>
                                    </a>

                                </div>

                                <!-- Authentication links -->
                                <div x-data="{ isActive: false, open: false}">
                                    <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                    <a
                                        href="profile.jsp"

                                        class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                        :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                        role="button"
                                        aria-haspopup="true"
                                        :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                        >
                                        <span aria-hidden="true">
                                            <svg
                                                class="w-5 h-5"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                                                />
                                            </svg>
                                        </span>
                                        <span class="ml-2 text-sm"> Profile </span>
                                        <span aria-hidden="true" class="ml-auto">
                                            <!-- active class 'rotate-180' -->
                                            <svg
                                                class="w-4 h-4 transition-transform transform"
                                                :class="{ 'rotate-180': open }"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </span>
                                    </a>

                                </div>

                                <!-- Layouts links -->
                                <div x-data="{ isActive: false, open: false}">
                                    <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                    <a
                                        href="settings.jsp"

                                        class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                        :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                        role="button"
                                        aria-haspopup="true"
                                        :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                        >
                                        <span aria-hidden="true">
                                            <svg
                                                class="w-5 h-5"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                                                />
                                            </svg>
                                        </span>
                                        <span class="ml-2 text-sm"> Settings</span>
                                        <span aria-hidden="true" class="ml-auto">
                                            <!-- active class 'rotate-180' -->
                                            <svg
                                                class="w-4 h-4 transition-transform transform"
                                                :class="{ 'rotate-180': open }"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </span>
                                    </a>

                                </div>
                                <div x-data="{ isActive: false, open: false}">
                                    <!-- active & hover classes 'bg-primary-100 dark:bg-primary' -->
                                    <a
                                        href="logout.jsp"

                                        class="flex items-center p-2 text-gray-500 transition-colors rounded-md dark:text-light hover:bg-primary-100 dark:hover:bg-primary"
                                        :class="{'bg-primary-100 dark:bg-primary': isActive || open}"
                                        role="button"
                                        aria-haspopup="true"
                                        :aria-expanded="(open || isActive) ? 'true' : 'false'"
                                        >
                                        <span aria-hidden="true">
                                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <circle cx="12" cy="12" r="10" />
                                            <line x1="16.5" y1="7.5" x2="12" y2="12" />
                                            <line x1="12" y1="12" x2="16.5" y2="16.5" />
                                            <line x1="3" y1="3" x2="21" y2="21" />
                                            </svg>

                                        </span>
                                        <span class="ml-2 text-sm"> Log Out</span>
                                        <span aria-hidden="true" class="ml-auto">
                                            <!-- active class 'rotate-180' -->
                                            <svg
                                                class="w-4 h-4 transition-transform transform"
                                                :class="{ 'rotate-180': open }"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </span>
                                    </a>

                                </div>
                            </nav>
                        </div>
                    </header>   
                    <main >
                        <!-- Content header -->
                        <div class="flex items-center justify-between px-4 py-4 border-b lg:py-6 dark:border-primary-darker">
                            <h1 class="text-2xl font-semibold">Dashboard</h1>

                        </div>

                        <!-- Content -->

                        <div class="mt-2">
                            <% if (tableNotFound) { %>
                            <p class="pl-10 text-red-500">No expense data found. Start adding expenses to view reports.</p>
                            <% } %>



                            <!-- State cards -->
                            <div class="grid grid-cols-1 gap-8 p-4 lg:grid-cols-2 xl:grid-cols-4">
                                <!-- Value card -->

                                <div class="flex items-center justify-between p-4 bg-white rounded-md dark:bg-darker">
                                    <div>
                                        <h6
                                            class="text-xs font-medium leading-none tracking-wider text-gray-500 uppercase dark:text-primary-light"
                                            >
                                            Today Expense
                                        </h6>
                                        <span class="text-xl font-semibold">$ <%= totalDailyExpense %></span>
                                        <span class="inline-block px-2 py-px ml-2 text-xs text-white bg-red-400 rounded-md">
                                            total of today
                                        </span>
                                    </div>
                                    <div>
                                        <span>
                                            <svg
                                                class="w-12 h-12 text-gray-300 dark:text-primary-dark"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                                                />
                                            </svg>
                                        </span>
                                    </div>
                                </div>

                                <!-- Users card -->
                                <div class="flex items-center justify-between p-4 bg-white rounded-md dark:bg-darker">
                                    <div>
                                        <h6
                                            class="text-xs font-medium leading-none tracking-wider text-gray-500 uppercase dark:text-primary-light"
                                            >
                                            Weekly Expense
                                        </h6>
                                        <span class="text-xl font-semibold">$ <%= weeklyExpense %></span>
                                        <span class="inline-block px-2 py-px ml-2 text-xs text-green-500 bg-green-100 rounded-md">
                                            this week
                                        </span>
                                    </div>
                                    <div>
                                        <span>
                                            <svg
                                                class="w-12 h-12 text-gray-300 dark:text-primary-dark"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                                                />
                                            </svg>
                                        </span>
                                    </div>
                                </div>

                                <!-- Orders card -->
                                <div class="flex items-center justify-between p-4 bg-white rounded-md dark:bg-darker">
                                    <div>
                                        <h6
                                            class="text-xs font-medium leading-none tracking-wider text-gray-500 uppercase dark:text-primary-light"
                                            >
                                            Monthly Expense
                                        </h6>
                                        <span class="text-xl font-semibold">$ <%= monthlyExpense %></span>
                                        <span class="inline-block px-2 py-px ml-2 text-xs text-white bg-red-400 rounded-md outline-none border-none">
                                            Current month
                                        </span>
                                    </div>
                                    <div>
                                        <span>
                                            <svg
                                                class="w-12 h-12 text-gray-300 dark:text-primary-dark"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
                                                />
                                            </svg>
                                        </span>
                                    </div>
                                </div>

                                <!-- Tickets card -->
                                <div class="flex items-center justify-between p-4 bg-white rounded-md dark:bg-darker">
                                    <div>
                                        <h6
                                            class="text-xs font-medium leading-none tracking-wider text-gray-500 uppercase dark:text-primary-light"
                                            >
                                            Total Expense
                                        </h6>
                                        <span class="text-xl font-semibold">$ <%= totalExpense %> </span>
                                        <span class="inline-block px-2 py-px ml-2 text-xs text-white bg-red-400 rounded-md">
                                            total 
                                        </span>
                                    </div>
                                    <div>
                                        <span>
                                            <svg
                                                class="w-12 h-12 text-gray-300 dark:text-primary-dark"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"
                                                />
                                            </svg>
                                        </span>
                                    </div>
                                </div>




                            </div>


                            <!-- Charts -->
                            <div class="grid grid-cols-1 p-4 space-y-8 lg:gap-8 lg:space-y-0 lg:grid-cols-3">
                                <!-- Bar chart card -->
                                <div class=" col-span-2 bg-white rounded-md dark:bg-darker" x-data="{ isOn: false }">
                                    <!-- Card header -->
                                    <div class="flex items-center justify-between p-4 border-b dark:border-primary">
                                        <h4 class="text-lg font-semibold text-gray-500 dark:text-light">Daily Expense Chart</h4>
                         
                                    </div>
                                    <!-- Chart -->
                                    <div class=" relative pl-10 pr-10 pt-3  ">
                                        <canvas id="barChart" ></canvas>

                                    </div>
                                </div>

                                <!-- Doughnut chart card -->
                                <div class="bg-white rounded-md dark:bg-darker" x-data="{ isOn: false }">
                                    <!-- Card header -->
                                    <div class="flex items-center justify-between p-4 border-b dark:border-primary">
                                        <h4 class="text-lg font-semibold text-gray-500 dark:text-light">Monthly Category Wise Expense Chart  </h4>
                                   
                                    </div>
                                    <!-- Chart -->

                                    <div class=" p-4 h-72"><canvas  id="doughnutChart"></canvas></div>

                                </div>
                            </div>

                            <!-- Two grid columns -->
                            <div class="grid grid-cols-1 p-4 space-y-8 lg:gap-8 lg:space-y-0 lg:grid-cols-3">
                                <!-- Active users chart -->
                                <div class="col-span-1 bg-white rounded-md dark:bg-darker">
                                    <!-- Card header -->
                                    <div class="p-4 border-b dark:border-primary">
                                        <h4 class="text-lg font-semibold text-gray-500 dark:text-light">Active users right now</h4>
                                    </div>
                                    <p class="p-4">
                                        <span class="text-2xl font-medium text-gray-500 dark:text-light" id="usersCount">0</span>
                                        <span class="text-sm font-medium text-gray-500 dark:text-primary">Users</span>
                                    </p>
                                    <!-- Chart -->
                                    <div class="relative p-4">
                                        <canvas id="activeUsersChart"></canvas>
                                    </div>
                                </div>

                                <!-- Line chart card -->
                                <div class="col-span-2 bg-white rounded-md dark:bg-darker" x-data="{ isOn: false }">
                                    <!-- Card header -->
                                    <div class="flex items-center justify-between p-4 border-b dark:border-primary">
                                        <h4 class="text-lg font-semibold text-gray-500 dark:text-light">Monthly Total Expense</h4>
                                        <div class="flex items-center">
                                            <button
                                                class="relative focus:outline-none"
                                                x-cloak
                                                @click="isOn = !isOn; $parent.updateLineChart()"
                                                >
                                                <div
                                                    class="w-12 h-6 transition rounded-full outline-none bg-primary-100 dark:bg-primary-darker"
                                                    ></div>
                                                <div
                                                    class="absolute top-0 left-0 inline-flex items-center justify-center w-6 h-6 transition-all duration-200 ease-in-out transform scale-110 rounded-full shadow-sm"
                                                    :class="{ 'translate-x-0  bg-white dark:bg-primary-100': !isOn, 'translate-x-6 bg-primary-light dark:bg-primary': isOn }"
                                                    ></div>
                                            </button>
                                        </div>
                                    </div>
                                    <!-- Chart -->
                                    <div class="  ">
                                        <canvas id="lineChart"></canvas>
                                    </div>
                                </div>
                            </div>




                        </div>



                    </main>

                    <!-- Main footer -->
                    <footer
                        class="flex items-center justify-between p-4 bg-white border-t dark:bg-darker dark:border-primary-darker"
                        >
                        <div>ExP &copy; 2024</div>
                        <div>
                            Made by
                            <a href="#" target="_blank" class="text-blue-500 hover:underline"
                               >HackEath</a
                            >
                        </div>
                    </footer>







                </div>


                <!-- Panels -->

                <!-- Settings Panel -->
                <!-- Backdrop -->
                <div
                    x-transition:enter="transition duration-300 ease-in-out"
                    x-transition:enter-start="opacity-0"
                    x-transition:enter-end="opacity-100"
                    x-transition:leave="transition duration-300 ease-in-out"
                    x-transition:leave-start="opacity-100"
                    x-transition:leave-end="opacity-0"
                    x-show="isSettingsPanelOpen"
                    @click="isSettingsPanelOpen = false"
                    class="fixed inset-0 z-10 bg-primary-darker"
                    style="opacity: 0.5"
                    aria-hidden="true"
                    ></div>
                <!-- Panel -->
                <section
                    x-transition:enter="transition duration-300 ease-in-out transform sm:duration-500"
                    x-transition:enter-start="translate-x-full"
                    x-transition:enter-end="translate-x-0"
                    x-transition:leave="transition duration-300 ease-in-out transform sm:duration-500"
                    x-transition:leave-start="translate-x-0"
                    x-transition:leave-end="translate-x-full"
                    x-ref="settingsPanel"
                    tabindex="-1"
                    x-show="isSettingsPanelOpen"
                    @keydown.escape="isSettingsPanelOpen = false"
                    class="fixed inset-y-0 right-0 z-20 w-full max-w-xs bg-white shadow-xl dark:bg-darker dark:text-light sm:max-w-md focus:outline-none"
                    aria-labelledby="settinsPanelLabel"
                    >
                    <div class="absolute left-0 p-2 transform -translate-x-full">
                        <!-- Close button -->
                        <button
                            @click="isSettingsPanelOpen = false"
                            class="p-2 text-white rounded-md focus:outline-none focus:ring"
                            >
                            <svg
                                class="w-5 h-5"
                                xmlns="http://www.w3.org/2000/svg"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                                >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                    <!-- Panel content -->
                    <div class="flex flex-col h-screen">
                        <!-- Panel header -->
                        <div
                            class="flex flex-col items-center justify-center flex-shrink-0 px-4 py-8 space-y-4 border-b dark:border-primary-dark"
                            >
                            <span aria-hidden="true" class="text-gray-500 dark:text-primary">
                                <svg
                                    class="w-8 h-8"
                                    xmlns="http://www.w3.org/2000/svg"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                    stroke="currentColor"
                                    >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 110-4m0 4v2m0-6V4"
                                    />
                                </svg>
                            </span>
                            <h2 id="settinsPanelLabel" class="text-xl font-medium text-gray-500 dark:text-light">Settings</h2>
                        </div>
                        <!-- Content -->
                        <div class="flex-1 overflow-hidden hover:overflow-y-auto">
                            <!-- Theme -->
                            <div class="p-4 space-y-4 md:p-8">
                                <h6 class="text-lg font-medium text-gray-400 dark:text-light">Mode</h6>
                                <div class="flex items-center space-x-8">
                                    <!-- Light button -->
                                    <button
                                        @click="setLightTheme"
                                        class="flex items-center justify-center px-4 py-2 space-x-4 transition-colors border rounded-md hover:text-gray-900 hover:border-gray-900 dark:border-primary dark:hover:text-primary-100 dark:hover:border-primary-light focus:outline-none focus:ring focus:ring-primary-lighter focus:ring-offset-2 dark:focus:ring-offset-dark dark:focus:ring-primary-dark"
                                        :class="{ 'border-gray-900 text-gray-900 dark:border-primary-light dark:text-primary-100': !isDark, 'text-gray-500 dark:text-primary-light': isDark }"
                                        >
                                        <span>
                                            <svg
                                                class="w-6 h-6"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
                                                />
                                            </svg>
                                        </span>
                                        <span>Light</span>
                                    </button>

                                    <!-- Dark button -->
                                    <button
                                        @click="setDarkTheme"
                                        class="flex items-center justify-center px-4 py-2 space-x-4 transition-colors border rounded-md hover:text-gray-900 hover:border-gray-900 dark:border-primary dark:hover:text-primary-100 dark:hover:border-primary-light focus:outline-none focus:ring focus:ring-primary-lighter focus:ring-offset-2 dark:focus:ring-offset-dark dark:focus:ring-primary-dark"
                                        :class="{ 'border-gray-900 text-gray-900 dark:border-primary-light dark:text-primary-100': isDark, 'text-gray-500 dark:text-primary-light': !isDark }"
                                        >
                                        <span>
                                            <svg
                                                class="w-6 h-6"
                                                xmlns="http://www.w3.org/2000/svg"
                                                fill="none"
                                                viewBox="0 0 24 24"
                                                stroke="currentColor"
                                                >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                stroke-width="2"
                                                d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
                                                />
                                            </svg>
                                        </span>
                                        <span>Dark</span>
                                    </button>
                                </div>
                            </div>

                            <!-- Colors -->
                            <div class="p-4 space-y-4 md:p-8">
                                <h6 class="text-lg font-medium text-gray-400 dark:text-light">Colors</h6>
                                <div>
                                    <button
                                        @click="setColors('cyan')"
                                        class="w-10 h-10 rounded-full"
                                        style="background-color: var(--color-cyan)"
                                        ></button>
                                    <button
                                        @click="setColors('teal')"
                                        class="w-10 h-10 rounded-full"
                                        style="background-color: var(--color-teal)"
                                        ></button>
                                    <button
                                        @click="setColors('green')"
                                        class="w-10 h-10 rounded-full"
                                        style="background-color: var(--color-green)"
                                        ></button>
                                    <button
                                        @click="setColors('fuchsia')"
                                        class="w-10 h-10 rounded-full"
                                        style="background-color: var(--color-fuchsia)"
                                        ></button>
                                    <button
                                        @click="setColors('blue')"
                                        class="w-10 h-10 rounded-full"
                                        style="background-color: var(--color-blue)"
                                        ></button>
                                    <button
                                        @click="setColors('violet')"
                                        class="w-10 h-10 rounded-full"
                                        style="background-color: var(--color-violet)"
                                        ></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Notification panel -->
                <!-- Backdrop -->
                <div
                    x-transition:enter="transition duration-300 ease-in-out"
                    x-transition:enter-start="opacity-0"
                    x-transition:enter-end="opacity-100"
                    x-transition:leave="transition duration-300 ease-in-out"
                    x-transition:leave-start="opacity-100"
                    x-transition:leave-end="opacity-0"
                    x-show="isNotificationsPanelOpen"
                    @click="isNotificationsPanelOpen = false"
                    class="fixed inset-0 z-10 bg-primary-darker"
                    style="opacity: 0.5"
                    aria-hidden="true"
                    ></div>
                <!-- Panel -->
                <section
                    x-transition:enter="transition duration-300 ease-in-out transform sm:duration-500"
                    x-transition:enter-start="-translate-x-full"
                    x-transition:enter-end="translate-x-0"
                    x-transition:leave="transition duration-300 ease-in-out transform sm:duration-500"
                    x-transition:leave-start="translate-x-0"
                    x-transition:leave-end="-translate-x-full"
                    x-ref="notificationsPanel"
                    x-show="isNotificationsPanelOpen"
                    @keydown.escape="isNotificationsPanelOpen = false"
                    tabindex="-1"
                    aria-labelledby="notificationPanelLabel"
                    class="fixed inset-y-0 z-20 w-full max-w-xs bg-white dark:bg-darker dark:text-light sm:max-w-md focus:outline-none"
                    >
                    <div class="absolute right-0 p-2 transform translate-x-full">
                        <!-- Close button -->
                        <button
                            @click="isNotificationsPanelOpen = false"
                            class="p-2 text-white rounded-md focus:outline-none focus:ring"
                            >
                            <svg
                                class="w-5 h-5"
                                xmlns="http://www.w3.org/2000/svg"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                                >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                    <div class="flex flex-col h-screen" x-data="{ activeTabe: 'action' }">
                        <!-- Panel header -->
                        <div class="flex-shrink-0">
                            <div class="flex items-center justify-between px-4 pt-4 border-b dark:border-primary-darker">
                                <h2 id="notificationPanelLabel" class="pb-4 font-semibold">Notifications</h2>
                                <div class="space-x-2">
                                    <button
                                        @click.prevent="activeTabe = 'action'"
                                        class="px-px pb-4 transition-all duration-200 transform translate-y-px border-b focus:outline-none"
                                        :class="{'border-primary-dark dark:border-primary': activeTabe == 'action', 'border-transparent': activeTabe != 'action'}"
                                        >
                                        Action
                                    </button>
                        
                                </div>
                            </div>
                        </div>

                        <!-- Panel content (tabs) -->
                        <div class="flex-1 pt-4 overflow-y-hidden hover:overflow-y-auto">
                            <!-- Action tab -->
                            <div class="space-y-4" x-show.transition.in="activeTabe == 'action'">

                                <template x-for="i in 5" x-key="i">
                                    <a href="#" class="block">
                                        <div class="flex px-4 space-x-4">
                                            <div class="relative flex-shrink-0">
                                                <span
                                                    class="inline-block p-2 overflow-visible rounded-full bg-primary-50 text-primary-light dark:bg-primary-darker"
                                                    >
                                                    <svg
                                                        class="w-7 h-7"
                                                        xmlns="http://www.w3.org/2000/svg"
                                                        fill="none"
                                                        viewBox="0 0 24 24"
                                                        stroke="currentColor"
                                                        >
                                                    <path
                                                        stroke-linecap="round"
                                                        stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
                                                        />
                                                    </svg>
                                                </span>
                                                <div
                                                    class="absolute h-24 p-px -mt-3 -ml-px bg-primary-50 left-1/2 dark:bg-primary-darker"
                                                    ></div>
                                            </div>
                                            <div class="flex-1 overflow-hidden">
                                                <h5 class="text-sm font-semibold text-gray-600 dark:text-light">
                                                    New project "Expense Tracker" created
                                                </h5>
                                                <p class="text-sm font-normal text-gray-400 truncate dark:text-primary-lighter">
                                                    Looks like there might be a new theme soon
                                                </p>
                                                <span class="text-sm font-normal text-gray-400 dark:text-primary-light"> 9h ago </span>
                                            </div>
                                        </div>
                                    </a>
                                </template>
                            </div>

                            <!-- User tab -->
                            <div class="space-y-4" x-show.transition.in="activeTabe == 'user'">

                                <template x-for="i in 5" x-key="i">
                                    <a href="#" class="block">
                                        <div class="flex px-4 space-x-4">
                                            <div class="relative flex-shrink-0">
                                                <span class="relative z-10 inline-block overflow-visible rounded-ful">
                                                    <img
                                                        class="object-cover rounded-full w-9 h-9"
                                                        src="build/images/avatar.jpg"
                                                        alt="H"
                                                        />
                                                </span>
                                                <div
                                                    class="absolute h-24 p-px -mt-3 -ml-px bg-primary-50 left-1/2 dark:bg-primary-darker"
                                                    ></div>
                                            </div>
                                            <div class="flex-1 overflow-hidden">
                                                <h5 class="text-sm font-semibold text-gray-600 dark:text-light">Hackeath</h5>
                                                <p class="text-sm font-normal text-gray-400 truncate dark:text-primary-lighter">
                                                    Release new version of Expense Tracker
                                                </p>
                                                <span class="text-sm font-normal text-gray-400 dark:text-primary-light"> 20d ago </span>
                                            </div>
                                        </div>
                                    </a>
                                </template>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Search panel -->
                <!-- Backdrop -->
                <div
                    x-transition:enter="transition duration-300 ease-in-out"
                    x-transition:enter-start="opacity-0"
                    x-transition:enter-end="opacity-100"
                    x-transition:leave="transition duration-300 ease-in-out"
                    x-transition:leave-start="opacity-100"
                    x-transition:leave-end="opacity-0"
                    x-show="isSearchPanelOpen"
                    @click="isSearchPanelOpen = false"
                    class="fixed inset-0 z-10 bg-primary-darker"
                    style="opacity: 0.5"
                    aria-hidden="ture"
                    ></div>
                <!-- Panel -->
                <section
                    x-transition:enter="transition duration-300 ease-in-out transform sm:duration-500"
                    x-transition:enter-start="-translate-x-full"
                    x-transition:enter-end="translate-x-0"
                    x-transition:leave="transition duration-300 ease-in-out transform sm:duration-500"
                    x-transition:leave-start="translate-x-0"
                    x-transition:leave-end="-translate-x-full"
                    x-show="isSearchPanelOpen"
                    @keydown.escape="isSearchPanelOpen = false"
                    class="fixed inset-y-0 z-20 w-full max-w-xs bg-white shadow-xl dark:bg-darker dark:text-light sm:max-w-md focus:outline-none"
                    >
                    <div class="absolute right-0 p-2 transform translate-x-full">
                        <!-- Close button -->
                        <button @click="isSearchPanelOpen = false" class="p-2 text-white rounded-md focus:outline-none focus:ring">
                            <svg
                                class="w-5 h-5"
                                xmlns="http://www.w3.org/2000/svg"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                                >
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>

                    <h2 class="sr-only">Search panel</h2>
                    <!-- Panel content -->
                    <div class="flex flex-col h-screen">
                        
                                            
                        <!-- Panel header (Search input) -->
                        <div
                            class="relative flex-shrink-0 px-4 py-8 text-gray-400 border-b dark:border-primary-darker dark:focus-within:text-light focus-within:text-gray-700"
                            >
                      
    
        
        <form onsubmit="searchExpenses(); return false;" class="mb-4">
            <input type="text" id="searchInput" placeholder="Enter keyword" class="focus:outline-none border rounded p-2">
            <button type="submit" class="bg-blue-500 text-white p-2 ml-2">Search</button>
        </form>

        <p id="error" class="text-red-500"></p>

        <div id="expenseLists"></div>
 
            
                        </div>

                        <!-- Panel content (Search result) -->
                   
                    </div>
                </section>
            </div>
        </div>


        <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.bundle.min.js"></script>
  <script>
        var expenses = [];
        var searchInput;
        var errorContainer;
        var listContainer;

        function init() {
            searchInput = document.getElementById("searchInput");
            errorContainer = document.getElementById("error");
            listContainer = document.getElementById("expenseLists");

            // Add an event listener for input field changes
            searchInput.addEventListener("input", searchExpenses);
        }

        function searchExpenses() {
            var keyword = searchInput.value.trim();

            // Validation: Check if the keyword is not empty
            if (keyword === "") {
                errorContainer.textContent = "Please enter a keyword.";
                listContainer.innerHTML = ""; // Clear the previous results
                return;
            }

            errorContainer.textContent = "";

            fetch("fetchExpenses.jsp", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                body: "keyword=" + encodeURIComponent(keyword),
            })
                .then(response => response.json())
                .then(data => {
                    console.log("Received data:", data);

                    if (Array.isArray(data)) {
                        expenses = data;
                        displayExpenseList(expenses);
                    } else {
                        console.error("Invalid data format received from server.");
                        errorContainer.textContent = "Error fetching expenses.";
                    }
                })
                .catch(error => {
                    console.error("Error fetching expenses:", error);
                    errorContainer.textContent = "Error fetching expenses.";
                });
        }

        function displayExpenseList(expenses) {
            listContainer.innerHTML = "";

            if (expenses.length === 0) {
                errorContainer.textContent = "No results found.";
                return;
            }

            for (var i = 0; i < expenses.length; i++) {
                var expense = expenses[i];

                // Create list item
                var listItem = document.createElement("div");
                listItem.classList.add("mb-4", "p-4", "bg-white", "rounded", "shadow");

                // Display expense details
                listItem.innerHTML = "<div class='flex justify-between'>" +
                                        "<div class='text-black'>Date: " + expense['date'] + " | Amount: " + expense.amount + "</div>" +
                                        "<div class='text-red-500 cursor-pointer' onclick='removeExpense(" + i + ")'>&times;</div>" +
                                    "</div>" +
                                    "<div class='mt-2 cursor-pointer' onclick='showExpenseDetails(" + i + ")'>" +
                                        "<strong>Expense Title:</strong> " + expense.expenseType + " <br>" +
                                        "<strong>Description:</strong> " + expense.description +
                                    "</div>" +
                                    "<div id='details" + i + "' class='hidden mt-2 bg-gray-100 p-4 rounded'>" +
                                        "<strong>Expense Title:</strong> " + expense.expenseType + " <br>" +
                                        "<strong>Description:</strong> " + expense.description + " <br>" +
                                        "<strong>Price:</strong> " + expense.amount + " <br>" +
                                        "<strong>Date:</strong> " + expense.date +
                                    "</div>";

                listContainer.appendChild(listItem);
            }
        }

        function showExpenseDetails(index) {
            var detailsContainer = document.getElementById(`details${index}`);
            detailsContainer.classList.toggle("hidden");
        }

        function removeExpense(index) {
            expenses.splice(index, 1);
            displayExpenseList(expenses);
        }

        // Initialize variables on page load
        window.onload = init;
    </script>
        <script>
            const colors = {
                primary: 'rgba(75, 192, 192, 0.2)',
                primaryLight: 'rgba(75, 192, 192, 0.4)',
                primaryLighter: 'rgba(75, 192, 192, 0.6)',
                primaryDark: 'rgba(75, 192, 192, 1)',
                primaryDarker: 'rgba(75, 192, 192, 1.5)',
            };

            var categories = [
            <%
            for (String category : categoryExpenses.keySet()) {
                out.println("'" + category.replace("'", "\\'") + "',");
            }
            %>
            ];

            var expenses = <%= new java.util.ArrayList(categoryExpenses.values()) %>;



            // Your Chart.js code
            var doughnutChart = new Chart(document.getElementById('doughnutChart'), {
                type: 'doughnut',
                data: {
                    labels: categories,
                    datasets: [
                        {
                            data: expenses,
                            backgroundColor: getRandomColors(expenses.length),
                            hoverBackgroundColor: getRandomColors(expenses.length),
                            borderWidth: 0,
                            weight: 5
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        position: 'bottom'
                    },
                    title: {
                        display: true
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true
                    },
                },
            });

            // Function to generate random colors
            function getRandomColors(count) {
                var colors = [];
                for (var i = 0; i < count; i++) {
                    colors.push(getRandomColor());
                }
                return colors;
            }

            // Function to generate a random color
            function getRandomColor() {
                var letters = '0123456789ABCDEF';
                var color = '#';
                for (var i = 0; i < 6; i++) {
                    color += letters[Math.floor(Math.random() * 16)];
                }
                return color;
            }



            const random = (max = 100) => {
                return Math.round(Math.random() * max) + 20;
            };
            const randomData = () => {
                return [
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random(),
                    random()
                ];
            };
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];


            //Bar chart
function renderCategoryBarChart(data) {
    var ctx = document.getElementById('barChart').getContext('2d');
    var datasets = [];

    // Check if data is empty or undefined
    if (!data || Object.keys(data).length === 0) {
        // Handle the case when there is no data
        console.error('No data available for rendering the bar chart.');
        return;
    }

    // Extract unique dates for labeling the x-axis
    var dates = [...new Set(Object.keys(data).flatMap(category => Object.keys(data[category])))];

    // Prepare datasets for each category
    for (var category in data) {
        if (data.hasOwnProperty(category)) {
            var expenses = data[category];
            var dataset = {
                label: category,
                data: dates.map(date => expenses[date] || 0),
                backgroundColor: 'rgba(' + getRandomColor() + ', 1)', // Adjust the color as needed
                borderColor: 'rgba(' + getRandomColor() + ', 0.1)',
                borderWidth: 1
            };
            datasets.push(dataset);
        }
    }

    // Set the width and height of the canvas element
        var chartContainer = document.getElementById('lineChart');
    chartContainer.className = 'w-full h-72 '; 
    
        // Set your desired height

    var chart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: dates,
            datasets: datasets
        },
        options: {
            scales: {
                x: {
                    title: {
                        display: true,
                        text: 'Date'
                    }
                },
                y: {
                    beginAtZero: true
                }
            }
        }
    });

    function getRandomColor() {
        var r = Math.floor(Math.random() * 256);
        var g = Math.floor(Math.random() * 256);
        var b = Math.floor(Math.random() * 256);
        return r + ',' + g + ',' + b;
    }
}


            renderCategoryBarChart(<%= jsonCategoryExpenses %>);



            function renderMonthlyTotalChart(data) {
                var ctx = document.getElementById('lineChart').getContext('2d');
                var datasets = [];

                // Check if data is empty or undefined
                if (!data || Object.keys(data).length === 0) {
                    // Handle the case when there is no data
                    console.error('No data available for rendering the line chart.');
                    return;
                }

                // Prepare datasets with random colors for each month
                var months = Object.keys(data);
                var randomColors = generateRandomColors(months.length);
                
            var chartContainer = document.getElementById('lineChart');
    chartContainer.className = 'w-full lg:96 h-full'; 
                

                var dataset = {
                    label: 'Monthly Total',
                    data: [],
                    fill: false, // Set to false for a line chart
                    borderColor: randomColors[0], // Use the color of the first month for the line
                    borderWidth: 2,
                    pointBackgroundColor: randomColors[0], // Add point background color
                    pointBorderWidth: 2,
                    pointRadius: 4,
                };

                months.forEach(function (month) {
                    dataset.data.push(data[month]);
                });

                datasets.push(dataset);

                var chart = new Chart(ctx, {
                    type: 'line', // Change to line chart
                    data: {
                        labels: months,
                        datasets: datasets
                    },
                    options: {
                        scales: {
                            y: {
                                beginAtZero: true
                            }
                        }
                    }
                });
            }

            // Call the function with the monthly totals data
            renderMonthlyTotalChart(<%= ejsonMonthlyData %>);

            // Function to generate an array of random colors
            function generateRandomColors(count) {
                var colors = [];
                for (var i = 0; i < count; i++) {
                    colors.push('#' + Math.floor(Math.random() * 16777215).toString(16));
                }
                return colors;
            }












            // Active users chart
            const activeUsersChart = new Chart(document.getElementById('activeUsersChart'), {
                type: 'bar',
                data: {
                    labels: [...randomData(), ...randomData()],
                    datasets: [
                        {
                            data: [...randomData(), ...randomData()],
                            backgroundColor: colors.primaryDark,
                            borderWidth: 0,
                            categoryPercentage: 1,
                        },
                    ],
                },
                options: {
                    scales: {
                        yAxes: [
                            {
                                display: false,
                                gridLines: false,
                            },
                        ],
                        xAxes: [
                            {
                                display: false,
                                gridLines: false,
                            },
                        ],
                    },
                    ticks: {
                        padding: 10,
                    },
                    cornerRadius: 2,
                    maintainAspectRatio: false,
                    legend: {
                        display: false,
                    },
                    tooltips: {
                        prefix: 'Users',
                        bodySpacing: 4,
                        footerSpacing: 4,
                        hasIndicator: true,
                        mode: 'index',
                        intersect: true,
                    },
                    hover: {
                        mode: 'nearest',
                        intersect: true,
                    },
                },
            });





            // Function to generate an array of random colors
            function generateRandomColors(count) {
                var colors = [];
                for (var i = 0; i < count; i++) {
                    colors.push('#' + Math.floor(Math.random() * 16777215).toString(16));
                }
                return colors;
            }


            let randomUserCount = 0;
            const usersCount = document.getElementById('usersCount');
            const fakeUsersCount = () => {
                randomUserCount = random();
                activeUsersChart.data.datasets[0].data.push(randomUserCount);
                activeUsersChart.data.datasets[0].data.splice(0, 1);
                activeUsersChart.update();
                usersCount.innerText = randomUserCount;
            };
            setInterval(() => {
                fakeUsersCount();
            }, 1000);
            //Theme
            const setup = () => {
                const getTheme = () => {
                    if (window.localStorage.getItem('dark')) {
                        return JSON.parse(window.localStorage.getItem('dark'))
                    }

                    return !!window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
                }

                const setTheme = (value) => {
                    window.localStorage.setItem('dark', value)
                }

                const getColor = () => {
                    if (window.localStorage.getItem('color')) {
                        return window.localStorage.getItem('color')
                    }
                    return 'cyan'
                }

                const setColors = (color) => {
                    const root = document.documentElement
                    root.style.setProperty('--color-primary', `var(--color-${color})`)
                    root.style.setProperty('--color-primary-50', `var(--color-${color}-50)`)
                    root.style.setProperty('--color-primary-100', `var(--color-${color}-100)`)
                    root.style.setProperty('--color-primary-light', `var(--color-${color}-light)`)
                    root.style.setProperty('--color-primary-lighter', `var(--color-${color}-lighter)`)
                    root.style.setProperty('--color-primary-dark', `var(--color-${color}-dark)`)
                    root.style.setProperty('--color-primary-darker', `var(--color-${color}-darker)`)
                    this.selectedColor = color
                    window.localStorage.setItem('color', color)
                    //
                }

                const updateBarChart = (on) => {
                    const data = {
                        data: randomData(),
                        backgroundColor: 'rgb(207, 250, 254)',
                    }
                    if (on) {
                        barChart.data.datasets.push(data)
                        barChart.update()
                    } else {
                        barChart.data.datasets.splice(1)
                        barChart.update()
                    }
                }

                const updateDoughnutChart = (on) => {
                    const data = random()
                    const color = 'rgb(207, 250, 254)'
                    if (on) {
                        doughnutChart.data.labels.unshift('Seb')
                        doughnutChart.data.datasets[0].data.unshift(data)
                        doughnutChart.data.datasets[0].backgroundColor.unshift(color)
                        doughnutChart.update()
                    } else {
                        doughnutChart.data.labels.splice(0, 1)
                        doughnutChart.data.datasets[0].data.splice(0, 1)
                        doughnutChart.data.datasets[0].backgroundColor.splice(0, 1)
                        doughnutChart.update()
                    }
                }

                const updateLineChart = () => {
                    lineChart.data.datasets[0].data.reverse()
                    lineChart.update()
                }

                return {
                    loading: true,
                    isDark: getTheme(),
                    toggleTheme() {
                        this.isDark = !this.isDark
                        setTheme(this.isDark)
                    },
                    setLightTheme() {
                        this.isDark = false
                        setTheme(this.isDark)
                    },
                    setDarkTheme() {
                        this.isDark = true
                        setTheme(this.isDark)
                    },
                    color: getColor(),
                    selectedColor: 'cyan',
                    setColors,
                    toggleSidbarMenu() {
                        this.isSidebarOpen = !this.isSidebarOpen
                    },
                    isSettingsPanelOpen: false,
                    openSettingsPanel() {
                        this.isSettingsPanelOpen = true
                        this.$nextTick(() => {
                            this.$refs.settingsPanel.focus()
                        })
                    },
                    isNotificationsPanelOpen: false,
                    openNotificationsPanel() {
                        this.isNotificationsPanelOpen = true
                        this.$nextTick(() => {
                            this.$refs.notificationsPanel.focus()
                        })
                    },
                    isSearchPanelOpen: false,
                    openSearchPanel() {
                        this.isSearchPanelOpen = true
                        this.$nextTick(() => {
                            this.$refs.searchInput.focus()
                        })
                    },
                    isMobileSubMenuOpen: false,
                    openMobileSubMenu() {
                        this.isMobileSubMenuOpen = true
                        this.$nextTick(() => {
                            this.$refs.mobileSubMenu.focus()
                        })
                    },
                    isMobileMainMenuOpen: false,
                    openMobileMainMenu() {
                        this.isMobileMainMenuOpen = true
                        this.$nextTick(() => {
                            this.$refs.mobileMainMenu.focus()
                        })
                    },
                    updateBarChart,
                    updateDoughnutChart,
                    updateLineChart,
                }
            }
            //Profile

            if (typeof setup === 'function') {
                setup();
            }


            function showForm(formId) {
                // Hide all forms
                document.getElementById('edit-profile-form').style.display = 'none';
                document.getElementById('change-name-form').style.display = 'none';
                document.getElementById('change-password-form').style.display = 'none';
                // Show the selected form
                document.getElementById(formId).style.display = 'block';
            }

            function saveProfile() {
                // Implement profile saving logic here (e.g., update the image source)
                const newImageUrl = document.getElementById('new-image-url').value;
                document.getElementById('profile-image').src = newImageUrl;
                // Hide the form
                document.getElementById('edit-profile-form').style.display = 'none';
            }

            function saveName() {
                // Implement name saving logic here (e.g., update the displayed name)
                const newName = document.getElementById('new-name').value;
                // Update the displayed name
                document.getElementById('profile-container').getElementsByTagName('h1')[0].innerText = newName;
                // Hide the form
                document.getElementById('change-name-form').style.display = 'none';
            }

            function savePassword() {
                // Implement password saving logic here (e.g., update the password)
                const newPassword = document.getElementById('new-password').value;
                // Update the password (replace this line with actual logic)
                alert('Password updated: ' + newPassword);
                // Hide the form
                document.getElementById('change-password-form').style.display = 'none';
            }

        </script>




    </body>
</html>
