const functions = require('firebase-functions');
const admin = require('firebase-admin');
const serviceAccount = require('./ServiceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

var stream = require("getstream");

exports.recieveNotification = functions.https.onRequest((request, response) => {
  response.set("Content-Type", "text/html");
  response.send("wyjmu24k9tts")
});

exports.getUsersList = functions.https.onRequest((request, response) => {
  const token = request.token
  const users = [];

  return admin.auth().listUsers(50, token).then(listUsersResult => {
    listUsersResult.users.forEach(userRecord => {
      const data = {
        id: userRecord.uid,
        email: userRecord.email,
        name: userRecord.displayName,
        imgURL: userRecord.photoURL
      };
      users.push(data);
    });
    
    response.setHeader(
      "Content-disposition",
      "attachment; filename=users.json"
    );
    response.set("Content-Type", "application/json");
    response.status(200).send(users)
    return
  }).catch((err) => {
    console.log(err);
    throw new functions.https.HttpsError('Exception while getting users list', err);
  });
});

exports.createStreamToken = functions.https.onCall(async (data, context) => {
  try{
    const client = stream.connect('wyjmu24k9tts', '3sczq7cdgbjfecf4444qr98xq3u9f7mq5vqrfne76c7mmy6rtjybt8y2gg63mq33', '81406');
    const userID = data.UID;
    const firstName = data.firstName;
    const lastName = data.lastName;

    console.log("Function called with userID " + userID + " and name " + firstName + " " + lastName)
    await client.user(userID).getOrCreate({ firstName: firstName, lastName: lastName });
    const token = client.createUserToken(userID);

    const userTokenData = {
      user: userID, 
      token: token
    };

    const db = admin.firestore();
    return db.collection('userStreamTokens').doc(userID).set(userTokenData).then(() => {
      console.log('New stream user token saved');
      return { token: token };
    });

  } catch (err){
    console.error(err);
    throw new functions.https.HttpsError('Exception while creating token ', err);
  }
});

exports.isAdmin = functions.https.onCall(async (data, context) => {
  try{
    const userID = data.UID;
    const db = admin.firestore();
    return db.collection('adminList').doc(userID).get().then((snap) => {
      return { isAdmin: snap.exists };
    });

  } catch (err){
    console.error(err);
    throw new functions.https.HttpsError('Exception while checking admin status', err);
  }
});

exports.csvJsonReport = functions.https.onRequest((request, response) => {

  const db = admin.firestore();
  const ratingsRef = db.collectionGroup('ratingData')
  return ratingsRef.get()
    .then(querySnapshot => {
      const ratings = [];

      querySnapshot.forEach(doc => {
        ratings.push(doc.data());
      });

      response.setHeader(
        "Content-disposition",
        "attachment; filename=ratingsReport.json"
      );
      response.set("Content-Type", "application/json");
      response.status(200).send(ratings)
      return
    }).catch((err) => {
      console.log(err);
    });
});