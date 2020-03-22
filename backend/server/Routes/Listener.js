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

module.exports = router