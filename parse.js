import axios from "axios"
import cheerio from "cheerio"

const fetch = async (term, crn) => {
    const baseUrl = `https://oscar.gatech.edu/pls/bprod/bwckschd.p_disp_detail_sched?term_in=${term}&crn_in=${crn}`
    const result = await axios.get(baseUrl)
    return cheerio.load(result.data)
}

const parse = async (term, crn) => {
    const $ = await fetch(term, crn)
    const keys = ["capacity", "actual", "remaining"]
    const seats = {}
    const waitlist = {}
    $('span').filter(function(index, el){
        return $(this).text() === "Seats"
    }).parent().parent().children('td').each((index, el) => {
        seats[keys[index]] = parseInt($(el).text())
    })

    $('span').filter(function(index, el){
        return $(this).text() === "Waitlist Seats"
    }).parent().parent().children('td').map((index, el) => {
        waitlist[keys[index]] = parseInt($(el).text())
    }).get()
    
    return {
        crn: crn,
        seats: seats,
        waitlist: waitlist
    }
}

export default parse