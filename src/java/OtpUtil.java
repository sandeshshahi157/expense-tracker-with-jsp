import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class OtpUtil {

    public static String generateOTP() {
        // Implement your OTP generation logic here (e.g., using Random class)
        // This is a simple example; you may want to use a more secure method
        return String.format("%06d", new java.util.Random().nextInt(1000000));
    }

    public static void sendOTPEmail(String toEmail, String otp) {
        String fromEmail = "shahisandesh157@gmail.com"; // Replace with your email
        String password = "Momdad@#123"; // Replace with your email password

        // Configure the properties of the mail server
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com"); // Replace with your SMTP server
        props.put("mail.smtp.port", "587"); // Replace with your SMTP server port

        // Get the Session object and create an authenticator
        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, password);
            }
        });

        try {
            // Create a message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Your OTP");
            message.setText("Your OTP is: " + otp);

            // Send the message
            Transport.send(message);

        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}
