const express = require('express')
const router = express.Router()
const parse = require('../parse.js')


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
    const crn = req.body.crn
    if (crn) {
        result = await parse("202008", crn)
        res.json(result)
    }
})

module.exports = router