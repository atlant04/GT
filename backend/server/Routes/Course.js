const express = require('express')
const router = express.Router()
const db = require('../db.js').db()

router.get('/courses', (req, res) => {
    db.collection("courses").find({}).toArray((err, courses) => {
        console.log(courses)
        res.json(courses)
    })
})

router.get('/', (req, res) => {
    res.json({
        message: "HI"
    })
})



module.exports = router