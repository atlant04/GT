const PushNotifications = require('@pusher/push-notifications-server');

let beamsClient = new PushNotifications({
    instanceId: '2c57da76-8881-452d-93e7-974833886bda',
    secretKey: '81E64ADC63CFACF37021024F6D203E2D5D16E9E79F7377F5377F10945C8871CC'
});

const publish = (bucket) => {
    beamsClient.publishToInterests(bucket.subscribers, {
        apns: {
            aps: {
                alert: 'Status changed for ' + bucket.section.course.identifier
            }
        },
        fcm: {
            notification: {
                title: 'Status changed for ' + bucket.crn,
                body: 'There are currently ' + bucket.seats.remaining + " spots available"
            }
        }
    }).then((publishResponse) => {
        console.log('Just published:', publishResponse.publishId);
    }).catch((error) => {
        console.error('Error:', error);
    })
}

module.exports = publish