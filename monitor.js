import parse from "./parse.js"
import axios from "axios"

const crns = [55187, 56670, 55191, 55193]

const monitor = async (term, crns) => {
    const result = await crns.map(crn => {
        return parse(term, crn)
    })
    return Promise.all(result)
}

const post = async (url) => {
    const result = await monitor(202005, crns)
    const res = await axios.post(url, result)
}

export const start = (url) => setInterval(() => post(url), 10000)
