require('dotenv').config()
const { Pool, Client } = require("pg");
const express = require('express')
const app = express()
const port = 3000

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
});

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})

app.post('/user', (req, res) => {
    pool.query('SELECT * FROM departments', (error, results) => {
        if (error) {
          throw error
        }
        res.status(200).json(results.rows)
    })
})