const functions = require('firebase-functions');

exports.addViaEmail = functions.https.onRequest((request, response) => {
  const emailAddress = request.query.email_address;
  response.send("Send email to ["+emailAddress+"]");
});