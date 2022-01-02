require('dotenv').config()

const path = require('path');
const pgp = require('pg-promise')()
const express = require('express')
const bodyParser = require('body-parser')
const { json } = require('express/lib/response')
const app = express()
const cors = require('cors')

app.use(cors())
app.use(express.json())
app.use(express.static(path.resolve(__dirname, 'client/build')));

const port =  process.env.PORT || 3001

//UNCOMMENT THIS IF YOU WANT TO USE LOCAL DB

// const db = pgp({
//   user: process.env.DB_USER,
//   host: process.env.DB_HOST,
//   database: process.env.DATABASE,
//   password: process.env.DB_PASSWORD,
//   port: process.env.DB_PORT,
// })

// THIS DB is used for production, its the heroku DB and will automatically switch urls.
const db = pgp(process.env.DATABASE_URL)

app.get('/', (req, res) => {
  res.sendFile(path.resolve(__dirname, 'client/build', 'index.html'));
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})

// //SELECT ALL DEPARTMENTS -json object
// db.proc('add_employee', ["test1", "9811-1220", "Junior", 2]), (error, results) => {
//       if (error) {
//         throw error
//       }
//       res.send(json)
// }

//Get all departments (use Postman or just go to http://localhost:3000/departments)
app.get('/departments', (req, res) => {
  db.query('SELECT * FROM departments').then((data) => {
    res.send(data)
  })
})

//Add a new deparment (You must use postman to test this)
app.post('/departments', (req, res) => {
  //console.log(req.body)
  console.log(req.body.did)
  db.proc('add_department', [req.body.did, req.body.dname]).then((data) => {
    res.send(data)
  })
})

//Delete an existing department (You must use postman to test this)
app.delete('/departments/:id', (req, res) => {
  db.proc('remove_department', [req.params.id]).then((data) => {
    res.send(data)
  })
})

//Get all rooms (use Postman or just go to http://localhost:3000/rooms)
app.get('/rooms', (req, res) => {
  db.query('SELECT * FROM Meeting_Rooms').then((data) => {
    res.send(data)
  })
})

//Add a new room (You must use postman to test this)
app.post('/rooms', (req, res) => {
  console.log(req.body)
  db.proc('add_room', [
    req.body.floor,
    req.body.room,
    req.body.rname,
    req.body.room_capacity,
    req.body.did,
    req.body.mid,
    req.body.date,
  ]).then((data) => {
    res.send(data)
  })
})

//Change capacity
app.post('/rooms', (req, res) => {
  console.log(req.body)
  db.proc('change_capacity', [
    req.body.floor,
    req.body.room,
    req.body.new_capacity,
    req.body.date,
    req.body.mid,
  ]).then((data) => {
    res.send(data)
  })
})
