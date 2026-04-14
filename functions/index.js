// ═══ FILE: functions/index.js ═══
// Cloud Function: sends FCM push notification to resident when a new visitor request is created.

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.sendVisitorNotification = onDocumentCreated(
  "visitor_requests/{docId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data in document.");
      return;
    }

    const data = snapshot.data();
    const residentId = data.residentId;
    const visitorName = data.visitorName || "A visitor";
    const purpose = data.purpose || "a visit";

    if (!residentId) {
      console.log("No residentId found in request.");
      return;
    }

    try {
      // Fetch the resident's user document to get their FCM token
      const db = getFirestore();
      const userDoc = await db.collection("users").doc(residentId).get();

      if (!userDoc.exists) {
        console.log(`Resident user document not found: ${residentId}`);
        return;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for resident: ${residentId}`);
        return;
      }

      // Send the FCM notification
      const message = {
        notification: {
          title: "New Visitor Request",
          body: `${visitorName} is at the gate for ${purpose}`,
        },
        data: {
          requestId: event.params.docId,
          residentId: residentId,
        },
        token: fcmToken,
      };

      await getMessaging().send(message);
      console.log(`Notification sent to resident ${residentId} for visitor ${visitorName}`);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  }
);
