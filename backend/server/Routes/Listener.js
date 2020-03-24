const express = require('express')
const router = express.Router()
const parse = require('../parse.js')
const db = require("../db.js").db()


router.post("/listen", async (req, res) => {
    const crns = req.body.sections[0].crn
    var result = []
    if (crns) {
        result = crns.map(crn => parse(req.body.semester, crn))
    }
    const data = await Promise.all(result)
    res.json(data)
})

router.post("/listen/section", async (req, res) => {
    db.collection("bucket").findOneAndUpdate({
        crn: req.body.section.crn,
    }, {
        $set: {
            seats: 0,
            notify: false,
            section: req.body.section
        },
        $addToSet: {
            "subscribers": req.body.user_id
        }
    }, {
        upsert: true
    })

    console.log(req.body)
    const crn = req.body.section.crn
    if (crn) {
        result = await parse("202008", crn)
        res.json(result)
    }
})


module.exports = router