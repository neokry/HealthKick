'use strict';

var admin = require('firebase-admin')
const serviceAccount = require('./ServiceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://health-kick-a3832.firebaseio.com"
});
const db = admin.firestore();

exports.handler = async function(event) {
  try {
    console.info("Starting function with event: " + JSON.stringify(event));

    const promises = [];
    event.Records.forEach(record => {
      let buff = Buffer.from(record.body, 'base64')
      let stringData = buff.toString('ascii');
      let jsonData = JSON.parse(stringData)
      console.info("Decoded record: " + JSON.stringify(jsonData));
      jsonData.forEach(message => {
        message.new.forEach(newMessage => {
          promises.push(processMessage(newMessage));
        });
      });
    });


    return Promise.all(promises);

  } catch (err) {
    console.log(err)
    return
  }
};

function processMessage(newMessage) {
  console.info("Processing message " + JSON.stringify(newMessage))
  return new Promise(resolve => {
    const id = newMessage.object.actor.id;
    console.info("Found user id " + id)

    db.collection("userNotificationTokens").doc(id).get()
      .then(doc => {
        const token = doc.data()["token"];
        console.log("Found token " + token)

        var body = newMessage.actor.data.firstName + " " + newMessage.actor.data.lastName

        if (newMessage.reaction.kind == "comment") {
          body += " commented on your post"
        }else if (newMessage.reaction.kind == "like"){
          body += " liked your post"
        } else if (newMessage.reaction.kind == "follow"){
          body += " followed you"
        }

        console.log("Sending message: " + body)

        var message = {
          notification: {
            title: null,
            body: body
          },
          token: token
        };

        admin.messaging().send(message)
          .then((response) => {
            console.log("Sent message", response)
            resolve(true)
          })
          .catch((err) => {
            console.log("Error: ", err);
            resolve(false)
          });
      }).catch((err) => {
        console.log("Error: ", err);
        resolve(false)
      });
  })
}
