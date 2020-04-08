// const PushNotifications = require('@pusher/push-notifications-server');

// let beamsClient = new PushNotifications({
//     instanceId: '2c57da76-8881-452d-93e7-974833886bda',
//     secretKey: '4D530ED4C7C703DE5622DF99A0B88447AA22CCDC7F8D05C360C2BD9AA1DD12FF'
// });

// const publish = (bucket) => {
//     beamsClient.publishToInterests(["44D235AD-9237-4619-824B-81CFB8991882"], {
//         apns: {
//             aps: {
//                 alert: 'Status changed in ' + bucket.crn + " Section: " + bucket.section.section_id
//             }
//         },
//         fcm: {
//             notification: {
//                 title: 'Status changed in ' + bucket.crn + " Section: " + bucket.section.section_id,
//                 body: 'There are currently ' + bucket.seats + ' available!'
//             }
//         }
//     }).then((publishResponse) => {
//         console.log('Just published:', publishResponse.publishId);
//         db.collection("bucket").findOneAndUpdate({
//             crn: bucket.crn
//         }, {
//             $set: {
//                 notify: false
//             }
//         })
//     }).catch((error) => {
//         console.error('Error:', error);
//     })
// }

// //module.exports = publish