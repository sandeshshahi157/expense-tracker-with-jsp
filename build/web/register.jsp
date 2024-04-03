<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up</title>

        <!-- Include Tailwind CSS via CDN -->
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">

        <style>
            .error-message {
                color: red;
                font-size: 0.875rem;
                margin-top: 0.25rem;
            }


            .max-w-md {
                max-width: 28rem; /* Set the maximum width for the image container */
            }

            .object-cover {
                object-fit: cover; /* Ensure the image covers the container */
            }

            .object-center {
                object-position: center; /* Center the image within the container */
            }

            /* Adjust margin for smaller screens */
            @media (max-width: 840px) {
                .lg:mt-40 {
                    margin-top: 0; /* Remove top margin on smaller screens */
                }
                img{

                    position: absolute;
                    width: 100%;

                }
                .mainComp{
                    position: absolute;
                    background-color: white;
                    margin-top:12.8rem;
                    width: 100%;
                }

            }

            .mainComp{
                width: 100%;
            }
            .mainComp form
            {
                width: 100%;
            }
        </style>

        <script>
            function validateForm() {
                // Fetch form input values
                var firstName = document.getElementById("FirstName").value.trim();
                var lastName = document.getElementById("LastName").value.trim();
                var email = document.getElementById("Email").value.trim();
                var password = document.getElementById("Password").value;
                var passwordConfirmation = document.getElementById("PasswordConfirmation").value;
                var marketingAccept = document.getElementById("MarketingAccept").checked;

                // Clear previous error messages
                clearErrorMessages();




                function isValidName(name) {
                    // Allow only letters and spaces in the name
                    return /^[a-zA-Z\s]+$/.test(name);
                }
                // Validate First Name
                if (firstName === '') {
                    displayErrorMessage("First Name is required.", "FirstName");
                    return false;
                }

                // Validate Last Name
                if (lastName === '') {
                    displayErrorMessage("Last Name is required.", "LastName");
                    return false;
                }

                if (!isValidName(firstName)) {
                    displayErrorMessage("First Name should contain only letters and spaces.", "FirstName");
                    return false;
                }

                // Validate Last Name
                if (!isValidName(lastName)) {
                    displayErrorMessage("Last Name should contain only letters and spaces.", "LastName");
                    return false;
                }

                // Validate Email using a simple regex
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(email)) {
                    displayErrorMessage("Invalid email address.", "Email");
                    return false;
                }

                // Validate Password length
                if (password.length < 6) {
                    displayErrorMessage("Password should be at least 6 characters long.", "Password");
                    return false;
                }

                // Validate Password Confirmation
                if (password !== passwordConfirmation) {
                    displayErrorMessage("Password and confirmation do not match.", "PasswordConfirmation");
                    return false;
                }

                // Validate Marketing Acceptance
                if (!marketingAccept) {
                    displayErrorMessage("You must accept marketing terms to proceed.", "MarketingAccept");
                    return false;
                }

                // If all validations pass, allow the form submission
                return true;
            }



            function displayErrorMessage(message, fieldId) {
                var errorMessage = document.createElement("div");
                errorMessage.className = "error-message";
                errorMessage.textContent = message;

                // Display error message next to the corresponding input field
                var field = document.getElementById(fieldId);
                field.parentNode.appendChild(errorMessage);
            }

            function clearErrorMessages() {
                var errorMessages = document.querySelectorAll(".error-message");
                errorMessages.forEach(function (errorMessage) {
                    errorMessage.remove();
                });
            }
        </script>
    </head>
    <body>
        <section class="bg-white ">
            <div class="lg:grid lg:min-h-screen lg:grid-cols-12 sm:grid-cols-12   ">
                <aside class=" relative lg:mt-40 block h-16 lg:order-last lg:col-span-5 lg:h-full xl:col-span-6 ">
                    <img
                        alt="Pattern"
                        src="images/svg_5.svg"
                        class=" relatve  object-fit "
                        />
                </aside>

                <main class="flex items-center justify-center px-8 py-8 sm:px-12 lg:col-span-7 mainComp lg:px-16 lg:py-12 xl:col-span-6">
                    <div class="max-w-xl lg:max-w-3xl">
                        <h1 class="mt-6 text-2xl font-bold text-blue-500 sm:text-3xl md:text-4xl">
                            Welcome to Expense Tracker 
                        </h1>

                        <form action="signupProcess.jsp" onsubmit="return validateForm();" class="mt-8 grid grid-cols-6 gap-6" method="post">
                            <div class="col-span-6 sm:col-span-3">
                                <label for="FirstName" class="block text-sm font-medium text-gray-700">First Name</label>
                                <input
                                    type="text"
                                    id="FirstName"
                                    name="first_name"
                                    class="text-center focus:outline-none bg-gray-100 text-md h-11 mt-1 w-full rounded-md text-gray-700 shadow-sm"
                                    />
                            </div>

                            <div class="col-span-6 sm:col-span-3">
                                <label for="LastName" class="block text-sm font-medium text-gray-700">Last Name</label>
                                <input
                                    type="text"
                                    id="LastName"
                                    name="last_name"
                                    class="text-center focus:outline-none bg-gray-100 text-md h-11 mt-1 w-full rounded-md border-gray-200 text-md text-gray-700 shadow-sm"
                                    />
                            </div>

                            <div class="col-span-6">
                                <label for="Email" class="block text-sm font-medium text-gray-700">Email</label>
                                <input
                                    type="text"
                                    id="Email"
                                    name="email"
                                    class="text-center focus:outline-none bg-gray-100 text-md h-11 mt-1 w-full rounded-md border-gray-200 text-md text-gray-700 shadow-sm"
                                    />
                                
                               

    
                            </div>

                            <div class="col-span-6 sm:col-span-3">
                                <label for="Password" class="block text-sm font-medium text-gray-700">Password</label>
                                <input
                                    type="password"
                                    id="Password"
                                    name="password"
                                    class="text-center focus:outline-none bg-gray-100 text-md text-center focus:outline-none bg-gray-100 text-md h-11 mt-1 w-full rounded-md border-gray-200 text-sm text-gray-700 shadow-sm"
                                    />
                            </div>

                            <div class="col-span-6 sm:col-span-3">
                                <label for="PasswordConfirmation" class="block text-sm font-medium text-gray-700">Password Confirmation</label>
                                <input
                                    type="password"
                                    id="PasswordConfirmation"
                                    name="password_confirmation"
                                    class="text-center focus:outline-none bg-gray-100 text-md h-11 mt-1 w-full rounded-md border-gray-200 text-sm text-gray-700 shadow-sm"
                                    />
                            </div>

                            <div class="col-span-6">
                                <label for="MarketingAccept" class="flex gap-4">
                                    <input
                                        type="checkbox"
                                        id="MarketingAccept"
                                        name="marketing_accept"
                                        class="h-5 w-5 rounded-md border-gray-200 bg-white shadow-sm"
                                        />
                                    <span class="text-sm text-gray-700">
                                        I want to receive emails about events, product updates and company announcements.
                                    </span>
                                </label>
                            </div>

                            <div class="col-span-6">
                                <p class="text-sm text-gray-500">
                                    By creating an account, you agree to our
                                    <a href="#" class="text-gray-700 underline">terms and conditions</a>
                                    and
                                    <a href="#" class="text-gray-700 underline">privacy policy</a>.
                                </p>
                            </div>

                            <!-- Error messages will be displayed here -->

                            <div class="col-span-6 sm:flex sm:items-center sm:gap-4">
                                <button
                                    class="inline-block shrink-0 rounded-md border border-blue-600 bg-blue-600 px-12 py-3 text-sm font-medium text-white transition hover:bg-transparent hover:text-blue-600 focus:outline-none focus:ring active:text-blue-500"
                                    type="submit">
                                    Create an account
                                </button>
                                <p class="mt-4 text-sm text-gray-500 sm:mt-0">
                                    Already have an account?
                                    <a href="login.jsp" class="pl-3 text-blue-500 underline">Log in</a>.
                                </p>
                            </div>
                        </form>
                    </div>
                </main>
            </div>
        </section>
    </body>
</html>
