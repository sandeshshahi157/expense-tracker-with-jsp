import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/FetchExpensesServlet")
public class FetchExpensesServlet extends HttpServlet {

    // Define the Expense class within the servlet
    public class Expense {
        private String expenseType;
        private String description;
        private double amount;
        private String date;

        // Constructors, getters, and setters
        public Expense() {}

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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        HttpSession session = request.getSession();
        String logusername = (String) session.getAttribute("username");
        List<Expense> expensesList = new ArrayList<>();

        Connection connection = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

            String query = "SELECT * FROM " + logusername + " WHERE username=? AND expense LIKE ?";
            PreparedStatement preparedStatement = connection.prepareStatement(query);
            preparedStatement.setString(1, logusername);
            preparedStatement.setString(2, "%" + keyword + "%");

            ResultSet resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                Expense expense = new Expense();
                expense.setExpenseType(resultSet.getString("expense"));
                expense.setDescription(resultSet.getString("description"));
                expense.setAmount(resultSet.getDouble("amount"));
                expense.setDate(resultSet.getString("date"));
                expensesList.add(expense);
            }

            String jsonExpenses = new Gson().toJson(expensesList);

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
    }
}
