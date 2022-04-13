import React, { useState } from "react";
import PropTypes from 'prop-types';

async function loginUser(credentials) {
  try {
    const response = await fetch('http://localhost:3000/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(credentials)
    })
    console.log(response);
  } catch (err) {
    console.log(err)
  }
}

export default function LandingPage({ setToken }) {
  const [username, setUsername] = useState();
  const [password, setPassword] = useState();

  const handleSubmit = async e => {
    e.preventDefault();
    const response = await loginUser({
      username,
      password
    });
    console.log(response)
    //setToken(token);
  }

  return (
    <div>
      <h1> Landing Page </h1>
      <form onSubmit={handleSubmit}>
        <div>
          <input
            type="text"
            id="email"
            name="username"
            placeholder="Username"
            onChange={(e) => setUsername(e.target.value)}
            required
          />
        </div>
        <div>
          <input
            type="password"
            id="password"
            name="password"
            placeholder="Password"
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        <div>
          <button type="submit">Submit</button>
        </div>
      </form>
    </div>
  );
}

/*LandingPage.propTypes = {
  setToken: PropTypes.func.isRequired
}*/