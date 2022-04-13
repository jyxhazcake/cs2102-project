require('dotenv').config()

const path = require('path')
const pgp = require('pg-promise')()
const express = require('express')
const bodyParser = require('body-parser')
const { json } = require('express/lib/response')
const app = express()
const cors = require('cors')
const { ssl } = require('pg/lib/defaults')
const { nextTick } = require('process')

app.use(cors())
app.use(express.json())
app.use(express.static(path.resolve(__dirname, 'client/build')))

/*##################
  # Authentication #
  ################## */

const session = require('express-session');
const flash = require('express-flash');
const passport = require('passport');

const initializePassport = require('./passportConfig')

initializePassport(passport);


//allows storing of session data
app.use(session({
  secret:'secret', //encrypt the session

  resave: false, //should we resave our session information if nothing has changed

  saveUninitialized: true //should we save our session if there is no information
  })
);

app.use(passport.initialize());
app.use(passport.session());

//displays flash messages
app.use(flash());

const port = process.env.PORT || 3000

//UNCOMMENT THIS IF YOU WANT TO USE LOCAL DB

/*const db = pgp({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
})*/

//THIS DB is used for production, its the heroku DB and will automatically switch urls.
const cn = {
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
};

const db = pgp(cn);

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})

app.get('/', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../client/build', 'index.js'));
})

/*app.use('/login', (req, res) => {
  res.send({
    token: 'test123'
  });
  next();
});*/

function checkAuthenticated(req, res, next) {
  if (req.isAuthenticated()) {
    return next()
  }

  res.redirect('/login')
}

function checkNotAuthenticated(req, res, next) {
  if (req.isAuthenticated()) {
    return res.redirect('/')
  }
  next()
}

app.post('/login', passport.authenticate('local', {
    successRedirect: "/employees",
    failureRedirect: "/",
    failureFlash: true
  })
);

//Get all departments
app.get('/departments', (req, res) => {
  db.query('SELECT * FROM departments').then((data) => {
    res.send(data)
  })
})

/**
 * Add a new deparment
 * DID - Integer
 * dname - String up to 50 characters
 */
app.post('/departments', (req, res) => {
  db.proc('add_department', [req.body.did, req.body.dname]).then((data) => {
    res.send(data)
  })
})

/**
 * Delete an existing department
 * ID - Integer
 */
app.delete('/departments/:id', (req, res) => {
  db.proc('remove_department', [req.params.id]).then((data) => {
    res.send(data)
  })
})

/* #################################################
############ Wei Xuan's components #################
#################################################### */

//Get all Employees
app.get('/employees', (req, res) => {
  db.query('SELECT * FROM Employees').then((data) => {
    res.send(data)
  })
})
//Add a new Employee
app.post('/employees', (req, res) => {
  console.log(req.body)
  db.proc('add_employee', [
    req.body.name,
    req.body.mobilenum,
    req.body.kind,
    req.body.did,
    req.body.homenum,
    req.body.officenum,
  ]).then((data) => {
    res.send(data)
  })
})

//Simulate an employee resigning
app.post('/employees/resign', (req, res) => {
  console.log(req.body)
  db.proc('remove_employee', [
    req.body.eid,
    req.body.date
  ])
})

//non_compliance function
app.post('/employees/non_compliance', (req, res) => {
  console.log(req.body)
  db.function('non_compliance', [req.body.start_date, req.body.end_date])
})

/**
 * Select specific employee
 * ID - Integer
 */
 app.get('/employees/:id', (req, res) => {
    db.query('SELECT * FROM Employees WHERE eid = $1', [req.params.id]).then(
      (data) => {
        res.send(data)
      }
    )
  })

//Contact_tracing function
app.get('/employees/:id/contact_tracing', (req, res) => {
  db.func('contact_tracing', [req.params.id]).then((data) => {
    res.send(data)
  })
})

//Get all rooms (use Postman or just go to http://localhost:3000/rooms)
app.get('/employees/:id/rooms', (req, res) => {
  db.query('SELECT * FROM Meeting_Rooms').then((data) => {
    res.send(data)
  })
})

/**
 * Add a new room
 * floor - Integer
 * room - Integer
 * rname - Text
 * room_capacity - Integer
 * did - Integer (Department which the room belongs to)
 * mid - Employee ID (Trigger enforces that this must be a Manager)
 * date - Date Object
 */
app.post('/employees/:id/rooms', (req, res) => {
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


/**
 * Change capacity of the room
 * floor - Integer
 * room - Integer
 * new_capacity - Integer
 * date - Date Object
 * mid - Employee ID (Trigger enforces that this must be a Manager)
 */
app.post('/employees/:id/rooms/change_capacity', (req, res) => {
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

/* 
Wei Xuan - I think it is necessary to create an interface to display the booking status
of the rooms as well to facilitate the booking/unbooking process
*/

/**
 * Book a room
 * floor - Integer
 * room - Integer
 * date - Date object
 * start_hour - Time object
 * end_hour - Time object
 * eid - Employee ID
 */
app.post('/employees/:id/rooms/book', (req, res) => {
  console.log(req.body)
  db.proc('book_room', [
    req.body.floor,
    req.body.room,
    req.body.date,
    req.body.start_hour,
    req.body.end_hour,
    req.params.id,
  ]).then((data) => {
    res.send(data)
  })
})

/**
 * Unbook a room
 * floor - Integer
 * room - Integer
 * date - Date object
 * start_hour - Time object
 * end_hour - Time object
 * eid - Employee ID
 */
app.post('/employees/:id/rooms/unbook', (req, res) => {
  console.log(req.body)
  db.proc('unbook_room', [
    req.body.floor,
    req.body.room,
    req.body.date,
    req.body.start_hour,
    req.body.end_hour,
    req.params.id,
  ]).then((data) => {
    res.send(data)
  })
})

// View future meeting of particular employee (wh-working)
/*
Note: Returns Date somehow in UTC+8 TimeZone. Sample return
[
    {
        "date": "2021-12-31T16:00:00.000Z",
        "start_hour": "01:00:00",
        "room": 1,
        "floor": 1
    }
]
We need to display the Date as 2021-01-01 in the FrontEnd! This possibly due to timezone conversion
*/

/**
 * View future meeting of particular employee from particular date
 * Date - Date Object, future meeting from this date
 * ID - Integer, Employee ID
 */
app.get('/employees/:id/:date/view-future-meeting/', (req, res) => {
  db.func('view_future_meeting', [req.params.date, req.params.id]).then(
    (data) => {
      res.send(data)
    }
  )
})

// View manager report if the employee is a manager - Datetime issue same as above (wh-working)
/**
 * View manager report of rooms to be approved if person is manager
 * Date - Date Object, all meeting rooms that needs to be approved from this date
 * ID - Employee ID
 */
app.get('/employees/:id/:date/view-manager-report', (req, res) => {
  db.func('view_manager_report', [req.params.date, req.params.id]).then(
    (data) => {
      res.send(data)
    }
  )
})

/**
 * Join meeting for specific employee
 * floor - Integer
 * room - Integer
 * date - Date object
 * start_hour - Time object
 * end_hour - Time object
 * eid - Employee ID
 */
app.post('/employees/join-meeting', (req, res) => {
  db.proc('join_meeting', [
    req.body.floor,
    req.body.room,
    req.body.date,
    req.body.start_hour,
    req.body.end_hour,
    req.body.eid,
  ]).then((data) => {
    res.send(data)
  })
})

/**
 * Leave meeting for specific employee
 * floor - Integer
 * room - Integer
 * date - Date object
 * start_hour - Time object
 * end_hour - Time object
 * eid - Employee ID
 */
app.delete(
  '/employees/:floor/:room/:date/:start_hour/:end_hour/:eid/leave-meeting',
  (req, res) => {
    db.proc('leave_meeting', [
      req.params.floor,
      req.params.room,
      req.params.date,
      req.params.start_hour,
      req.params.end_hour,
      req.params.eid,
    ]).then((data) => {
      res.send(data)
    })
  }
)

/**
 * Approve meeting if person is manager, else do nothing
 * floor - Integer
 * room - Integer
 * date - Date object
 * start_hour - Time object
 * end_hour - Time object
 * eid - Employee ID
 */
app.post('/employees/approve-meeting', (req, res) => {
  db.proc('approve_meeting', [
    req.body.floor,
    req.body.room,
    req.body.date,
    req.body.start_hour,
    req.body.end_hour,
    req.body.eid,
  ]).then((data) => {
    res.send(data)
  })
})
