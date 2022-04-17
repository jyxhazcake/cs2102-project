const LocalStrategy = require("passport-local").Strategy;

function initialize(passport) {
    const authenticateUser = (email, password, done) => {
        db.query(
            'SELECT * FROM Employees WHERE email = $1', [email], (err, results) => {
                if (err) {
                    throw err;
                }

                console.log(results.rows);
                console.log("you have reached this stage")

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