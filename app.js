import express from "express"
import parser from "body-parser"
import { start } from "./monitor.js"
import { courseInfoUpdate } from './jobs.js'
import CourseRoute from "./Routes/Course.js"
import ListenRoute from "./Routes/Listener.js"
import * as worker from "./Routes/Worker.js"
import * as db from "./db.js"

const app = express()

const port = process.env.PORT || 3000
app.use(parser.urlencoded({
    extended: true
}))

app.use(express.json());

db.connect(() => {
    app.use(CourseRoute)
    app.use(ListenRoute)
    app.listen(port, () => {
        console.log("Listening on port 3000")
        //worker.startWorker()
        //monitor.start("https://ada7996e.ngrok.io/listen")
    })
})
