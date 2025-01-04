const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: "gmail", // Or any other email provider
  auth: {
    user: "kingarain7866@gmail.com", // Replace with your email
    pass: "arainking7866", // Replace with your email password or app password
  },
});

exports.sendEmailWithImage = functions.https.onCall(async (data, context) => {
  const {email, imageUrl} = data; // Data passed from the Flutter app

  const mailOptions = {
    from: "kingarain7866@gmail.com",
    to: email, // Homeowner's email address
    subject: "Permission Request: Unknown Visitor",
    html: `
      <p>Someone is at your door.</p>
      <p>Do you want to give permission?</p>
      <img src="${imageUrl}" alt="Visitor Image" style="width:300px;height:300px;"/>
      <p>
        <a href="http://your-app-url.com/allow?user=${context.auth.uid}">Yes</a>
        <a href="http://your-app-url.com/deny?user=${context.auth.uid}" style="margin-left: 10px;">No</a>
      </p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("Email sent successfully!");
    return {message: "Email sent successfully!"};
  } catch (error) {
    console.error("Error sending email:", error);
    throw new functions.https.HttpsError("internal", "Error sending email.");
  }
});
