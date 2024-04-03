import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/UpdateExpenseServlet")
public class UpdateExpenseServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int expenseId = Integer.parseInt(request.getParameter("id"));
        String updatedExpense = request.getParameter("expense");
        double updatedAmount = Double.parseDouble(request.getParameter("amount"));
        String updatedDescription = request.getParameter("description");
        String updatedDate = request.getParameter("date");
        HttpSession session = request.getSession();
        String loggedInUsername = (String) session.getAttribute("username");

        Connection connection = null;
        PreparedStatement preparedStatement = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/expensetracker", "root", "");

            String updateQuery = "UPDATE " + loggedInUsername + " SET expense=?, amount=?, description=?, date=? WHERE id=?";
            preparedStatement = connection.prepareStatement(updateQuery);
            preparedStatement.setString(1, updatedExpense);
            preparedStatement.setDouble(2, updatedAmount);
            preparedStatement.setString(3, updatedDescription);
            preparedStatement.setString(4, updatedDate);
            preparedStatement.setInt(5, expenseId);
            int rowsAffected = preparedStatement.executeUpdate();

            if (rowsAffected > 0) {
                response.sendRedirect("addWallet.jsp");
            } else {
                response.getWriter().println("Failed to update expense.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
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
    }
}
