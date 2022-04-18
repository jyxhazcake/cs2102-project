const LocalStrategy = require("passport-local").Strategy;
const pgp = require('pg-promise')()
const db = pgp({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DATABASE,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
})

function initialize(passport) {
    const authenticateUser = (email, password, done) => {
        db.query(
            'SELECT * FROM Employees WHERE email = $1', [email], (err, results) => {
                if (err) {
                    throw err;
                }

                console.log(results.rows);

                //check if there is a match for username
                if (results.rows.length > 0) {
                    const user = results.rows[0];

                    if (password == user.password) {
                        return done(null, user); //returns user if password matches
                    } else {
                        return done(null, false, {message: "Incorrect password"}); //returns false value if password does not match
                    }
                } else {
                    return done(null, false, {message: "Email is not registered"});
                }

                
            }
        )
    }

    passport.use (
        new LocalStrategy(
            { usernameField: "email", passwordField: "password" },
            authenticateUser
        )
    );

    passport.serializeUser((user,done) => done(null, user.eid)); //stores the userID in the session

    passport.deserializeUser((id,done) => {
        db.query(
            'SELECT * FROM Employees WHERE eid = $1', [id], (err, results) => {
                if (err) {
                    throw err;
                }
                return done(null, results.row[0]); //store the user id into the session
            }
        );
    });
}

module.exports = initialize;