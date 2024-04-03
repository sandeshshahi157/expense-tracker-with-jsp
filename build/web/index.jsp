<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*, java.io.*" %>



<%
    String rememberedUser = null;
    HttpSession existingSession = request.getSession(false);
    if (existingSession != null && existingSession.getAttribute("username") != null) {
        // User is already logged in, redirect to the dashboard
        response.sendRedirect("dashboard.jsp");
    } else {
        // Check if the user has a remembered cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("username")) {
                    rememberedUser = cookie.getValue();
                    break;
                }
            }
        }
    }
        // If a remembered user is found, set the username in a new session and redirect to the dashboard
        if (rememberedUser != null) {
            HttpSession newSession = request.getSession();
            newSession.setAttribute("username", rememberedUser);
            response.sendRedirect("dashboard.jsp");
        } else {
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <link rel="stylesheet" href="Component/tailwind.css" />
    
    <!-- Your existing head content -->

    <!-- Font Awesome for social media icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"
        integrity="sha384-Bm3ZRjVhFgSKE7cP6KnoP8E2GPmW6f2O2i8XMlRizkqJL6v3+3HEI8L4PYPXJf2a" crossorigin="anonymous" />
    <!-- Font Awesome for social media icons -->
    <script src="https://kit.fontawesome.com/your-kit-id.js" crossorigin="anonymous"></script>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@200;300;400;600;700;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" />
    <script src="https://cdn.jsdelivr.net/gh/alpine-collective/alpine-magic-helpers@0.5.x/dist/component.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.2.1/datepicker.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/alpinejs@2.8.2/dist/alpine.min.js" defer></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.bundle.min.js"></script>
    
    <!-- Your existing stylesheets and scripts -->

    <style>
        body {
            font-family: 'Cairo', sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
            position: relative;
            overflow-y: auto;
            overflow-x: hidden;
        }

        header {
            background-color: #1a202c;
            color: #ffffff;
            padding: 2rem;
            text-align: center;
        }

        .Header {
            align-items: center;
            text-align: center;
            justify-content: space-around;
        }

        section {
            text-align: center;
            padding: 4rem 2rem;
            position: relative;
            overflow: hidden;
        }

        .images img {
            max-width: 100%;
            height: auto;
            transform: rotateY(10deg) rotateX(10deg);
            transition: transform 0.5s ease;
        }

        footer {
            background-color: #1a202c;
            color: #ffffff;
            padding: 2rem;
            text-align: center;
            position: relative;
            overflow: hidden;
            display: flex;
            flex-wrap: wrap;
            justify-content: space-around;
        }
        
        /* Loading screen styles */
        .loading-screen {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.8);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .loader {
            border: 16px solid #f3f3f3;
            border-top: 16px solid #3498db;
            border-radius: 50%;
            width: 120px;
            height: 120px;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>

<body class="font-mono h-screen w-screen">

   <header class="bg-black text-white py-4">
        <div class="flex Header items-center justify-content-space-around">
            <h1 class="text-2xl font-semibold pt-5">Expense Tracker</h1>
            <div class="mt-4 flex gap-8 ">
                <button class="w-28 h-10 shadow-md shadow-gray-500/50 rounded-lg bg-black">
                    <a href="register.jsp">Sign Up</a>
                </button>
                <button class="w-28 h-10 shadow-md shadow-gray-500/50 rounded-lg bg-purple-400">
                    <a href="login.jsp">Login</a>
                </button>
            </div>
        </div>
    </header>

    <section class="lg:flex items-center w-screen bg-gray-900 relative">
        <div class="w-auto flex-col ">
            <h2 class="text-3xl mt-8 mb-6 lg:pl-5  text-gray-300">
                Effortlessly manage and track your expenses with our powerful Expense Tracker. Gain insights, save money, and
                achieve financial freedom.
            </h2>
            <a href="login.jsp" class="btn rounded-lg btn-teal">Get Started</a>
        </div>
        <div class="w-full relative images">
            <img src="images/svg_2.svg" alt="Expense Tracker Logo"
                class="rounded-lg shadow-md shadow-gray-500/50 mx-auto mt-10">
            <div class="corner-design"></div>
        </div>
    </section>

    <section class="bg-gray-200 w-screen">
<div class="flex-wrap items-center justify-center gap-8 text-center sm:flex">
    <div class="w-full px-4 py-4 mt-6 bg-white rounded-lg shadow-lg sm:w-1/2 md:w-1/2 lg:w-1/4 dark:bg-gray-800">
        <div class="flex-shrink-0">
            <div class="flex items-center justify-center w-12 h-12 mx-auto text-white bg-indigo-500 rounded-md">
                <svg width="20" height="20" fill="currentColor" class="w-6 h-6" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
                    <path d="M491 1536l91-91-235-235-91 91v107h128v128h107zm523-928q0-22-22-22-10 0-17 7l-542 542q-7 7-7 17 0 22 22 22 10 0 17-7l542-542q7-7 7-17zm-54-192l416 416-832 832h-416v-416zm683 96q0 53-37 90l-166 166-416-416 166-165q36-38 90-38 53 0 91 38l235 234q37 39 37 91z">
                    </path>
                </svg>
            </div>
        </div>
        <h3 class="py-4 text-2xl font-semibold text-gray-700 sm:text-xl dark:text-white">
            Why Use Expense Tracker?
        </h3>
        <p class="py-4 text-gray-500 text-md dark:text-gray-300">
            Expense Tracker helps you efficiently manage your finances, providing insights into your spending habits and budget planning.
        </p>
    </div>
    <div class="w-full px-4 py-4 mt-6 bg-white rounded-lg shadow-lg sm:w-1/2 md:w-1/2 lg:w-1/4 sm:mt-16 md:mt-20 lg:mt-24 dark:bg-gray-800">
        <div class="flex-shrink-0">
            <div class="flex items-center justify-center w-12 h-12 mx-auto text-white bg-indigo-500 rounded-md">
                <svg width="20" height="20" fill="currentColor" class="w-6 h-6" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
                    <path d="M491 1536l91-91-235-235-91 91v107h128v128h107zm523-928q0-22-22-22-10 0-17 7l-542 542q-7 7-7 17 0 22 22 22 10 0 17-7l542-542q7-7 7-17zm-54-192l416 416-832 832h-416v-416zm683 96q0 53-37 90l-166 166-416-416 166-165q36-38 90-38 53 0 91 38l235 234q37 39 37 91z">
                    </path>
                </svg>
            </div>
        </div>
        <h3 class="py-4 text-2xl font-semibold text-gray-700 sm:text-xl dark:text-white">
            What Are the Benefits of Expense Tracker?
        </h3>
        <p class="py-4 text-gray-500 text-md dark:text-gray-300">
            Expense Tracker allows you to track your spending, set budget goals, receive financial insights, and achieve financial stability.
        </p>
    </div>
    <div class="w-full px-4 py-4 mt-6 bg-white rounded-lg shadow-lg sm:w-1/2 md:w-1/2 lg:w-1/4 dark:bg-gray-800">
        <div class="flex-shrink-0">
            <div class="flex items-center justify-center w-12 h-12 mx-auto text-white bg-indigo-500 rounded-md">
                <svg width="20" height="20" fill="currentColor" class="w-6 h-6" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
                    <path d="M491 1536l91-91-235-235-91 91v107h128v128h107zm523-928q0-22-22-22-10 0-17 7l-542 542q-7 7-7 17 0 22 22 22 10 0 17-7l542-542q7-7 7-17zm-54-192l416 416-832 832h-416v-416zm683 96q0 53-37 90l-166 166-416-416 166-165q36-38 90-38 53 0 91 38l235 234q37 39 37 91z">
                    </path>
                </svg>
            </div>
        </div>
        <h3 class="py-4 text-2xl font-semibold text-gray-700 sm:text-xl dark:text-white">
            Why Is Expense Tracker Needed?
        </h3>
        <p class="py-4 text-gray-500 text-md dark:text-gray-300">
            Expense Tracker is essential for maintaining a clear understanding of your financial health, avoiding overspending, and achieving your savings objectives.
        </p>
    </div>
</div>



    </section>


<footer class="footer p-10 bg-base-200 text-base-content">
  <nav>
    <h6 class="footer-title">Services</h6> 
    <a class="link link-hover">Branding</a>
    <a class="link link-hover">Design</a>
    <a class="link link-hover">Marketing</a>
    <a class="link link-hover">Advertisement</a>
  </nav> 
  <nav>
    <h6 class="footer-title">Company</h6> 
    <a class="link link-hover">About us</a>
    <a class="link link-hover">Contact</a>
    <a class="link link-hover">Jobs</a>
    <a class="link link-hover">Press kit</a>
  </nav> 
  <nav>
    <h6 class="footer-title">Legal</h6> 
    <a class="link link-hover">Terms of use</a>
    <a class="link link-hover">Privacy policy</a>
    <a class="link link-hover">Cookie policy</a>
  </nav>
</footer> 
<footer class="footer px-10 py-4 border-t bg-base-200 text-base-content border-base-300">
  <aside class="items-center grid-flow-col">
    <svg width="24" height="24" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" class="fill-current"><path d="M22.672 15.226l-2.432.811.841 2.515c.33 1.019-.209 2.127-1.23 2.456-1.15.325-2.148-.321-2.463-1.226l-.84-2.518-5.013 1.677.84 2.517c.391 1.203-.434 2.542-1.831 2.542-.88 0-1.601-.564-1.86-1.314l-.842-2.516-2.431.809c-1.135.328-2.145-.317-2.463-1.229-.329-1.018.211-2.127 1.231-2.456l2.432-.809-1.621-4.823-2.432.808c-1.355.384-2.558-.59-2.558-1.839 0-.817.509-1.582 1.327-1.846l2.433-.809-.842-2.515c-.33-1.02.211-2.129 1.232-2.458 1.02-.329 2.13.209 2.461 1.229l.842 2.515 5.011-1.677-.839-2.517c-.403-1.238.484-2.553 1.843-2.553.819 0 1.585.509 1.85 1.326l.841 2.517 2.431-.81c1.02-.33 2.131.211 2.461 1.229.332 1.018-.21 2.126-1.23 2.456l-2.433.809 1.622 4.823 2.433-.809c1.242-.401 2.557.484 2.557 1.838 0 .819-.51 1.583-1.328 1.847m-8.992-6.428l-5.01 1.675 1.619 4.828 5.011-1.674-1.62-4.829z"></path></svg>
    <p>Hackeath <br>Providing reliable Service</p>
  </aside> 
  <nav class="md:place-self-center md:justify-self-end">
    <div class="grid grid-flow-col gap-4">
      <a><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="fill-current"><path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z"></path></svg></a>
      <a><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="fill-current"><path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z"></path></svg></a>
      <a><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" class="fill-current"><path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z"></path></svg></a>
    </div>
  </nav>
</footer>
 <div id="loadingScreen" class="loading-screen">
        <div class="loader"></div>
    </div>


    <script>
        document.onreadystatechange = function () {
            if (document.readyState === 'complete') {
                document.getElementById('loadingScreen').style.display = 'none';
            }
        };
    </script>

</body>

</html>

<%
    }
%>
