<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <!-- Include Tailwind CSS via CDN -->
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <style>
        .error-message {
            color: red;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        #loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        }
        #loading-spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top: 4px solid #3498db;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }
            100% {
                transform: rotate(360deg);
            }
        }
        img {
            cursor: pointer;
            transition: transform 0.3s ease-in-out;
        }
    </style>
    <script>
        function validateLoginForm() {
            var email = document.getElementById("email").value.trim();
            var password = document.getElementById("password").value;
            var rememberCheckbox = document.getElementById("remember");

            var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                displayErrorMessage("Invalid email address.", "email");
                return false;
            }

            if (password === '') {
                displayErrorMessage("Password is required.", "password");
                return false;
            }

            if (rememberCheckbox.checked) {
                var expiryDate = new Date();
                expiryDate.setDate(expiryDate.getDate() + 30);

                document.cookie = "rememberedEmail=" + email + "; expires=" + expiryDate.toUTCString() + "; path=/";
                document.cookie = "rememberedPassword=" + password + "; expires=" + expiryDate.toUTCString() + "; path=/";
            }

            showLoadingOverlay();
            return true;
        }

        function showLoadingOverlay() {
            document.getElementById("loading-overlay").style.display = "flex";
            setTimeout(function () {
                window.location.href = "dashboard.jsp";
            }, 2000);
        }

        function displayErrorMessage(message, fieldId) {
            var errorMessage = document.createElement("div");
            errorMessage.className = "error-message";
            errorMessage.textContent = message;

            var field = document.getElementById(fieldId);
            field.parentNode.appendChild(errorMessage);
        }
    </script>
</head>
<body>
<section class="w-screen h-screen">
    <div class="py-8 px-4 mx-auto max-w-screen-2xl lg:py-28 grid lg:grid-cols-2  lg:gap-28">
        <div class="flex flex-col justify-center">
            <img src="images/svg_1.svg" alt="alt"/>
        </div>
        <div>
            <div class="w-full lg:max-w-xl p-6 space-y-8 sm:p-8 bg-white rounded-lg shadow-xl dark:bg-gray-800">
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Sign in</h2>
                <div class="pt-3 pb-3">
                    <% 
                        String error = request.getParameter("error");
                        if (error != null) {
                            if (error.equals("invalidCredentials")) {
                    %>
                                <div id="errorMessage" style="color: red;">Invalid email or password. Please try again.</div>
                    <%
                            } else if (error.equals("userNotFound")) {
                    %>
                                <div id="errorMessage" style="color: red;">User does not exist. Please check your email or register.</div>
                    <%
                            }
                    %>
                                <script>
                                    setTimeout(function() {
                                        var errorMessage = document.getElementById("errorMessage");
                                        if (errorMessage) {
                                            errorMessage.style.display = "none";
                                        }
                                    }, 5000);
                                </script>
                    <%
                        }
                    %>
                </div>
                <form class="mt-8 space-y-6" action="loginProcess.jsp" onsubmit="return validateLoginForm();" method="post">
                    <div>
                        <label for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Your email</label>
                        <input type="text" name="email" id="email" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500" placeholder="name@company.com">
                    </div>
                    <div>
                        <label for="password" class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">Your password</label>
                        <input type="password" name="password" id="password" placeholder="••••••••" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500">
                    </div>
                    <div class="flex items-start">
                        <div class="flex items-center h-5">
                            <input id="remember" aria-describedby="remember" name="remember" type="checkbox" class="w-4 h-4 border-gray-300 rounded bg-gray-50 focus:ring-3 focus:ring-blue-300 dark:focus:ring-blue-600 dark:ring-offset-gray-800 dark:bg-gray-700 dark:border-gray-600">
                        </div>
                        <div class="ms-3 text-sm">
                            <label for="remember" name="rememberMe" class="font-medium text-gray-500 dark:text-gray-400">Remember this device</label>
                        </div>
                        <a href="#" class="ms-auto text-sm font-medium text-blue-600 hover:underline dark:text-blue-500">Lost Password?</a>
                    </div>
                    <button type="submit" class="w-full px-5 py-3 text-base font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 sm:w-auto dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800">Login to your account</button>
                    <div class="text-sm font-medium text-gray-900 dark:text-white">
                        Not registered yet? <a href="register.jsp" class="pl-3 text-blue-600 hover:underline dark:text-blue-500">Create account</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <button id="loading-overlay" type="button" class="py-2 px-4 flex justify-center items-center  bg-blue-600 hover:bg-blue-700 focus:ring-blue-500 focus:ring-offset-blue-200 text-white w-full transition ease-in duration-200 text-center text-base font-semibold shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2  rounded-lg ">
        <div class="loading-spinner">
            <svg width="20" height="20" fill="currentColor" class="mr-2 animate-spin" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
                <path d="M526 1394q0 53-37.5 90.5t-90.5 37.5q-52 0-90-38t-38-90q0-53 37.5-90.5t90.5-37.5 90.5 37.5 37.5 90.5zm498 206q0 53-37.5 90.5t-90.5 37.5-90.5-37.5-37.5-90.5 37.5-90.5 90.5-37.5 90.5 37.5 37.5 90.5zm-704-704q0 53-37.5 90.5t-90.5 37.5-90.5-37.5-37.5-90.5 37.5-90.5 90.5-37.5 90.5 37.5 37.5 90.5zm1202 498q0 52-38 90t-90 38q-53 0-90.5-37.5t-37.5-90.5 37.5-90.5 90.5-37.5 90.5 37.5 37.5 90.5zm-964-996q0 66-47 113t-113 47-113-47-47-113 47-113 113-47 113 47 47 113zm1170 498q0 53-37.5 90.5t-90.5 37.5-90.5-37.5-37.5-90.5 37.5-90.5 90.5-37.5 90.5 37.5 37.5 90.5zm-640-704q0 80-56 136t-136 56-136-56-56-136 56-136 136-56 136 56 56 136zm530 206q0 93-66 158.5t-158 65.5q-93 0-158.5-65.5t-65.5-158.5q0-92 65.5-158t158.5-66q92 0 158 66t66 158z"></path>
            </svg>
            loading
        </div>
    </button>
</section>
</body>
</html>
