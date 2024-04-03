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
    ResultSet resultSet = null;

    try {
        // Establish a database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

        // Retrieve the expense details for editing
        String selectQuery = "SELECT * FROM " + loggedInUsername + " WHERE id = ?";
        preparedStatement = connection.prepareStatement(selectQuery);
        preparedStatement.setInt(1, expenseId);
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            // Retrieve necessary data for pre-filling the form
            String expense = resultSet.getString("expense");
            double amount = resultSet.getDouble("amount");
            String description = resultSet.getString("description");
            String date = resultSet.getString("date");

            // Now, you can use these values to pre-fill your form for editing
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

        <link rel="stylesheet" href="Component/tailwind.css" />
        <script src="https://cdn.jsdelivr.net/gh/alpine-collective/alpine-magic-helpers@0.5.x/dist/component.min.js"></script>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.2.1/datepicker.min.js"></script>

        <script src="https://cdn.jsdelivr.net/npm/alpinejs@2.8.2/dist/alpine.min.js" defer></script>
        <script src="https://cdn.tailwindcss.com"></script>
    


        <script src="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.2.1/flowbite.min.js"></script>


    </head>
    <body class="font-mono">
        <div x-data="setup()" x-init="$refs.loading.classList.add('hidden'); setColors(color);" :class="{ 'dark': isDark}">
            <div class="flex h-screen antialiased text-gray-900 bg-gray-100 dark:bg-dark dark:text-light">
                <!-- Loading screen -->
                <div
                    x-ref="loading"
                    class="fixed inset-0 z-50 flex items-center justify-center text-2xl font-semibold text-white bg-primary-darker"
                    >
                    Loading.....
                </div>

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

                <div class="flex-1 h-full " >
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
                                href="index.jsp"
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
                                            href="signup.jsp"


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
                                            href="signup.jsp"

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
                                        href="signup.jsp"

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
                    <main class=" h-screen">
                        <!-- Content header -->
                        <div class="flex items-center justify-between px-4 py-4 border-b lg:py-6 dark:border-primary-darker">
                        <h2 class="text-2xl font-semibold mb-4">Edit Expense</h2>
                            
                            
 

                        </div>
   <div class="container mx-auto mt-8 p-8 bg-white shadow-lg max-w-md">
       

 <form action="updateExpense.jsp" method="post" onsubmit="return validateForm()">
    <!-- Hidden input for passing expense ID to the update page -->
    <input type="hidden" name="id" value="<%= expenseId %>">

    <!-- Your form fields for editing -->
    <div class="mb-4">
        <label for="expense" class="block text-sm font-medium text-gray-600">Expense:</label>
        <input type="text" name="expense" id="expenseInput" value="<%= expense %>" class="mt-1 p-2 border rounded-md w-full">
        <span id="expenseError" class="text-red-500"></span>
    </div>

    <div class="mb-4">
        <label for="amount" class="block text-sm font-medium text-gray-600">Amount:</label>
        <input type="text" name="amount" id="amountInput" value="<%= amount %>" class="mt-1 p-2 border rounded-md w-full">
        <span id="amountError" class="text-red-500"></span>
    </div>

    <div class="mb-4">
        <label for="description" class="block text-sm font-medium text-gray-600">Description:</label>
        <textarea name="description" id="descriptionInput" class="mt-1 p-2 border rounded-md w-full"><%= description %></textarea>
        <span id="descriptionError" class="text-red-500"></span>
    </div>

    <div class="mb-4">
        <label for="date" class="block text-sm font-medium text-gray-600">Date:</label>
        <input type="text" name="date" id="dateInput" value="<%= date %>" class="mt-1 p-2 border rounded-md w-full">
        <span id="dateError" class="text-red-500"></span>
        <!-- You may want to use a date picker for better user experience -->
    </div>

    <button type="submit" class="bg-blue-500 text-white p-2 rounded-md">Update Expense</button>

    <script>
        function validateForm() {
            var expenseInput = document.getElementById('expenseInput').value;
            var amountInput = document.getElementById('amountInput').value;
            var descriptionInput = document.getElementById('descriptionInput').value;
            var dateInput = document.getElementById('dateInput').value;
            
            // Expense validation
            if (expenseInput.trim() === '') {
                document.getElementById('expenseError').innerText = 'Expense field cannot be empty.';
                return false;
            } else {
                document.getElementById('expenseError').innerText = '';
            }

            // Amount validation
            if (amountInput.trim() === '' || isNaN(amountInput)) {
                document.getElementById('amountError').innerText = 'Amount must be a valid number.';
                return false;
            } else {
                document.getElementById('amountError').innerText = '';
            }

            // Description validation
            if (descriptionInput.trim() === '') {
                document.getElementById('descriptionError').innerText = 'Description field cannot be empty.';
                return false;
            } else {
                document.getElementById('descriptionError').innerText = '';
            }

            // Date validation
            var dateRegex = /^\d{4}-\d{2}-\d{2}$/; // Change the regex as per your date format
            if (!dateRegex.test(dateInput)) {
                document.getElementById('dateError').innerText = 'Invalid date format. Please enter a valid date (YYYY-MM-DD).';
                return false;
            } else {
                var currentDate = new Date();
                var selectedDate = new Date(dateInput);
                
                if (selectedDate > currentDate) {
                    document.getElementById('dateError').innerText = 'Date cannot be in the future.';
                    return false;
                } else {
                    document.getElementById('dateError').innerText = '';
                }
            }

            // Add additional validation if needed

            return true;
        }
    </script>
</form>


    </div>


                        
 <%
        } else {
            // Handle the case where the expense with the given ID is not found
            out.println("Expense not found.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        // Handle exceptions appropriately
    } finally {
        // Close resources in the reverse order they were opened
        // ...
    }
%>

                      




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
                                    <button
                                        @click.prevent="activeTabe = 'user'"
                                        class="px-px pb-4 transition-all duration-200 transform translate-y-px border-b focus:outline-none"
                                        :class="{'border-primary-dark dark:border-primary': activeTabe == 'user', 'border-transparent': activeTabe != 'user'}"
                                        >
                                        User
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
                                                        src="https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
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
        <script >

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
          //Profil
        </script>

    </body>
</html>


