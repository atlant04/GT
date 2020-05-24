import express from "express"
import { db } from "../db.js"
import parse from "../parse.js"
import publish from "../publisher.js"
const router = express.Router()

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
                //publish(bucket)
            }
        })
    })
}

export const startWorker = () => setInterval(() => checkBuckets(), 10000)