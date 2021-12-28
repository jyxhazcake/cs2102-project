require('dotenv').config()

const pgp = require('pg-promise')()
const express = require('express')
const bodyParser = require('body-parser')
const { json } = require('express/lib/response')
const app = express()
const cors = require('cors')

app.use(cors())
app.use(express.json())

const port = 3000

const db = pgp({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
})

app.get('/', (req, res) => {
  res.send('Hello World!')
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
  console.log(req.body)
  db.proc('remove_department', [req.params.id]).then((data) => {
    res.send(data)
  })
})
