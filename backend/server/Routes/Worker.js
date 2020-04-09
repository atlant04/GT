const express = require('express')
const router = express.Router()
const parse = require('../parse.js')
const db = require("../db.js").db()
const publish = require("../publisher.js")

const statusChanged = async (bucket) => {
    const data = await parse("202008", bucket.crn)
    var needsNotification = false

    if (bucket.seats.remaining == 0 && data.seats.remaining > 0) {
        needsNotification = true
    }

    db.collection("bucket").findOneAndUpdate({
        crn: bucket.crn
    }, {
        $set: {
            seats: data.seats,
            waitlist: data.waitlist
        }
    })
    return needsNotification
}


const checkBuckets = async () => {
    const buckets = await db.collection("bucket").find({}).toArray(async (err, buckets) => {
        buckets.forEach(async (bucket) => {
            const needsNotification = await statusChanged(bucket)
            if (needsNotification) {
                publish(bucket)
            }
        })
    })
}

module.exports = {
    startWorker: () => setInterval(() => checkBuckets(), 10000)
}