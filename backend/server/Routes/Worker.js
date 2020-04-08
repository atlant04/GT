const express = require('express')
const router = express.Router()
const parse = require('../parse.js')
const db = require("../db.js").db()
//const publish = require("../publisher.js")

const notify = async (bucket) => {
    const data = await parse("202008", bucket.crn)
    let remaining = data.data.seats.remaining

    var needsNotification;

    if (bucket.seats == 0 && remaining >= 0) {
        needsNotification = true
    } else {
        needsNotification = false
    }
    db.collection("bucket").findOneAndUpdate({
        crn: bucket.crn
    }, {
        $set: {
            seats: parseInt(remaining)
        }
    })
    return needsNotification
}


const buckets = async () => {
    const buckets = await db.collection("bucket").find({}).toArray((err, buckets) => {
        buckets.forEach(async (bucket) => {
            let needsNotification = await notify(bucket)
            if (needsNotification == true) {
                console.log(buckets)
                //publish(bucket)
            }
        })
    })
}

module.exports = {
    startWorker: () => setInterval(() => buckets(), 10000)
}