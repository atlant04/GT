import express from "express"
import { db } from "../db.js"

const router = express.Router()

router.get("/courses/:term", (req, res) => {
    db.collection(req.params.term)
        .find({})
        .toArray((err, courses) => {
            res.json(courses)
        })
})

router.get("/testCourses/:size", (req, res) => {
    const size = parseInt(req.params.size)
    db.collection("courses")
        .aggregate([{ $sample: { size: size } }])
        .toArray()
        .then(courses => res.json(courses))
})

router.get("/", (req, res) => {
    res.json({
        message: "HI",
    })
})

export default router
